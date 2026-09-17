[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath
)

$resolvedProjectPath = (Resolve-Path -LiteralPath $ProjectPath -ErrorAction Stop).Path
$teamPath = Join-Path $resolvedProjectPath '.orca-team'
$requiredFiles = @(
    'TEAM_POLICY.md',
    'TEAM_RULES.md',
    'TEAM_STATE.md',
    'LEAD_LEASE.md',
    'TEAM_DASHBOARD.md',
    'QUALITY_GATES.md',
    'MODEL_POLICY.md',
    'MODEL_STATUS.md',
    'PROJECT_HOOKS.md'
)

$errors = [System.Collections.Generic.List[string]]::new()
$warnings = [System.Collections.Generic.List[string]]::new()

if (-not (Test-Path -LiteralPath $teamPath -PathType Container)) {
    $errors.Add('Missing .orca-team. Run bootstrap-project.ps1 first.')
}

foreach ($fileName in $requiredFiles) {
    $path = Join-Path $teamPath $fileName
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        $errors.Add("Missing $fileName")
    }
}

if ($errors.Count -eq 0) {
    $modelPolicy = Get-Content -Raw -Encoding utf8 (Join-Path $teamPath 'MODEL_POLICY.md')
    $modelStatus = Get-Content -Raw -Encoding utf8 (Join-Path $teamPath 'MODEL_STATUS.md')
    $hooks = Get-Content -Raw -Encoding utf8 (Join-Path $teamPath 'PROJECT_HOOKS.md')

    if ($modelPolicy -notmatch '(?m)^Revision:\s*\S+') {
        $errors.Add('MODEL_POLICY.md has no Revision.')
    }

    foreach ($route in @('big-lead', 'domain-lead', 'difficult-worker', 'normal-worker', 'quick-worker', 'final-review')) {
        if ($modelPolicy -notmatch [regex]::Escape("| $route |")) {
            $errors.Add("MODEL_POLICY.md is missing route $route.")
        }
    }

    if ($modelStatus -notmatch '(?m)^Policy revision.*?:\s*\S+') {
        $errors.Add('MODEL_STATUS.md has no checked policy revision.')
    }
    elseif ($modelStatus -match '(?m)^Policy revision.*?:\s*(unverified|unknown|none)') {
        $warnings.Add('Models have not been checked. Do not launch model-routed tasks before $lead models validate.')
    }

    if ($modelStatus -notmatch '\|\s*[^|]+\s*\|\s*[^|]+\s*\|\s*verified\s*\|') {
        $warnings.Add('No verified model appears in MODEL_STATUS.md. Keep model-routed tasks QUEUED or WAITING_USER.')
    }

    foreach ($eventName in @('before_worker_launch', 'before_done')) {
        if ($hooks -notmatch [regex]::Escape("Event: $eventName")) {
            $errors.Add("PROJECT_HOOKS.md is missing hook $eventName.")
        }
    }

}

[pscustomobject]@{
    project = $resolvedProjectPath
    valid = $errors.Count -eq 0
    readyToLaunchModelRoutedTasks = $errors.Count -eq 0 -and $warnings.Count -eq 0
    errors = @($errors)
    warnings = @($warnings)
} | ConvertTo-Json -Depth 3

if ($errors.Count -gt 0) {
    exit 1
}
