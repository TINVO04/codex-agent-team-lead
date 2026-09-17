# Team rules

`TEAM_RULES.md` is the project’s short rulebook. It lets the Root Lead record one clear instruction and require every affected Domain Lead and worker to apply it. It is not a transcript and it is not a way to bypass user approval.

## What belongs here

Add a rule when it changes how more than one task or owner must work. Examples:

- Every API/DTO/permission change updates Swagger, includes tests, and creates a FE contract.
- Changes to authentication require a backward-compatibility check.
- This release must not alter the database schema.

Keep a one-task constraint inside that task contract unless it is likely to affect other tasks.

## Who may change a rule

| Actor | May do |
|---|---|
| User | Add, change, or retire any project rule. User instruction is highest priority. |
| Root Lead | Record a clear user instruction; add a temporary delivery rule that protects an accepted task; assign rule IDs and notify affected owners. |
| Domain Lead | Propose a rule or report a conflict. It may not write/retire project rules or weaken policy. |
| Worker | Follow listed rules and report a blocker or decision need. It may not change rules. |

No rule can weaken `TEAM_POLICY.md`, permit unapproved Git/database/deployment/external work, reveal secrets, or change a user-approved scope. A task rule may be stricter than a project rule.

## Rule order

When two instructions conflict, apply them in this order:

1. The current user instruction and platform safety requirements.
2. `TEAM_POLICY.md`.
3. Active `TEAM_RULES.md` rules.
4. Task-specific constraints.

If the conflict is not resolvable by that order, stop the affected task as `WAITING_USER` or report `NEED_DECISION`.

## Rule format

```markdown
# Team Rules

Last updated: <ISO 8601 local time>

## Active rules

### R-001 — API change evidence

Source: user instruction on <date> | Root Lead decision on <date>
Scope: project | domain:<name> | tasks:<IDs>
Applies to: <owners/tasks>
Rule: Every API, DTO, permission, or business-state change updates the contract/Swagger, has relevant test evidence, and records a FE contract when FE is affected.
Checkpoints: before dispatch; before DONE
Required evidence: <OpenAPI/test/contract record>
If blocked: report BLOCKED or NEED_DECISION; do not mark DONE.
Status: active

## Retired rules

### R-000 — <title>

Retired by: user on <date>
Reason: <why>
```

Use increasing IDs (`R-001`, `R-002`, …). Retiring a rule preserves its history; never delete it. A rule becomes active for a new task immediately after it is written. For a running task, it becomes mandatory only after its owner acknowledges the update at a safe checkpoint, unless the user explicitly directs an immediate stop.

## Applying a rule

When the user says something like:

```text
$lead From now on, every API change must update Swagger, include tests, and tell FE what changed.
```

The Root Lead should:

1. Turn it into a concise rule with scope and evidence.
2. Add it to `TEAM_RULES.md` and record it in the rules section of `TEAM_STATE.md`.
3. Identify active and queued tasks affected by it.
4. Add its ID to every affected Task Contract.
5. Send a short rule-update message to each active owner; record acknowledgement at their next safe checkpoint.
6. Verify the evidence before accepting `DONE`.

Use a rule checkpoint as a required Lead check, not as a hidden shell hook. If a project later needs an actual test/lint command, put that exact command in the task acceptance evidence or project tooling after the required authorization.
