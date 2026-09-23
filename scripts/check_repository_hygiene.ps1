$ErrorActionPreference = 'Stop'

$forbiddenPatterns = @(
    '(^|/)(build|out|game|game_data|extracted|disc|content|generated|recompiled|ppc|dlc|title_updates|evidence/local|manifests/local)/',
    '(^|/)tools/(extract-xiso|rexglue-sdk|XenonRecomp)/',
    '\.(iso|xex|xexp|zar|pak|wad|bin|data|xma|xma2|dxbc|dxil|spv|dmp|etl|trace|exe|dll|pdb|obj|lib)$',
    '(shader|pipeline)[_-]?cache',
    'switch[_-]?tables?\.(toml|json|txt)$'
)

$tracked = @(git ls-files)
if ($LASTEXITCODE -ne 0) {
    throw 'Unable to enumerate tracked files.'
}

$violations = [System.Collections.Generic.List[string]]::new()
foreach ($path in $tracked) {
    $normalized = $path.Replace('\', '/')
    foreach ($pattern in $forbiddenPatterns) {
        if ($normalized -imatch $pattern) {
            $violations.Add("Forbidden tracked path: $path")
            break
        }
    }

    if (Test-Path -LiteralPath $path -PathType Leaf) {
        $item = Get-Item -LiteralPath $path
        if ($item.Length -gt 2MB) {
            $violations.Add("Tracked file exceeds the 2 MiB review limit: $path ($($item.Length) bytes)")
        }

        $bytes = [System.IO.File]::ReadAllBytes($item.FullName)
        if ($bytes.Length -ge 4) {
            $ascii4 = [System.Text.Encoding]::ASCII.GetString($bytes, 0, 4)
            if ($ascii4 -eq 'XEX2') {
                $violations.Add("Tracked file has an XEX2 header: $path")
            }
        }
    }
}

$sensitivePatterns = @(
    '[A-Za-z]:[\\/]+Users[\\/]+',
    'BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY',
    '(?i)(password|passwd|secret|api[_-]?key|access[_-]?token)\s*[:=]\s*[^\s$]'
)

foreach ($pattern in $sensitivePatterns) {
    $hits = @(git grep -n -I -E $pattern -- 2>$null)
    if ($LASTEXITCODE -eq 0) {
        foreach ($hit in $hits) {
            $violations.Add("Sensitive text pattern: $hit")
        }
    }
}

if ($violations.Count -ne 0) {
    $violations | ForEach-Object { Write-Error $_ }
    throw "Repository hygiene check failed with $($violations.Count) violation(s)."
}

Write-Host "Repository hygiene check passed for $($tracked.Count) tracked files."

