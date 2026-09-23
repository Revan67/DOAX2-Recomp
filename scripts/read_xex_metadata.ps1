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
if (-not $optional.ContainsKey($entryKey) -or -not $optional.ContainsKey($imageBaseKey) -or
    -not $optional.ContainsKey($executionKey)) {
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
}

$outputFullPath = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $OutputPath))
New-Item -ItemType Directory -Path (Split-Path -Parent $outputFullPath) -Force | Out-Null
$metadata | ConvertTo-Json | Set-Content -LiteralPath $outputFullPath -Encoding utf8
$metadata | Format-List

