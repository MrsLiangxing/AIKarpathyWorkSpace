[CmdletBinding()]
param([switch]$NoReport)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$wikiRoot = Join-Path $repoRoot 'wiki'
$issues = [System.Collections.Generic.List[object]]::new()

function Add-Issue {
    param([string]$Level, [string]$File, [string]$Message)
    $issues.Add([pscustomobject]@{ Level = $Level; File = $File; Message = $Message })
}
function Get-RelativePath([string]$Path) {
    return $Path.Substring($repoRoot.Length + 1).Replace('\', '/')
}

$allFiles = Get-ChildItem -Path $wikiRoot -Filter '*.md' -File -Recurse
$pageFiles = $allFiles | Where-Object {
    $relative = Get-RelativePath $_.FullName
    $relative -ne 'wiki/index.md' -and $relative -ne 'wiki/log.md' -and $relative -notlike 'wiki/_meta/*'
}
$lookup = @{}
foreach ($file in $pageFiles) {
    $key = ((Get-RelativePath $file.FullName) -replace '^wiki/', '' -replace '\.md$', '')
    $lookup[$key] = $file
}
foreach ($file in $pageFiles) {
    $relative = Get-RelativePath $file.FullName
    $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding utf8
    if (-not $content.StartsWith('---')) {
        Add-Issue 'ERROR' $relative 'Missing YAML frontmatter.'
        continue
    }
    $frontMatterEnd = $content.IndexOf(([char]10 + '---'), 3)
    if ($frontMatterEnd -lt 0) {
        Add-Issue 'ERROR' $relative 'Unclosed YAML frontmatter.'
        continue
    }
    $frontMatter = $content.Substring(0, $frontMatterEnd + 4)
    foreach ($field in @('title:', 'type:', 'status:', 'created:', 'updated:', 'sources:', 'tags:')) {
        if ($frontMatter -notmatch "(?m)^$([regex]::Escape($field))") {
            Add-Issue 'ERROR' $relative "Missing frontmatter field: $field"
        }
    }
    if ($frontMatter -match '(?m)^type:\s*(.+)$' -and $Matches[1].Trim() -notin @('source','concept','entity','project','analysis','overview')) {
        Add-Issue 'WARNING' $relative 'Unrecognized type.'
    }
    if ($frontMatter -match '(?m)^status:\s*(.+)$' -and $Matches[1].Trim() -notin @('draft','active','superseded')) {
        Add-Issue 'WARNING' $relative 'Unrecognized status.'
    }
    foreach ($match in [regex]::Matches($content, '\[\[([^\]|#]+)')) {
        $target = $match.Groups[1].Value.Trim().TrimStart('/') -replace '\.md$', ''
        if ($target -and -not $lookup.ContainsKey($target)) {
            Add-Issue 'WARNING' $relative "Missing internal-link target: [[$target]]"
        }
    }
}
$index = Get-Content -LiteralPath (Join-Path $wikiRoot 'index.md') -Raw -Encoding utf8
foreach ($key in $lookup.Keys) {
    if ($index -notmatch [regex]::Escape("[[$key")) {
        Add-Issue 'WARNING' 'wiki/index.md' "Page not listed in index: [[$key]]"
    }
}
foreach ($sourceFile in Get-ChildItem -Path (Join-Path $wikiRoot 'sources') -Filter '*.md' -File) {
    $content = Get-Content -LiteralPath $sourceFile.FullName -Raw -Encoding utf8
    $relative = Get-RelativePath $sourceFile.FullName
    if ($content -notmatch '(?m)^raw_path:\s*(.+)$') {
        Add-Issue 'ERROR' $relative 'Source note is missing raw_path.'
    } else {
        $rawPath = $Matches[1].Trim().Trim([char]34, [char]39)
        if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $rawPath))) {
            Add-Issue 'ERROR' $relative "raw_path does not exist: $rawPath"
        }
    }
}
$errors = @($issues | Where-Object Level -eq 'ERROR').Count
$warnings = @($issues | Where-Object Level -eq 'WARNING').Count
Write-Host "Knowledge-base lint: $errors error(s), $warnings warning(s)."
foreach ($issue in $issues) { Write-Host ("[{0}] {1} - {2}" -f $issue.Level, $issue.File, $issue.Message) }

if (-not $NoReport) {
    $reportsDir = Join-Path $repoRoot 'reports'
    New-Item -ItemType Directory -Force -Path $reportsDir | Out-Null
    $reportPath = Join-Path $reportsDir ("lint-" + (Get-Date -Format 'yyyy-MM-dd-HHmmss') + '.md')
    $lines = @('# Lint report', '', "- Run: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss K')", "- Errors: $errors", "- Warnings: $warnings", '')
    foreach ($issue in $issues) { $lines += "- $($issue.Level): $($issue.File): $($issue.Message)" }
    if ($issues.Count -eq 0) { $lines += '- No structural issues found.' }
    Set-Content -LiteralPath $reportPath -Value $lines -Encoding utf8
    Write-Host "Report: $(Get-RelativePath $reportPath)"
}
if ($errors -gt 0) { exit 1 }
