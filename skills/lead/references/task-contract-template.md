# Worker task contract

Every implementation, test, investigation, or review worker receives a self-contained contract. Do not dispatch a vague task.

```markdown
### Task: <ID> — <title>

Goal: <observable outcome>
Priority: <P0 | P1 | P2 | P3>
Project / module: <scope>
Task class: <implementation | research | contract | test | review | integration>
Coordination owner: <Root Lead | Domain Lead name>
Applicable team rules: <none | R-001, R-002>

Model plan:
- Task route: <Root Lead | Domain Lead | difficult | normal | quick | final review>
- Primary: <exact model ID and effort if applicable>
- Fallback order: <exact permitted model IDs>
- Attempt: <1 of 3, 2 of 3, or 3 of 3>
- Effective launch: <fill only after runtime confirms model and effort>

Context:
- <only relevant paths, contract, or established decision>

Ownership zone:
- Allowed: `<exact paths or glob>`
- Do not touch: `<shared paths, other worker zones, config/migration/etc.>`

Dependencies:
- <none, task IDs, or contract record>

Parallel Gate:
- Result: <pass | hard dependency | ownership conflict | contract-first>
- Reason and reservation: <specific path/resource or contract ID>

Constraints:
- <environment, compatibility, security, user-approved boundary>

Rule checkpoints:
- Before work: <ownership/approval/contract check>
- Before DONE: <rule evidence that the Lead must verify>

Acceptance:
1. <observable behavior>
2. <specific test/build/manual evidence>
3. <compatibility or regression criterion>

Report:
- Actual files changed.
- Commands run and result.
- Assumptions, blocker, or follow-up contract needed.
- One event: `DONE`, `BLOCKED`, `NEED_DECISION`, `CONTRACT_CHANGED`, or `FAILED`.
- If the model/agent failed: model evidence, whether files may have changed, and safe recovery needed.

Recovery handover (fill only on a replacement attempt):
- Previous Dispatch/session: <actual ID or none>
- Proven state: <failed | stopped>; never use unknown/disconnected.
- Files/checkpoint inspected: <paths and result>
- Continue from: <the next concrete step; do not redo verified work>
- Ownership: <still reserved for this same task until the replacement settles>
```

For a read-only investigation or review, set the ownership zone to `none` and name the exact output that constitutes acceptance. A review completion authorizes findings, not edits by the Lead.
