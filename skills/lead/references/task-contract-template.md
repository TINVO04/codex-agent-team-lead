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

Delegation and user contact:
- Delivery owner: <worker role label; required for any research or project file/output change>
- Lead boundary: <user request + .orca-team coordination state, scheduling, verification, and reporting only>
- User contact: <Root Lead only | explicitly authorized role; plain-language rules apply>
- Live launch evidence: <Orca Task/Dispatch and terminal handle; pending until returned>

Model plan:
- Task route: <Root Lead | Domain Lead | difficult | normal | quick | final review>
- Primary: <exact model ID and effort if applicable>
- Fallback order: <exact permitted model IDs>
- Attempt: <1 of 3, 2 of 3, or 3 of 3>
- Effective launch: <fill only after runtime confirms model and effort>

Capabilities and skills:
- Capability Gate: <not needed | existing skill | approved project reference | candidate under review | user approval needed>
- Required capability: <none or exact specialized capability>
- Allowed resources: <installed skill name/path, approved project reference, or none>
- Registry record: <SK-### or none>
- Prohibited: <unapproved skill download, scripts/hooks, credential sharing, external upload>

Research:
- Research Gate: <routine | research-first | research-deep>
- Decision question: <what must evidence help decide>
- Existing project evidence: <paths or none>
- Research brief: <RN-### path or pending; required before implementation for research-first/deep>
- Approved source types: <official docs, standards, named public examples, or none>
- Design/IP boundary: <reference principles only; do not copy third-party code, visual assets, or private data>

Quality and preview:
- Quality checklist: <API | UI/UX | data/change | integration | research/review; exact items required>
- Required evidence: <tests, screenshots, manual steps, contract check, or none>
- Preview Gate: <not needed | internal | user review required>
- Preview record: <PV-### decision/link or none>
- Preview-sensitive scope: <paths/decisions that must wait for preview; or none>

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
- If a needed capability is missing: send `CAPABILITY_REQUEST` with the capability, why normal project knowledge is insufficient, whether it is one-time or reusable, and whether any data would need to leave the project. Do not install or execute a candidate skill yourself.
- If research evidence is missing: send `RESEARCH_REQUEST` with the decision question, what was checked locally, and the smallest evidence needed. Do not browse broadly or use third-party material without the Lead's bounded source plan.
- Before `DONE`: run or report the task's listed quality checks. A changed file, a successful build alone, or an unverified worker claim is not sufficient evidence.

Recovery handover (fill only on a replacement attempt):
- Previous Dispatch/session: <actual ID or none>
- Proven state: <failed | stopped>; never use unknown/disconnected.
- Files/checkpoint inspected: <paths and result>
- Continue from: <the next concrete step; do not redo verified work>
- Ownership: <still reserved for this same task until the replacement settles>
```

For a read-only investigation or review, set the ownership zone to `none` and name the exact output that constitutes acceptance. A review completion authorizes findings, not edits by the Lead.
