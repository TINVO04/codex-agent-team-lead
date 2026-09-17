# Project team state schema

`TEAM_STATE.md` is local durable coordination state under `.orca-team/`. It is not a source-of-truth for live Orca terminal identity; reconcile it with Orca after restart.

```markdown
# Team State

Last updated: <ISO 8601 local time>
Project: <name>
Lead mode: <active | recovering | idle>
Orca Run: <run ID or unbound>
Lead terminal: <live handle or unbound>

## Current objective

<one current objective or none>

## Active team rules

| Rule ID | Short rule | Scope | Affected tasks / owners | Evidence required | Acknowledgement |
|---|---|---|---|---|---|

The full wording and history belong in `TEAM_RULES.md`. Record every active-rule change here so the Root Lead can see who must acknowledge it.

## Task board

| ID | Request | Priority | Status | Owner | Ownership zone | Depends on | Acceptance evidence | Notes |
|---|---|---|---|---|---|---|---|---|
| T-001 | ... | P1 | READY | API | src/... | — | dotnet test ... | ... |

Status: `INTAKE`, `READY`, `QUEUED`, `ACTIVE`, `VERIFYING`, `BLOCKED`, `WAITING_USER`, `DONE`, `FAILED`, `CANCELLED`.

## Team topology and capacity

| Team / domain | Lead | Allocated capacity | Owned task IDs | State | Collapse condition |
|---|---|---:|---|---|---|
| Root | <handle or unbound> | <global max> | ... | active | never during current request |

Do not count capacity per row. The sum of all active workers must remain within the global `max_workers` policy.

## Active assignments

| Task | Attempt | Dispatch | Terminal | Requested / effective model / effort | Checkpoint | Last known result |
|---|---:|---|---|---|---|---|

Only enter IDs returned by the current live Orca runtime. On restart, change an assignment to `RECOVERY_REQUIRED` until live inventory verifies it.

## Model routing and recovery

| Role / task | Attempt | Requested model / effort | Effective model / effort | Fallback order | Failure evidence | Recovery decision |
|---|---:|---|---|---|---|---|

Do not retry a model failure from missing or unknown status. Keep the ownership reservation until the failed/stopped state, files, and replacement path are verified. A replacement uses the same task ID and is the only writer for that ownership zone.

## Active ownership and Parallel Gate

| Task | Ownership zone / shared resource | Parallel Gate | Reserved until | Conflict / contract |
|---|---|---|---|---|

Record an ownership reservation before dispatching a writer. Use `pass`, `hard dependency`, `ownership conflict`, or `contract-first` as the gate result.

## Decisions and contracts

| ID | Decision / contract | Owner | Affected tasks | Date |
|---|---|---|---|---|

## Blockers and user approvals

| Task | Blocker or approval needed | Since | Next owner |
|---|---|---|---|
```

Keep the task board short. Preserve completed task rows only while they explain a dependency, verification result, or later recovery decision.
