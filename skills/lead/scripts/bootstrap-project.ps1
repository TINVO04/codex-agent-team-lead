[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath
)

$resolvedProjectPath = (Resolve-Path -LiteralPath $ProjectPath -ErrorAction Stop).Path
$teamPath = Join-Path $resolvedProjectPath '.orca-team'
[System.IO.Directory]::CreateDirectory($teamPath) | Out-Null

$policyPath = Join-Path $teamPath 'TEAM_POLICY.md'
$rulesPath = Join-Path $teamPath 'TEAM_RULES.md'
$statePath = Join-Path $teamPath 'TEAM_STATE.md'
$leasePath = Join-Path $teamPath 'LEAD_LEASE.md'
$dashboardPath = Join-Path $teamPath 'TEAM_DASHBOARD.md'

if (-not (Test-Path -LiteralPath $policyPath)) {
    $policyContents = @'
# Team Policy

max_workers: 3
max_hierarchy_depth: 2
default_priority: P1
scaling_policy: parallel-first with ownership and dependency gates
git_policy: all Git operations require explicit user approval
database_policy: shared database changes require explicit user approval
service_policy: service restart or deployment requires explicit user approval
cross_project_policy: Lead-to-Lead contract required before implementation
terminal_policy: Orca runtime is required; retained terminals may disappear after Orca restart; recover from live inventory
lead_identity_policy: one active Big Lead per project; second terminals are viewers until verified recovery or explicit user takeover

## Roles

1. Lead: intake, scheduling, decision log, verification, integration planning.
2. API / implementation: assigned module or service changes.
3. QA / integration: test evidence and smoke-test contracts.
4. Reviewer: independent read-only review unless a fix is explicitly assigned.

## Queue rule

New work is recorded before dispatch. It does not cancel active work unless the Lead marks it P0 and redirects workers at a safe checkpoint.

## Parallel rule

Before dispatching a writer, record whether the Parallel Gate passed, has a hard dependency, has an ownership conflict, or needs a contract first. Group small related work by module/context. The global worker limit applies across every optional Domain Lead.

## Rule authority

User instructions and this policy cannot be weakened. The Root Lead may record project rules in TEAM_RULES.md and must include applicable rule IDs in task contracts. Domain Leads may propose rules; workers follow them or report a blocker. Rules never grant Git, database, service, deployment, or external-change authority.

## User report rule

Agents may use technical detail internally. When the Root Lead reports to the user, it starts with a simple completed, working, or blocked status in the user's language; explains only the result, verification, blocker, or direct decision needed in plain language; and omits task IDs, agent names, terminals, long logs, and internal planning unless the user asks.

## Model policy

Root Lead and Domain Lead: gpt-5.6-terra with xhigh effort. Lead fallback: qwen3.8-max-0902.

Worker routes:
- difficult work: qwen3.8-max-0902 with high effort, then deepseek-v4.1-flash, then glm-5.3-flash.
- normal work: deepseek-v4.1-flash with medium effort, then qwen3.8-max-0902, then glm-5.3-flash.
- quick work: glm-5.3-flash with low effort, then deepseek-v4.1-flash, then qwen3.8-max-0902.
- final review: qwen3.8-max-0902 with high effort, then deepseek-v4.1-flash, then glm-5.3-flash.

Before launch, record requested model, runtime-confirmed effective model, effort, and fallback order. An unknown/disconnected worker is not a failed model. Inspect it before retrying. If a worker may have changed files, preserve its ownership reservation and recover the same task with one permitted fallback only after failure is proven. In Orca, the replacement starts a fresh Codex worker on the same Task using the failed Dispatch as retry evidence; do not reuse a failing terminal or run two writers. If every permitted model fails or is unavailable, wait for a user model decision. A failed Root Lead must be replaced by its supervising caller using the saved project state.

## Big Lead identity and visibility

Only one active Big Lead owns the project queue and may dispatch workers. The terminal that creates the active lease uses `00 | BIG | <project> | RUN`. A second terminal opening the same project is a viewer until the live Big Lead gives it a bounded role, or verified recovery/explicit user takeover transfers the lease. Use `.orca-team/TEAM_DASHBOARD.md` and role labels to show who owns each worker. A terminal title is for people to read; live Orca worker state remains the authority for liveness and recovery.
'@
    [System.IO.File]::WriteAllText($policyPath, $policyContents, (New-Object System.Text.UTF8Encoding($false)))
}

