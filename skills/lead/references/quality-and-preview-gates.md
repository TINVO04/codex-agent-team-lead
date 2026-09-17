# Quality and Preview Gates

Use this reference when the Lead defines “done”, reviews a worker result, or decides whether a UI/UX/product direction needs a short user preview before the team builds it.

## Quality Gate: “done” must be visible

Every Task Contract selects the relevant checklist in `.orca-team/QUALITY_GATES.md` and states the exact evidence needed. Select only what applies; a narrow documentation task should not carry a migration checklist.

At minimum, the Lead verifies:

1. the task goal actually happened, not merely that files changed;
2. the relevant tests or clearly recorded manual checks passed;
3. public contracts and cross-project obligations were handled when they changed;
4. the task did not break a stated rule, approval boundary, or other worker's ownership;
5. claims marked `DONE` have evidence the Lead can inspect.

A worker's statement, a successful compile alone, or a screenshot alone is not sufficient for every task. Combine the evidence that fits the change.

## Preview Gate: decide before expensive subjective work

The Lead classifies a preview as one of:

- `not needed`: localized maintenance or a fully specified, low-impact change;
- `internal`: a small technical/design choice is documented for the team but does not need the user's preference;
- `user review required`: a decision would materially affect how people see, navigate, understand, or use the product.

Require a user preview by default for:

- a new user-facing page or major dashboard;
- a material visual redesign or new visual direction;
- navigation/information hierarchy changes;
- a new or materially changed user journey, such as registration, moderation, checkout, or onboarding;
- a user-visible content or behavior choice with two reasonable but different directions.

Skip it only when the user explicitly asks for direct implementation, has already provided a final design/specification, or the change is genuinely minor. Record why it was skipped in the Task Contract.

## What the user receives

Keep the preview short, plain, and decision-focused. It is not a long design document and it should not make the user read internal agent details.

```text
Mục tiêu: <the user problem being improved>
Đề xuất: <layout/flow in a few lines>
Trên mobile và các trạng thái: <only important differences>
Điểm cần chốt: <one direct choice, or a request to approve this direction>
```

If useful, include a small text wireframe, existing screenshot, or a mockup. Do not build a high-fidelity implementation just to ask which direction the user prefers.

After the user responds, save a `PV-###` record in `TEAM_STATE.md` and reference it in the Task Contract. The implementation worker may then work on the preview-sensitive files. If the user changes direction, update the record and re-scope work at a safe checkpoint.

## Verification sequence

1. Worker reports actual files, evidence, and any remaining uncertainty.
2. Lead compares it with the accepted preview, research brief, task acceptance, and selected checklist.
3. Lead runs/reviews the proportionate checks and resolves cross-project confirmation where required.
4. Only then mark the task `DONE` and tell the user in plain language.

If a check cannot run, do not hide it. State what could not be checked, why, what lower-risk evidence exists, and whether the task should be marked `BLOCKED`, `WAITING_USER`, or completed with an explicit follow-up.
