param(
    [Parameter(Mandatory = $true)]
    [string]$XexPath,

    [string]$OutputPath = 'evidence/local/xex-metadata.json'
)

$ErrorActionPreference = 'Stop'

function Read-Be16([byte[]]$Bytes, [int]$Offset) {
    return ([uint16]$Bytes[$Offset] -shl 8) -bor [uint16]$Bytes[$Offset + 1]
}

function Read-Be32([byte[]]$Bytes, [int]$Offset) {
    return ([uint32]$Bytes[$Offset] -shl 24) -bor
        ([uint32]$Bytes[$Offset + 1] -shl 16) -bor
        ([uint32]$Bytes[$Offset + 2] -shl 8) -bor
        [uint32]$Bytes[$Offset + 3]
}

$resolved = (Resolve-Path -LiteralPath $XexPath).Path
$bytes = [System.IO.File]::ReadAllBytes($resolved)
if ($bytes.Length -lt 0x18 -or [System.Text.Encoding]::ASCII.GetString($bytes, 0, 4) -ne 'XEX2') {
    throw 'Input is not an XEX2 file.'
}

$headerCount = Read-Be32 $bytes 0x14
$optional = @{}
for ($index = 0; $index -lt $headerCount; $index++) {
    $offset = 0x18 + ($index * 8)
    if ($offset + 8 -gt $bytes.Length) { throw 'Optional-header table exceeds the file.' }
    $key = Read-Be32 $bytes $offset
    $value = Read-Be32 $bytes ($offset + 4)
    $optional[$key] = $value
}

$entryKey = [uint32]0x00010100
$imageBaseKey = [uint32]0x00010201
$executionKey = [uint32]0x00040006
$fileFormatKey = [uint32]0x000003FF
$importsKey = [uint32]0x000103FF
if (-not $optional.ContainsKey($entryKey) -or -not $optional.ContainsKey($imageBaseKey) -or
    -not $optional.ContainsKey($executionKey) -or -not $optional.ContainsKey($fileFormatKey)) {
    throw 'Required XEX optional headers are missing.'
}

$executionOffset = [int]$optional[$executionKey]
if ($executionOffset + 0x18 -gt $bytes.Length) { throw 'Execution-info header exceeds the file.' }

$rawVersion = Read-Be32 $bytes ($executionOffset + 4)
$versionMajor = ($rawVersion -shr 28) -band 0xF
$versionMinor = ($rawVersion -shr 24) -band 0xF
$versionBuild = ($rawVersion -shr 8) -band 0xFFFF
$versionQfe = $rawVersion -band 0xFF

$item = Get-Item -LiteralPath $resolved
$hash = Get-FileHash -LiteralPath $resolved -Algorithm SHA256

$securityOffset = [int](Read-Be32 $bytes 0x10)
if ($securityOffset + 0x184 -gt $bytes.Length) { throw 'Security header exceeds the file.' }
$pageDescriptorCount = Read-Be32 $bytes ($securityOffset + 0x180)
$sectionCounts = [ordered]@{ code = 0; data = 0; readOnlyData = 0; unknown = 0 }
$totalPages = [uint64]0
for ($index = 0; $index -lt $pageDescriptorCount; $index++) {
    $descriptorOffset = $securityOffset + 0x184 + ($index * 0x18)
    if ($descriptorOffset + 0x18 -gt $bytes.Length) { throw 'Page descriptors exceed the file.' }
    $descriptor = Read-Be32 $bytes $descriptorOffset
    $sectionType = $descriptor -band 0xF
    $pageCount = $descriptor -shr 4
    $totalPages += $pageCount
    switch ($sectionType) {
        1 { $sectionCounts.code++ }
        2 { $sectionCounts.data++ }
        3 { $sectionCounts.readOnlyData++ }
        default { $sectionCounts.unknown++ }
    }
}

