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
$skillRegistryPath = Join-Path $teamPath 'SKILL_REGISTRY.md'
$researchNotesPath = Join-Path $teamPath 'RESEARCH_NOTES'
$researchReadmePath = Join-Path $researchNotesPath 'README.md'
$qualityGatesPath = Join-Path $teamPath 'QUALITY_GATES.md'

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
skill_discovery_policy: suggest-only; Lead reviews every candidate; no automatic global installation
research_policy: research-first for design, UX, content, user flows, new architecture/libraries, security, performance, and significant integrations; use evidence, do not copy third-party work
quality_policy: every task has observable acceptance evidence; use the matching project checklist before DONE
preview_policy: ask for a short user decision before a new user-facing page, material UI/UX redesign, navigation change, or user-flow direction unless the user asks for direct implementation
delegation_policy: Leads have zero delivery/research tasks; every meaningful web/document search, filesystem scan, analysis, code, test, configuration, documentation, asset, or output belongs to a visible Orca worker terminal, except pure status, clarification, policy, or one-sentence answer
user_language_policy: Root Lead normally talks to the user; any agent directly addressed by the user uses short plain Vietnamese and explains unavoidable technical terms immediately
audit_policy: $lead audit is read-only and checks that meaningful changes have visible worker ownership; Git inspection requires separate user approval

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

## Skill Discovery Gate

At task intake, the Lead checks already available skills and `.orca-team/SKILL_REGISTRY.md` before searching externally. Search is warranted only for a genuinely specialized capability that is material to the accepted task. Workers may request a capability but may not search, download, install, execute, or enable an external skill themselves.

The default mode is `suggest-only`: the Lead may research and record candidates, but must ask the user before downloading, installing, enabling, or running any newly discovered skill. A user may opt in per project to `trusted-instruction-only`; even then, a Lead may only prepare a project-local, instruction-only candidate from a reputable source after reading it completely. Scripts, hooks, credentials, external upload, deployment, database operations, Git operations, or unclear source always require separate user approval. Never auto-install skills globally for the user.

Every candidate and decision is recorded in `SKILL_REGISTRY.md`. If a recurring project capability has no trustworthy candidate, create or improve a project-local internal reference/skill after the normal project approval boundaries; do not keep searching endlessly.

## Research-first Gate

The Lead labels each task `routine`, `research-first`, or `research-deep` before implementation. `research-first` is required for UI/UX, visual design, copy/content, user flows, product experience, new libraries/frameworks, architecture choices, security, performance, and significant integrations. A short, bounded research brief must state the decision question, local context, trusted sources, findings, and project-specific decision before a writer begins the affected work. `research-deep` is reserved for a decision with broader cost, safety, or product impact and needs an explicit evidence plan.

Use project conventions, official documentation, standards, and a small number of relevant public examples. Learn principles; do not copy third-party code, designs, assets, or text. Never send private code, credentials, customer data, or raw production logs to a search service. Store reusable brief summaries in `.orca-team/RESEARCH_NOTES/`; the brief is internal coordination, not permission for Git, database, deployment, or external changes.

## Quality and Preview Gates

Every task chooses the relevant checklist from `QUALITY_GATES.md` and writes the required evidence into its Task Contract. Code changes and worker claims are not acceptance evidence by themselves. The Lead verifies the evidence before reporting a task done.

Before a new user-facing page, material redesign, navigation change, or user-flow direction, the Lead gives the user a short preview: goal, proposed structure/behavior, alternatives if they matter, desktop/mobile/state impact, and the single decision needed. Implementation that would lock in that decision waits for the user's answer unless the user explicitly asks to implement directly. Minor visual adjustments and clear maintenance changes do not need a preview.

## Delegation and user language

Root and Domain Leads own intake, prioritization, worker scheduling, decisions, verification, and reporting. They have zero research or delivery tasks: they do not search the web, scan files, run long commands, debug, write code/tests/configuration/documentation/assets, or create other project deliverables in their Lead terminal. Each meaningful research or project task belongs to one concrete worker task. Related tiny changes may be grouped under one worker. Status, a clarification, a project rule, or a one-sentence answer does not need a worker.

A worker is active only after Orca returns its live Task/Dispatch and terminal handle, its terminal has the correct role label, and the dashboard records it. If launch fails, the Lead leaves the work queued or blocked and tells the user; it never takes over research or implementation silently.

Root Lead normally speaks to the user. If a user directly talks to any other Lead, QA, or worker, that agent uses short plain Vietnamese, starts with the practical result, explains a necessary technical word immediately, and avoids internal task IDs, agent names, models, terminals, commands, and logs unless the user asks.

## Delegation audit

`$lead audit` is a read-only check of the task board, dashboard, task contracts, and live Orca inventory. It confirms that every meaningful research or project change has a visible worker owner and that Leads remain coordinators. It does not launch, stop, or replace workers; it does not edit delivery files; and it does not use Git unless the user separately approves Git inspection. A gap is recorded and reported plainly instead of being silently fixed by a Lead doing the task itself.

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

