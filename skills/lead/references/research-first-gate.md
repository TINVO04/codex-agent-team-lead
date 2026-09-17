# Research-first Gate

Use this gate before implementation when evidence and examples materially improve the decision. It prevents two opposite failures: making important design/product decisions from guesswork, and browsing forever when the task is already clear.

This is different from the Skill Discovery Gate. Research-first means “learn enough to make a sound decision.” A skill is only considered if the team needs a reusable specialist workflow.

## Classify every task once

The Lead chooses one level at intake and writes it in the Task Contract.

| Level | Use it when | Required outcome |
|---|---|---|
| `routine` | A bounded fix or implementation has a clear local pattern and little design/risk impact. | Work directly from project context. |
| `research-first` | UI/UX, visual design, content/copy, a user flow, a new library/framework, architecture choice, performance, security, or integration needs current evidence. | A focused research brief before the affected implementation. |
| `research-deep` | The decision has broad product, cost, safety, compliance, or irreversible impact. | Evidence plan, comparative brief, and Lead decision before implementation. |

Default to `research-first` for a new user-facing screen or journey, dashboard, responsive/mobile redesign, visual/brand work, content that affects conversion or trust, a new vendor/framework, authentication/authorization, payment, file storage, public API shape, significant performance work, or an unclear multi-option task.

Do not label a routine typo, localized defect, known pattern, or a mechanically specified change as research-first just to add ceremony.

## The research brief

A research task is read-only unless its Task Contract explicitly says otherwise. It writes one short `RN-###-short-topic.md` into `.orca-team/RESEARCH_NOTES/` using that folder's template.

The brief must answer:

1. What exact project decision must be made?
2. What do existing code, product requirements, and users already require?
3. Which trustworthy sources were checked?
4. What practical principles or constraints apply here?
5. Which options were considered and what is the trade-off?
6. What is the recommended project-specific direction?
7. What must implementation and QA prove afterward?

It should be short enough for a worker to use. Links and a distilled conclusion are better than pasted pages of text.

## Source order

Prefer this order. Do not treat a search ranking as proof.

1. Existing project rules, design system, user research, requirements, code patterns, and earlier research notes.
2. Official product, framework, or platform documentation.
3. Relevant standards and recognized guidance, such as accessibility or security standards.
4. A small number of well-known public products/examples for interaction or information-design principles.
5. Reputable expert sources only when the earlier sources do not settle the question.

For visual/design research, inspect layout hierarchy, information density, states, responsive behavior, and accessibility — not merely colors or screenshots. For technical research, inspect compatibility, maintenance, security, operational cost, failure behavior, and migration/rollback implications.

## Boundaries

- Learn principles. Do not copy third-party code, visual assets, text, or a whole design verbatim.
- Never put private source, tokens, customer data, unredacted logs, or production database details into a web query, public issue, or third-party service.
- The source plan may name public links and official docs, but an external upload, login, paid tool, plugin install, crawler, script, or API use follows the separate user-approval and Skill Discovery rules.
- A worker reads only the research brief and sources approved in its contract. If it needs broader research, it sends `RESEARCH_REQUEST` to the Lead.

## How it works with workers

The Lead must run a read-only research worker for every `research-first` or `research-deep` task. The Lead itself only creates the task and reviews the resulting brief; it does not scan files, browse the web, or research documentation. The implementation worker starts after the brief is accepted if the design/decision depends on it. A scaffolding task can run earlier only when it cannot lock in the disputed decision or overlap a writer.

If a task combines research and implementation, either split it into `research -> implementation` or give the worker an explicit checkpoint: it must submit the brief to the Lead before changing the decision-sensitive files.

## Stop point and quality check

Research is sufficient when it gives a clear recommendation that fits the project constraints, cites enough trustworthy evidence for the level, explains a real trade-off, and gives QA something observable to verify.

If two good options remain and the choice materially changes scope, design direction, cost, or external authority, the Lead asks the user one plain-language question rather than guessing.

At completion, record reusable findings in `TEAM_STATE.md` and keep the brief. Mark a related skill candidate in `SKILL_REGISTRY.md` only if a skill was actually evaluated.