$encryptionNames = @('none', 'normal')
$compressionNames = @('none', 'basic', 'normal', 'delta')
$fileFormatOffset = [int]$optional[$fileFormatKey]
$encryptionValue = Read-Be16 $bytes ($fileFormatOffset + 4)
$compressionValue = Read-Be16 $bytes ($fileFormatOffset + 6)

$importLibraryCount = 0
$importSymbolCount = 0
$importLibraries = @()
if ($optional.ContainsKey($importsKey)) {
    $importsOffset = [int]$optional[$importsKey]
    $importsSize = Read-Be32 $bytes $importsOffset
    $stringTableSize = Read-Be32 $bytes ($importsOffset + 4)
    $stringCount = Read-Be32 $bytes ($importsOffset + 8)
    $strings = @()
    $cursor = $importsOffset + 12
    for ($index = 0; $index -lt $stringCount; $index++) {
        $start = $cursor
        while ($cursor -lt $bytes.Length -and $bytes[$cursor] -ne 0) { $cursor++ }
        $strings += [System.Text.Encoding]::ASCII.GetString($bytes, $start, $cursor - $start)
        $cursor++
        while ((($cursor - ($importsOffset + 12)) % 4) -ne 0) { $cursor++ }
    }

    $libraryOffset = $stringTableSize + 12
    while ($libraryOffset -lt $importsSize) {
        $absoluteOffset = $importsOffset + $libraryOffset
        $librarySize = Read-Be32 $bytes $absoluteOffset
        if ($librarySize -eq 0) { break }
        $nameIndex = (Read-Be16 $bytes ($absoluteOffset + 0x24)) -band 0xFF
        $symbolCount = Read-Be16 $bytes ($absoluteOffset + 0x26)
        $name = if ($nameIndex -lt $strings.Count) { $strings[$nameIndex] } else { '<invalid>' }
        $importLibraries += [ordered]@{ name = $name; symbolCount = $symbolCount }
        $importLibraryCount++
        $importSymbolCount += $symbolCount
        $libraryOffset += $librarySize
    }
}

$metadata = [ordered]@{
    schemaVersion = 1
    fileName = $item.Name
    sizeBytes = $item.Length
    sha256 = $hash.Hash.ToLowerInvariant()
    titleId = ('{0:X8}' -f (Read-Be32 $bytes ($executionOffset + 0x0C)))
    mediaId = ('{0:X8}' -f (Read-Be32 $bytes $executionOffset))
    version = "$versionMajor.$versionMinor.$versionBuild.$versionQfe"
    imageBase = ('0x{0:X8}' -f $optional[$imageBaseKey])
    entryPoint = ('0x{0:X8}' -f $optional[$entryKey])
    optionalHeaderCount = $headerCount
    imageSizeBytes = Read-Be32 $bytes ($securityOffset + 4)
    imageFlags = ('0x{0:X8}' -f (Read-Be32 $bytes ($securityOffset + 0x10C)))
    regionFlags = ('0x{0:X8}' -f (Read-Be32 $bytes ($securityOffset + 0x178)))
    encryption = if ($encryptionValue -lt $encryptionNames.Count) { $encryptionNames[$encryptionValue] } else { "unknown-$encryptionValue" }
    compression = if ($compressionValue -lt $compressionNames.Count) { $compressionNames[$compressionValue] } else { "unknown-$compressionValue" }
    pageDescriptorCount = $pageDescriptorCount
    totalImagePages = $totalPages
    sectionDescriptorCounts = $sectionCounts
    importLibraryCount = $importLibraryCount
    importSymbolCount = $importSymbolCount
    importLibraries = $importLibraries
}

$outputFullPath = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $OutputPath))
New-Item -ItemType Directory -Path (Split-Path -Parent $outputFullPath) -Force | Out-Null
$metadata | ConvertTo-Json | Set-Content -LiteralPath $outputFullPath -Encoding utf8
$metadata | Format-List
