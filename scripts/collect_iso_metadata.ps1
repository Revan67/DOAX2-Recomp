param(
    [Parameter(Mandatory = $true)]
    [string]$IsoPath,

    [string]$OutputPath = 'evidence/local/iso-metadata.json'
)

$ErrorActionPreference = 'Stop'

$resolvedIso = (Resolve-Path -LiteralPath $IsoPath).Path
$item = Get-Item -LiteralPath $resolvedIso
if ($item.PSIsContainer) {
    throw 'IsoPath must identify a file.'
}

$hash = Get-FileHash -LiteralPath $resolvedIso -Algorithm SHA256
$outputFullPath = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $OutputPath))
$outputDirectory = Split-Path -Parent $outputFullPath
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

$metadata = [ordered]@{
    schemaVersion = 1
    fileName = $item.Name
    sizeBytes = $item.Length
    sha256 = $hash.Hash.ToLowerInvariant()
    measuredAtUtc = [DateTime]::UtcNow.ToString('o')
}

$metadata | ConvertTo-Json | Set-Content -LiteralPath $outputFullPath -Encoding utf8
Write-Host "Wrote local ISO metadata to $outputFullPath"
Write-Host "SHA-256: $($metadata.sha256)"

