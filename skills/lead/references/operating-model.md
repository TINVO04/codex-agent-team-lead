# Multi-request operating model

## Intake and queue

Create a root task for every incoming request. Triage it before dispatch:

| Result | Meaning | Lead action |
|---|---|---|
| `READY` | Has scope, acceptance, no dependency, no ownership conflict | Dispatch if capacity exists; otherwise `QUEUED` |
| `QUEUED` | Valid work but no suitable worker slot | Keep ordered by priority then arrival time |
| `BLOCKED` | Real implementation dependency | Record upstream task IDs |
| `WAITING_USER` | Needs a material choice, authorization, or external state | State exact question/blocker |
| `INTAKE` | Scope still unclear | Investigate or request clarity without creating implementation workers |

A newer task does not overwrite or silently cancel a current task. Place it in the board immediately and tell the user where it landed.

For a task with an unknown cause, create a bounded read-only `research` task rather than an implementation task. Its acceptance evidence must name the observed cause, affected paths, and a proposed follow-up task. For many small related tasks, group by context affinity before assigning an owner.

When the user states a project-wide work rule, the Root Lead writes a concise active rule in `TEAM_RULES.md`, lists affected tasks/owners in `TEAM_STATE.md`, and includes the rule ID in later Task Contracts. A Domain Lead can propose a rule but may not create or retire one. Existing writers acknowledge a changed rule at a safe checkpoint before the Lead treats it as applied.

## Priority

- `P0`: production/security/data-loss blocker; may preempt queued work and asks running workers to reach a safe checkpoint.
- `P1`: user-requested feature or blocking defect; normal top priority.
- `P2`: follow-up improvement or non-blocking defect.
- `P3`: research, cleanup, optional hardening.

For equal priority, schedule the oldest `READY` task first. Do not preempt a writer based only on a newer P1 task.

## Capacity and creation

`max_workers` is the maximum number of implementation agents at one time, not a target. Default is three when one Lead has a four-slot environment. Prefer terminal reuse after a settled task. Create a new worker only when the task is `READY`, has an exclusive ownership zone, and no retained terminal is suitable.

## Delegation Gate

The Root Lead and any Domain Lead are coordinators, not hidden implementation workers. For a meaningful requested change to source, tests, configuration, documentation, assets, or generated deliverables, the Lead creates or reuses one visible Orca worker with an explicit Task Contract. A Lead may do only intake, planning, contracts, research notes, read-only inspection, verification, `.orca-team` state updates, and user reporting.

Do not create a terminal for a pure status response, a clarification, a project rule, or a one-sentence answer. For several related tiny changes, dispatch one bounded worker rather than one terminal per edit. If no worker slot, safe ownership zone, or successful Orca launch exists, keep the task `QUEUED`/`BLOCKED`. The Lead must not implement it as a silent fallback.

A dispatch counts as real only after Orca returns a live Task/Dispatch and terminal handle. Rename that terminal and enter it in `TEAM_DASHBOARD.md` immediately. If an implementation task has no visible worker terminal, treat delegation as missing and investigate it before reporting progress.

Do not run two writers in the same workspace if their allowed paths overlap. If Git worktrees are chosen for isolation, obtain any project-required Git approval before creating them.

Before serialization, try to break a fake dependency with a versioned contract, mock, fixture, stub, or test case. Record that contract in the state board and reserve shared DTO/config/migration ownership even when workers use separate worktrees.

## Event loop

At each natural Lead checkpoint:

1. Process incoming user requests into task rows.
2. Process all Orca messages in FIFO order and answer workers.
3. Inspect model/agent errors before deciding whether a task can be retried or released.
4. Process pending rule acknowledgements and update affected Task Contracts.
5. Verify settled tasks, including active-rule evidence, and update state.
6. Recompute `READY` tasks, ownership conflicts, dependencies, and capacity.
7. Dispatch the next safe task; otherwise explain the blocker.

When the user sends new work while workers are active, run steps 1 and 4 immediately. Do not wait for the active wave to finish.

When a task settles, the Lead verifies it, handles its event, chooses retain/reuse/release, and schedules the next safe `READY` task immediately. Continuous scheduling is preferred to waiting for a whole wave, but never bypasses a hard dependency or an ownership reservation.

## Model route and recovery

Use the project model policy for every Lead/worker launch and write requested/effective model information in the task board. A model/agent error never proves work did not happen: first inspect whether the task is live, unknown, failed, or stopped, and whether it could have changed files. Only a proven failed/stopped task can start one replacement on its permitted fallback model. Keep its ownership reservation until then.

For a Lead, request `gpt-5.6-terra` with `xhigh`. If the runtime rejects or proves failure of that Lead, use only `qwen3.8-max-0902` as its fallback. A Root Lead that is itself dead must be replaced by its supervising caller using saved `.orca-team` state; it cannot create its own replacement.

## Dynamic team shape

The default is Root Lead plus leaf workers. A Domain Lead is optional, bounded by `max_hierarchy_depth`, and uses part of the global worker capacity. Create one only for an isolated domain with enough independent local work to justify local scheduling. It may escalate a blocker or changed contract but cannot expand the team beyond policy.

When a Domain Lead has no active or ready local work, collapse it, settle/release its workers, and return queued work to the Root board. Reuse a relevant idle terminal only after an accepted task settlement; terminal persistence is never assumed after restart.

## Recovery

After Orca restart, rebind the Lead to the project Run if it exists. Compare state with live terminal and worker inventory. Treat absent handles as missing, not stopped. Keep their task in `RECOVERY_REQUIRED`/`BLOCKED`, capture available report evidence, then create a fresh task/dispatch when rework is needed. Do not reuse stale task capabilities or terminal handles.

## BE/FE coordination

Each Lead stores a contract record before code starts:

```text
Contract ID:
Owner leads:
Endpoint or event:
Request / response:
Permission:
State transition / error mapping:
Version / backward compatibility:
Smoke-test owner and evidence:
```

The contract may unblock independent BE and FE work. If it changes, record a new decision, notify both Leads, and identify affected tasks.
