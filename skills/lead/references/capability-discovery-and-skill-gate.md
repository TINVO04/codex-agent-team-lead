# Capability Discovery and Skill Gate

Use this when a task needs knowledge or a workflow that the current team does not clearly have: for example a new framework, a security review method, a file format, accessibility testing, a cloud service, or a specialist testing tool.

The purpose is to let the team learn what it needs without letting every worker download unknown material or expose project information.

## The short rule

Workers request a capability. The Lead searches and decides. The user approves any risky or newly installed tool.

Normal coding, reading local code, ordinary tests, and vendor documentation do not need a skill search. Do not turn every small task into a search task.

## Intake decision

For each specialized task, the Lead records one of these outcomes in its Task Contract:

1. `not needed` — the work can be done safely from project context and normal engineering practice.
2. `existing skill` — a currently available Codex skill or a registry entry already fits. Read its whole `SKILL.md` and the resources it directs the task to read.
3. `approved project reference` — the project already has a vetted internal guide/reference that fits.
4. `candidate under review` — a new candidate may help; do not give it to a worker yet.
5. `user approval needed` — the candidate would be downloaded, installed, enabled, or needs permissions that the user has not granted.

The Lead must check the skills already available to Codex and `.orca-team/SKILL_REGISTRY.md` first. Only then search trustworthy external sources. Use the installed `find-skills` capability and `npx skills find <specific query>` when appropriate; check official vendor sources and primary documentation before relying on general web results.

## What a worker sends

Use this exact short message to its Lead:

```text
CAPABILITY_REQUEST
Task: <ID>
Need: <specific capability>
Why: <what cannot safely be resolved from project context>
Use: <one task | likely reusable>
Data boundary: <no project data leaves the machine | name the proposed data and destination>
```

The worker continues safe independent work if possible. It pauses only the portion that actually depends on the decision. It does not install, update, run, or browse for a skill on its own.

## How the Lead evaluates a candidate

Before recommending or allowing use, the Lead records a `SK-###` entry in `SKILL_REGISTRY.md` and checks:

| Check | What is required |
|---|---|
| Fit | It addresses the exact capability and task, not merely a similar word. |
| Publisher | Prefer an official vendor or established organization. Treat unknown individual sources carefully. |
| Adoption | Check meaningful usage/install numbers and repository activity; popularity alone is never proof of safety. |
| Contents | Read the entire `SKILL.md` plus every referenced script, hook, or resource that the task would use. |
| Data | Confirm it does not upload source code, logs, tokens, customer data, or credentials. |
| Authority | Identify any filesystem, Git, database, cloud, deploy, browser-login, or service action it could cause. |
| Scope | Prefer a task- or project-local reference over a global machine-wide installation. |

Reject a candidate when its source is unclear, its instructions cannot be fully inspected, it asks for secrets, it performs unrelated actions, or it requires permissions outside the accepted task.

## Permission modes

The default set by bootstrap is intentionally conservative:

### `suggest-only` (default)

The Lead may search, inspect public information, and record a recommendation. It must ask the user before any new skill is downloaded, installed, enabled, or executed.

### `trusted-instruction-only` (explicit opt-in per project)

The user may change the policy to this mode. The Lead can prepare and use a newly discovered skill only when all are true:

- the publisher is reputable and the source is fully inspectable;
- it contains instructions/references only — no scripts, hooks, native binaries, package install, or external tool execution;
- it requires no credential, login, data upload, Git, database, deploy, or service change;
- it is kept project-local and recorded in the registry.

This is not permission to install skills globally or to override project Git/database/deploy rules. A candidate that crosses any boundary returns to `user approval needed`.

## Safe ways to use a chosen skill

1. Existing installed skill: read and use it according to its instructions.
2. Trusted instruction-only candidate: Lead reads it, records why it passed, and gives the worker the exact approved local path and narrow purpose.
3. Candidate with scripts/hooks or external access: describe the risk and ask the user for one clear approval before obtaining or using it.
4. No good candidate: use primary documentation and normal engineering ability. If the capability recurs, create a small project-local internal guide or skill under the normal file-change rules.

Never copy secrets or full private code into a search query, a public issue, or a third-party skill service. Use generic descriptions and sanitized error messages.

## Registry lifecycle

Each candidate has a state:

- `candidate`: found but not yet accepted;
- `approved`: checked and allowed for a stated scope;
- `active`: currently being used by an assigned task;
- `rejected`: unsafe, poor fit, unavailable, or not approved;
- `retired`: once useful but no longer appropriate.

At task completion, the Lead changes `active` to `approved` if it can be reused, or `retired` if it was only temporary. If a skill did not help, record the reason so the next Lead does not repeat the same search.

## Reporting to the user

Keep it short and plain. Example:

> Đang làm: phần này cần một kỹ năng mới về kiểm thử bảo mật. Mình đã tìm được một lựa chọn từ nguồn chính thức, nhưng nó có script cài thêm công cụ. Bạn có đồng ý cho dùng lựa chọn đó không?

For a safe existing skill, no approval message is needed; record the use internally and continue the task.