if (-not (Test-Path -LiteralPath $rulesPath)) {
    $rulesContents = @'
# Team Rules

Last updated: not yet hydrated

## How rules work

The Root Lead records project/domain/task rules here when the user gives a clear instruction that affects more than one task or owner. User instructions and TEAM_POLICY.md always win. A rule cannot authorize Git, database, restart, deployment, remote permission, or other external work.

Before a worker starts and before the Lead accepts DONE, the Task Contract lists the applicable rule IDs and required evidence. A running worker acknowledges a changed rule at its next safe checkpoint.

## Active rules

No active rules yet.

## Retired rules

No retired rules yet.
'@
    [System.IO.File]::WriteAllText($rulesPath, $rulesContents, (New-Object System.Text.UTF8Encoding($false)))
}

if (-not (Test-Path -LiteralPath $statePath)) {
    $stateContents = @'
# Team State

Last updated: not yet hydrated
Project: pending discovery
Lead mode: idle
Orca Run: unbound
Lead terminal: unbound
Big Lead label: unassigned
Lead lease: UNASSIGNED

## Current objective

None

## Active team rules

| Rule ID | Short rule | Scope | Affected tasks / owners | Evidence required | Acknowledgement |
|---|---|---|---|---|---|

## Task board

| ID | Request | Priority | Status | Owner | Ownership zone | Depends on | Acceptance evidence | Notes |
|---|---|---|---|---|---|---|---|---|

## Team topology and capacity

| Team / domain | Lead label | Parent | Allocated capacity | Owned task IDs | State | Collapse condition |
|---|---|---|---:|---|---|---|

## Active assignments

| Task | Role label | Parent label | Attempt | Dispatch | Terminal | Requested / effective model / effort | Checkpoint | Last known result |
|---|---|---|---:|---|---|---|---|---|

## Model routing and recovery

| Role / task | Attempt | Requested model / effort | Effective model / effort | Fallback order | Failure evidence | Recovery decision |
|---|---:|---|---|---|---|---|

## Active ownership and Parallel Gate

| Task | Ownership zone / shared resource | Parallel Gate | Reserved until | Conflict / contract |
|---|---|---|---|---|

## Decisions and contracts

| ID | Decision / contract | Owner | Affected tasks | Date |
|---|---|---|---|---|

## Blockers and user approvals

| Task | Blocker or approval needed | Since | Next owner |
|---|---|---|---|
'@
    [System.IO.File]::WriteAllText($statePath, $stateContents, (New-Object System.Text.UTF8Encoding($false)))
}

if (-not (Test-Path -LiteralPath $leasePath)) {
    $leaseContents = @'
# Big Lead Lease

State: UNASSIGNED
Big Lead label: unassigned
Mode: unbound
Orca Run: unbound
Lead terminal: unbound
Started: not yet hydrated
Last confirmed: not yet hydrated

Only the active Big Lead may schedule workers. A second terminal is a viewer until verified recovery or explicit user takeover transfers this lease.
'@
    [System.IO.File]::WriteAllText($leasePath, $leaseContents, (New-Object System.Text.UTF8Encoding($false)))
}

if (-not (Test-Path -LiteralPath $dashboardPath)) {
    $dashboardContents = @'
# Team Dashboard

Last updated: not yet hydrated
Project: pending discovery

No Big Lead has claimed this project yet.

## Quick reading

| Label | Owner / task | State | Next checkpoint |
|---|---|---|---|
'@
    [System.IO.File]::WriteAllText($dashboardPath, $dashboardContents, (New-Object System.Text.UTF8Encoding($false)))
}

[pscustomobject]@{
    project = $resolvedProjectPath
    teamDirectory = $teamPath
    policy = $policyPath
    rules = $rulesPath
    state = $statePath
    lease = $leasePath
    dashboard = $dashboardPath
} | ConvertTo-Json -Depth 3
