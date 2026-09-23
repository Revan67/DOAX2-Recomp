param(
    [string]$RexgluePath = 'tools/rexglue-sdk/out/win-amd64/Release/rexglue.exe',
    [string]$ManifestPath = 'manifests/local/bootstrap/doax2_manifest.toml',
    [string]$GeneratedPath = 'manifests/local/bootstrap/generated/default',
    [string]$LogPath = 'evidence/local/phase3/strict-verification.log'
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$rexglue = Join-Path $root $RexgluePath
$manifest = Join-Path $root $ManifestPath
$generated = Join-Path $root $GeneratedPath
$log = Join-Path $root $LogPath

foreach ($required in @($rexglue, $manifest)) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
        throw "Required local input not found: $required"
    }
}

New-Item -ItemType Directory -Path (Split-Path -Parent $log) -Force | Out-Null

& $rexglue --log-level info --log-file $log codegen --ignore-stamp $manifest
if ($LASTEXITCODE -ne 0) {
    throw "Strict ReXGlue code generation failed with exit code $LASTEXITCODE."
}

if (-not (Test-Path -LiteralPath $generated -PathType Container)) {
    throw "Generated output directory not found: $generated"
}

$markers = @(
    'FATAL: unresolved',
    'Unresolved call',
    'Unresolved function',
    'unsupported instruction',
    'REX_FATAL'
)

$generatedFiles = @(Get-ChildItem -LiteralPath $generated -Recurse -File |
    Where-Object { $_.Extension -in @('.cpp', '.h') })
$violations = [System.Collections.Generic.List[string]]::new()

foreach ($file in $generatedFiles) {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    foreach ($marker in $markers) {
        if ($text.IndexOf($marker, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            $violations.Add("$($file.FullName): $marker")
        }
    }
}

if ($violations.Count -ne 0) {
    $violations | ForEach-Object { Write-Error $_ }
    throw "Generated output contains $($violations.Count) fatal or unresolved marker(s)."
}

Write-Host "Strict ReXGlue verification passed for $($generatedFiles.Count) generated source files."