if (-not (Test-Path -LiteralPath $skillRegistryPath)) {
    $skillRegistryContents = @'
# Skill Registry

Last updated: not yet hydrated
Mode: suggest-only

The Lead checks this registry and already available Codex skills before looking outside. A worker may request a capability but may not download, install, enable, or run an external skill. In `suggest-only` mode, the Lead asks the user before any newly found skill is downloaded, enabled, or executed. `trusted-instruction-only` is an explicit per-project opt-in and still prohibits scripts, hooks, credentials, external upload, Git, database, deployment, and unknown sources without separate user approval.

## Records

| ID | Capability / skill | Source and reputation checked | Needed by | Risk check | Permission needed | Status | Decision / evidence |
|---|---|---|---|---|---|---|---|

Status: `candidate`, `approved`, `active`, `rejected`, `retired`.

## Record details

Add a short block only when the table cannot explain the decision:

```text
### SK-001 — <skill or capability>
Source: <publisher/repository/URL>
Reason: <what task it helps>
Checks: <publisher, adoption, repository review, full SKILL.md/references/scripts review>
Contains: <instructions only | scripts | hooks | dependencies>
Data and permissions: <none or exact external access/credential/change>
Scope: <one task | this project>
Decision: <why approved/rejected and who approved it>
```
'@
    [System.IO.File]::WriteAllText($skillRegistryPath, $skillRegistryContents, (New-Object System.Text.UTF8Encoding($false)))
}

if (-not (Test-Path -LiteralPath $researchNotesPath)) {
    [System.IO.Directory]::CreateDirectory($researchNotesPath) | Out-Null
}

if (-not (Test-Path -LiteralPath $researchReadmePath)) {
    $researchReadmeContents = @'
# Research Notes

This folder keeps short, reusable research briefs. A brief gives the next Lead or worker the evidence and decision they need; it is not a copied web article or a place for private data.

## When a brief is required

The Lead creates or assigns a brief before implementation when a task is marked `research-first` or `research-deep`:

- UI/UX, visual design, responsive behaviour, accessibility, content/copy, user flows, or product experience;
- new framework/library or architecture choice;
- security, performance, significant integration, payment, identity, or other high-impact decision;
- an unclear task where current evidence would materially change the direction.

Routine bug fixes and clearly bounded implementation do not need a brief merely to satisfy process.

## Brief template

Use a small file named `RN-###-short-topic.md`:

```markdown
# RN-### — <topic>

Question: <decision this research must support>
Scope: <task/module; what is outside scope>
Local context: <relevant project paths and constraints>
Sources checked: <official docs, standards, and a small number of public examples>
Findings: <short facts/principles, not copied material>
Options considered: <option and trade-off>
Decision for this project: <chosen approach and why>
Acceptance impact: <what the implementation/QA must verify>
Skill decision: <none | existing skill/path | SK-### candidate>
Data/IP boundary: <no private data shared; principles only, no copied code/assets/text>
Date / owner: <date and Lead or research task owner>
```

## Levels

- `routine`: no brief unless a real question appears.
- `research-first`: a focused brief, usually enough to choose a direction safely.
- `research-deep`: a written evidence plan and comparative brief before a high-cost or high-risk decision.

Do not browse endlessly. Stop when the brief answers the decision question with enough current, trustworthy evidence. If evidence is inadequate or needs an external paid/login source, report the gap to the Lead and let the user decide.
'@
    [System.IO.File]::WriteAllText($researchReadmePath, $researchReadmeContents, (New-Object System.Text.UTF8Encoding($false)))
}

if (-not (Test-Path -LiteralPath $qualityGatesPath)) {
    $qualityGatesContents = @'
# Quality Gates

The Lead chooses only the checklists that match a task. Put concrete evidence in the Task Contract; do not require irrelevant checks just to complete a template.

## API / backend change

- Request, response, status/error behavior, validation, authorization, and idempotency/state rules are clear where relevant.
- Public API contract/docs/examples are updated when the endpoint or DTO is public.
- Focused automated tests pass, or the brief says why a test cannot run and gives a safe manual check.
- Existing clients stay compatible, or the BE/FE contract records the coordinated breaking change.

## UI / UX change

- Matches the accepted preview/research decision and existing project design conventions.
- Works at the agreed desktop and mobile sizes.
- Covers loading, empty, error, disabled, and long-content states that are relevant.
- Keyboard, readable labels, focus, contrast, and semantic structure are checked where applicable.
- Screenshot/visual check and focused test or manual steps are recorded.

## Data / migration / state change

- State transitions, validation, null/legacy data, and failure/rollback behavior are defined.
- Migration/seed/backfill scope and compatibility are reviewed if applicable.
- No shared database change runs without the separate user approval required by TEAM_POLICY.

## Integration / cross-project change

- Lead-to-Lead contract records fields, permissions, errors, states, nullable behavior, and acceptance smoke test.
- One side does not claim the integration complete until the other side confirms the contract or agreed mock/fixture behavior.
- Secrets, tokens, private URLs, and raw customer/production data are excluded from messages and test evidence.

## Research / review task

- The brief/review names the question, sources or inspected paths, evidence, conclusion, and action/decision.
- It clearly separates facts, assumptions, and recommendations.
- It changes no files outside its allowed read-only/output scope.

## Preview format

For a user-review-required change, the Lead asks in simple language:

```text
Mục tiêu: <what improves for the user>
Đề xuất: <short layout/flow/behavior>
Trên mobile và các trạng thái: <important change>
Lựa chọn cần bạn chốt: <one direct choice, or “đồng ý hướng này”>
```

Record the answer as `PV-###` in TEAM_STATE.md and the Task Contract. A preview confirms direction; it does not authorize unrelated Git, database, deployment, or external changes.
'@
    [System.IO.File]::WriteAllText($qualityGatesPath, $qualityGatesContents, (New-Object System.Text.UTF8Encoding($false)))
}

[pscustomobject]@{
    project = $resolvedProjectPath
    teamDirectory = $teamPath
    policy = $policyPath
    rules = $rulesPath
    state = $statePath
    lease = $leasePath
    dashboard = $dashboardPath
    skillRegistry = $skillRegistryPath
    researchNotes = $researchNotesPath
    qualityGates = $qualityGatesPath
} | ConvertTo-Json -Depth 3
