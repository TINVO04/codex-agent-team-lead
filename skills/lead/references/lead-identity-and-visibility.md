# One Big Lead, clear terminal names, and team visibility

This rule answers three simple questions at any moment: who is the Big Lead, which Lead owns a worker, and whether a second terminal may schedule work.

## One Big Lead only

The first terminal that completes project initialization becomes the Big Lead only after it records an active lease. Its permanent label starts with `00`:

```text
00 | BIG | <project> | RUN
```

The Big Lead owns the project queue, task ownership, policy, and the right to create Domain Leads and workers. There can be only one active owner for those responsibilities.

## Mandatory terminal naming in Orca

When the Big Lead successfully initializes in an Orca terminal, it must rename the terminal it is already using before it says initialization is complete:

```powershell
orca terminal rename --title "00 | BIG | <PROJECT> | RUN" --json
```

When the current terminal cannot be inferred, use the real handle returned by Orca instead:

```powershell
orca terminal rename --terminal <runtime-handle> --title "00 | BIG | <PROJECT> | RUN" --json
```

Every terminal created later follows the same rule as soon as Orca returns its handle:

```text
00 | BIG | MEU-HIRE-FE | RUN
10 | LEAD-ADMIN | T-100 | RUN
11 | WORKER-ADMIN-API | T-101.1 | RUN
12 | WORKER-ADMIN-UI | T-101.2 | RUN
19 | QA-ADMIN | T-101.QA | CHECK
90 | VIEW | MEU-HIRE-FE
```

The Big Lead issues `orca terminal rename` after worker/Lead start succeeds and before it records that role as active in the dashboard. If a rename fails, keep the task/worker running, record the failure, and keep the correct role visible in `TEAM_DASHBOARD.md`; never guess a terminal handle or rename an unrelated terminal.

When a person opens another Codex terminal in the same project and invokes `$lead` or `$lead init`:

1. Read `LEAD_LEASE.md`, `TEAM_STATE.md`, and `TEAM_DASHBOARD.md` first.
2. In Orca, inspect the stored Lead terminal/Run with live inventory. A live owner remains Big Lead.
3. If the current Big Lead is live, rename the new Orca terminal to `90 | VIEW | <project>` when a live handle is available. It may show `$lead status`, but must not start workers, change task ownership, or become a second Big Lead.
4. A new Big Lead may replace the old one only after its failure is proven through Orca, or when the user explicitly confirms the old Lead is unavailable and asks for `$lead take over`. Record the transfer before launching any worker.

Two terminals initialized at exactly the same time are a race that a Markdown file alone cannot make perfectly atomic. If this happens, neither terminal may dispatch a worker until one observes its lease as the only active lease or the user chooses the Big Lead. The ownership locks still prevent writer work from being intentionally duplicated.

## Lease file

`LEAD_LEASE.md` is a compact ownership record, not a background process monitor:

```markdown
# Big Lead Lease

State: ACTIVE
Big Lead label: 00 | BIG | <project> | RUN
Mode: Orca
Orca Run: <run ID or unbound>
Lead terminal: <runtime handle or unbound>
Started: <time>
Last confirmed: <time and evidence>

Only this Big Lead may schedule workers. A viewer needs verified recovery or explicit user takeover before it becomes Big Lead.
```

Allowed states are `UNASSIGNED`, `ACTIVE`, `VIEWER_ONLY`, `RECOVERY_REQUIRED`, and `TRANSFERRED`. Never overwrite an `ACTIVE` lease merely because a second terminal was opened.

## Naming pattern

Names are management labels for people. They never identify a model and never replace the runtime's actual terminal/Dispatch identity.

| Role | Terminal label | Meaning |
|---|---|---|
| Big Lead | `00 | BIG | <project> | RUN` | Only project-wide coordinator |
| Domain Lead | `10 | LEAD-ADMIN | T-100 | RUN` | Owns the Admin branch; use `20`, `30`, and so on for other domains |
| Worker | `11 | WORKER-ADMIN-API | T-101.1 | RUN` | Worker under Lead Admin; number stays in that Lead's group |
| QA | `19 | QA-ADMIN | T-101.QA | CHECK` | Test/review worker for that branch |
| Viewer | `90 | VIEW | <project>` | Extra terminal that can inspect but cannot schedule |

Use a short, stable domain code such as `ADMIN`, `AUTH`, `JOBS`, `REPORTS`, `PAYMENT`, `BE`, or `FE`. A Domain Lead assigns its children within its number group. Do not reuse a live number for an unrelated active role.

Allowed short state words are `RUN`, `WAIT`, `BLOCK`, `CHECK`, `DONE`, `MODEL_ERROR`, and `RECOVERING`.

## Dashboard

Every project uses `.orca-team/TEAM_DASHBOARD.md` as the human-readable map beside Orca terminal tabs.

```markdown
# Team Dashboard

Last updated: <time>
Project: <project>

00 | BIG | <project> | RUN
|
|- 10 | LEAD-ADMIN | T-100 | RUN
|  |- 11 | WORKER-ADMIN-API | T-101.1 | RUN
|  |- 12 | WORKER-ADMIN-UI | T-101.2 | BLOCK
|  `- 19 | QA-ADMIN | T-101.QA | WAIT
|
`- 20 | LEAD-AUTH | T-200 | RUN
   |- 21 | WORKER-AUTH-API | T-201.1 | RUN
   `- 22 | WORKER-AUTH-UI | T-201.2 | CHECK

## Quick reading

| Label | Owner / task | State | Next checkpoint |
|---|---|---|---|
| 12 | Admin user interface | BLOCK | Waiting for API contract T-101 |
| 22 | Auth user interface | CHECK | Run focused test |
```

Update it when a role starts, its state actually changes, a worker is replaced, or a role is collapsed. Do not claim an update based only on a silent terminal.

## Orca terminal titles

After Orca returns the live handle for a Lead or worker, the Big Lead must set the matching label:

```powershell
orca terminal rename --terminal <runtime-handle> --title "11 | WORKER-ADMIN-API | T-101.1 | RUN" --json
```

Rename only after the worker exists and its runtime handle was returned by Orca. The terminal title is for visibility; use Orca worker state and the task board to decide liveness, recovery, or ownership.

## When a Domain Lead ends

When its branch has no ready or active work, the Big Lead settles its workers, marks the Domain Lead `DONE` in the dashboard, and returns any remaining queued work to the Root board. Its label remains in the dashboard briefly as history but its number cannot be assigned to a new live role until that old row is clearly closed.
