param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^(xstart|sub_[0-9A-Fa-f]{8})$')]
    [string]$RootFunction,

    [ValidateRange(0, 8)]
    [int]$Depth = 2,

    [string]$GeneratedPath = 'manifests/local/bootstrap/generated/default'
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$generated = Join-Path $root $GeneratedPath
if (-not (Test-Path -LiteralPath $generated -PathType Container)) {
    throw "Generated output directory not found: $generated"
}

$graph = @{}
$current = $null
$functionPattern = '^DEFINE_REX_FUNC\((xstart|sub_[0-9A-F]+)\)'
$callPattern = '^\s*(sub_[0-9A-F]+|__imp__[A-Za-z0-9_]+|rexcrt_[A-Za-z0-9_]+)\(ctx, base\);'

foreach ($file in Get-ChildItem -LiteralPath $generated -Filter 'doax2_recomp.*.cpp') {
    foreach ($line in [System.IO.File]::ReadLines($file.FullName)) {
        if ($line -match $functionPattern) {
            $current = $Matches[1]
            if (-not $graph.ContainsKey($current)) {
                $graph[$current] = [System.Collections.Generic.HashSet[string]]::new()
            }
            continue
        }

        if ($current -and $line -match $callPattern) {
            [void]$graph[$current].Add($Matches[1])
        }
    }
}

if (-not $graph.ContainsKey($RootFunction)) {
    throw "Function not found in generated output: $RootFunction"
}

$queue = [System.Collections.Generic.Queue[object]]::new()
$queue.Enqueue([pscustomobject]@{ Function = $RootFunction; Level = 0 })
$visited = @{}

while ($queue.Count -ne 0) {
    $item = $queue.Dequeue()
    $function = [string]$item.Function
    $level = [int]$item.Level
    if ($visited.ContainsKey($function) -and $visited[$function] -le $level) {
        continue
    }
    $visited[$function] = $level

    $indent = '  ' * $level
    Write-Output "$indent$function"

    if ($level -ge $Depth -or -not $graph.ContainsKey($function)) {
        continue
    }

    foreach ($callee in $graph[$function] | Sort-Object) {
        if ($callee -like 'sub_*') {
            $queue.Enqueue([pscustomobject]@{ Function = $callee; Level = $level + 1 })
        } else {
            Write-Output "$indent  $callee"
        }
    }
}
