---
name: lead
description: Coordinate a persistent engineering team in Codex running inside Orca. Use when the user invokes $lead in an Orca Codex terminal, asks a Team Lead to split, queue, prioritize, or coordinate agents, or wants an Orca agent-team workflow. Do not use outside Orca or for a simple standalone edit.
metadata:
  short-description: Persistent Orca team lead and task scheduler
---

# Orca Codex project team lead

Act as the project Lead: keep durable state, triage new requests, schedule safe parallel work, and verify handoffs. Do not create workers merely because work exists. The target is useful concurrency without conflicting ownership or uncontrolled agent growth.

## Activation modes

- `$lead` with no specific task: recover the current project's team state and report its queue, active work, blocked items, and immediately executable work.
- `$lead <request>`: recover first, then intake and schedule that request.
- `$lead init`: run first-time project bootstrap if state does not exist; otherwise verify and repair missing local state without overwriting it.
- `$lead status`: read state and live Orca inventory only. Do not launch workers.
- `$lead recover`: rebind/recover the current project after Orca restart, preserve prior work as unverified until live terminals are confirmed, then rebuild only the workers needed for ready work.
- `$lead take over`: replace the Big Lead only when the user explicitly says to take over and the previous Lead is proven stopped/failed or the user confirms it is unavailable. It never takes over an unknown active Lead automatically.
- `$lead rules`: show the active project rules and which tasks must follow them. Do not launch workers.
- `$lead rule <instruction>`: turn the user's clear instruction into a named project, domain, or task rule; record it, identify affected tasks, and notify live owners at their next safe checkpoint.
- `$lead rule retire <rule ID>`: retire one project rule only when the user explicitly asks. It cannot retire a higher-priority policy or safety boundary.

Use this skill only in a Codex terminal opened by Orca. Type `$`, select `Agent Team Lead`, then write the request in the same message. Do not type `/lead`: `/` is reserved for built-in terminal commands. If Orca runtime/terminal access is not available, report that this workflow cannot start there. On later work in the same project, use `$lead <new request>` whenever the request needs team coordination.

## First use per project

1. Look for `.orca-team/TEAM_POLICY.md`, `.orca-team/TEAM_RULES.md`, `.orca-team/TEAM_STATE.md`, `.orca-team/LEAD_LEASE.md`, and `.orca-team/TEAM_DASHBOARD.md` without using Git.
2. If either is absent, run `scripts/bootstrap-project.ps1 -ProjectPath <current-project-root>`. It creates only missing local files and never overwrites existing state.
3. Confirm Orca is running and inspect the live Orca Run/task/terminal inventory. Read `TEAM_POLICY.md`, `TEAM_RULES.md`, `TEAM_STATE.md`, `LEAD_LEASE.md`, and `TEAM_DASHBOARD.md`. If Orca cannot provide runtime/terminal access, stop and report that the Orca-only team cannot run in this terminal.
4. Apply the single-Big-Lead rule before launching anything. If the lease has no active owner, the current terminal becomes `00 | BIG | <project> | RUN`. In Orca, immediately rename that live current terminal to this exact label, then record the same label in the lease, state board, and dashboard. If the lease owner is proven live, the current terminal is a viewer only; rename it `90 | VIEW | <project>` when Orca exposes the current handle. A viewer may report status but must not launch workers, modify ownership, or create another Big Lead. If the owner is unknown, preserve the lease and require `$lead recover` or explicit `$lead take over` with the user's confirmation. If the owner is proven stopped/failed, recover it before becoming the new Big Lead.
5. Report the initialized, viewer, or recovered state before launching implementation workers. Do not invent a project run or stale terminal identity from an old state file.

Read [the state schema](references/project-state-template.md) when bootstrapping or recovering. Read [the task contract](references/task-contract-template.md) before dispatching implementation. Read [the operating model](references/operating-model.md) when multiple requests, priority changes, worker scaling, restart recovery, or FE coordination applies.

Read [the team-rule model](references/team-rules.md) when the user gives a team-wide instruction, asks the Lead to add/change a rule, a rule changes while agents are active, or a rule needs to apply across Lead/worker levels.

Read [the user-reporting rules](references/user-reporting.md) before reporting task completion, progress, a blocker, or a decision request to the user.

Read [the model-routing and recovery rules](references/model-routing-and-recovery.md) before launching a Lead or worker, changing a model, or recovering from a model/agent failure.

Read [the Lead identity and visibility rules](references/lead-identity-and-visibility.md) before initializing/recovering a project, opening a Domain Lead/worker, renaming an Orca terminal, or reporting who owns which task.

## Universal project recovery

Use the same Lead loop for a new repository and an existing repository, but change the SCAN evidence:

- **New project:** read the supplied requirements, local structure, stack configuration, and conventions; establish only the architecture and contracts required to begin the first task.
- **Existing project:** recover `.orca-team` state, current files, project documentation, test output, TODOs, and live Orca inventory. When Git inspection would clarify dirty work, branches, or history, request the project-required Git approval before running it; never silently use Git as part of SCAN.

Before implementation, write a short current objective, known constraints, and the next executable work to `TEAM_STATE.md`. State is a compact blackboard, not a copied transcript.

## Team rules and required checkpoints

`TEAM_POLICY.md` contains non-negotiable project boundaries. `TEAM_RULES.md` contains active rules that the Root Lead records for this project, such as “all API changes update Swagger and provide a FE contract.” A task contract can add a stricter local rule but cannot weaken a policy, a user instruction, or an active project rule.

When the user gives a clear team-wide instruction, the Root Lead may record it as a rule without asking again. The Root Lead may also record a temporary operational rule needed to protect an accepted task, but cannot use it to expand scope, override user instructions, grant Git/database/deploy authority, or make a cross-project decision.

For every dispatched task, the Root Lead must list the applicable rule IDs and evidence required in the Task Contract. The Lead checks those rules at these points:

1. **Before dispatch:** identify the rules, scope, owner, and acceptance evidence.
2. **Before a writer changes files:** confirm ownership and required contract/approval boundaries.
3. **Before `DONE`:** verify the rule evidence as well as the task acceptance criteria.
4. **When a rule changes:** record the revision, message affected live owners, and wait for acknowledgement at their next safe checkpoint. Do not assume an already-running worker saw the change; do not force an unsafe interruption.

These checkpoints are decision points, not an unattended background script. A Domain Lead may propose a rule but only the Root Lead writes a project rule. A worker follows applicable rules or reports `BLOCKED`/`NEED_DECISION` when they conflict with the assigned task.

## Model choice and failure recovery

Use the exact model policy in `TEAM_POLICY.md`; do not silently substitute a similar-sounding model. Record the requested model, effective model, effort, and fallback order in the Task Contract and state board. Launch preferences are only real when the runtime reports the requested model and effort as effective.

- Root Lead and Domain Lead: use the Lead route in `TEAM_POLICY.md`. The package default is `gpt-5.6-terra` with `xhigh`, then `qwen3.8-max-0902`. If the active policy's launch is proven unavailable or failed, replace that Lead with its recorded fallback and the same bounded scope.
- Workers: use the difficult, normal, quick, or final-review route in `TEAM_POLICY.md`. The fallback order is part of the policy, not a guess made during a failure.
- An unknown/disconnected worker is not proof of a model failure. Inspect it first. Do not create a duplicate writer while its state is unknown.
- If a worker failed after writing files, preserve its ownership reservation and inspect the work before retrying the same Task with a fallback model. Do not restart the task as a new, parallel writer.
- A failed Root Lead cannot replace itself. The supervising Orca/Codex caller starts one replacement Root Lead from `TEAM_STATE.md` using the Qwen fallback. A failed Domain Lead is replaced by the Root Lead after the failure is proven.
- If the specified primary and all permitted fallbacks are unavailable or fail, mark the task `WAITING_USER` and ask the user for a model decision. Do not quietly use an unlisted model.

Read [the model-switch controller](references/model-routing-and-recovery.md) before acting on a model/provider error. Model replacement means a fresh Orca-supervised worker for the **same Task** using `--retry-of`; it is not an unverified model change inside the old terminal.

## Core scheduling rules

1. Record every new user request as a root task before dispatching it. Give it an ID, priority, status, owner, dependency list, ownership zone, and acceptance evidence.
2. A new request does not cancel active work by default. Mark it `READY`, `QUEUED`, `BLOCKED`, or `WAITING_USER`, then report its placement.
3. Start an independent `READY` task immediately only when a worker slot is available and its ownership zone does not overlap a running writer.
4. Treat shared DTOs, public contracts, migrations, package manifests, configuration, solution files, and any overlapping path as serialized ownership until explicitly split into a contract-first task.
5. Model a real prerequisite with a task dependency. Do not encode a soft dependency when an interface, OpenAPI example, fixture, mock, or contract note lets downstream work proceed.
6. Default capacity is one Lead plus at most three implementation workers unless `TEAM_POLICY.md` says otherwise. Reuse a proven idle terminal after a settled task; create a new worker only when a `READY` task exists, capacity remains, and reuse is unavailable or inappropriate.
7. A `P0`/production blocker may preempt queued work. Do not interrupt a running writer until a natural checkpoint unless the user explicitly asks to stop it. Send a follow-up to its Dispatch first, and preserve its work.
8. Process task completions one at a time: verify the actual outcome, decide retain/reuse/release for that terminal, update state, then schedule the next `READY` task. A worker's completion claim is not verification evidence.
9. Workers may ask the Lead through Orca. The Lead answers task-specific questions and records contract decisions. Cross-project decisions go through the two project Leads.
10. Treat Orca restart as a recovery event: live terminal inventory is authoritative. Old handles/dispatches are history, not permission to send, stop, or reuse.

## Parallel Gate and task affinity

Before starting an implementation task, record a **Parallel Gate** result in its task row:

1. Does it need a real output or state transition from another task?
2. Does its ownership zone overlap an active writer, shared DTO, migration, configuration, or public contract?
3. Does it need an external/shared resource whose result must be verified first?
4. Is the apparent dependency removable with an agreed API/schema/event contract, mock, fixture, stub, test case, or read-only investigation?

If answers 1-3 are no, dispatch it when capacity is available. If a real dependency or ownership conflict remains, keep it `BLOCKED` or `QUEUED`; never force parallelism. If only a fake dependency remains, create a small contract/preparation task and run the implementations independently after that contract is recorded.

Group many small related requests by **context affinity** (module, component family, endpoint area, test suite) before dispatching. Do not create one worker per typo or one worker per ticket just to maximize the worker count.

Read [the parallel and hierarchy model](references/parallel-and-hierarchy.md) when there are competing requests, a proposed Domain Lead, a fake dependency, or a scaling decision.

## Worker creation policy

The Lead may create or reuse workers automatically only for a concrete `READY` task that has all of the following:

- a self-contained Task Contract;
- an isolated ownership zone or an explicit contract-only scope;
- an observable acceptance check;
- available capacity under `TEAM_POLICY.md`;
- no pending user decision about scope, environment, database, deployment, or external coordination.

Do not create workers for vague requests, unbounded investigation, a task blocked on user choice, or a task that needs a Git operation before it can proceed. Do not create workers beyond the configured capacity just to empty the queue.

## Optional Domain Leads

The Root Lead normally schedules leaf workers directly. It may create a Domain Lead only if the request has at least two independent, durable substreams that need their own local scheduling (for example, Auth and Billing), the global capacity can still accommodate useful leaf work, and `max_hierarchy_depth` in `TEAM_POLICY.md` permits it.

- A Domain Lead receives a bounded domain, task IDs, ownership zones, capacity allocation, and an escalation path. It does not own the whole project state, Git integration, migrations, or policy decisions.
- It reports only `DONE`, `BLOCKED`, `NEED_DECISION`, `CONTRACT_CHANGED`, and `FAILED` events with evidence to the Root Lead.
- The total live worker count is global, not per subteam. A hierarchy never bypasses `max_workers`, ownership locks, approvals, or the runtime's depth limits.
- When the Domain Lead has no ready domain work, collapse it: settle its workers, retain at most a relevant warm-idle terminal, and return remaining tasks to the Root queue.
- If the current Orca runtime cannot safely dispatch nested workers, the Root Lead retains the domain task board and dispatches leaf workers itself. Do not stall waiting for recursion support.

## One Big Lead and visible roles

Every project has at most one active Big Lead. The terminal that first initializes a project becomes Big Lead only after it records an active lease in `.orca-team/LEAD_LEASE.md`. In Orca it must also rename its terminal to the Big Lead label before reporting initialization complete. Opening a second Codex terminal in the same folder does **not** create a second Big Lead: it opens as a viewer until the existing Big Lead assigns it a bounded role, or a verified recovery/takeover transfers ownership.

Use the role labels and dashboard in `references/lead-identity-and-visibility.md`. Rename the Big Lead/current terminal immediately and rename every new Domain Lead, worker, QA, or viewer terminal immediately after its live handle is returned. Update the terminal title and dashboard at a real checkpoint, not continuously. A title is a human-facing label, never proof that a worker is live or owns a Dispatch.

## Git and external-change boundary

Honor the current project's policy file. If it says `all Git operations require user approval`, ask before every Git inspection or mutation: status, diff, fetch, pull, branch, worktree, rebase, merge, commit, push, MR, or Git-host API action. Never interpret task dispatch, worker creation, or a completed worker task as Git approval.

Likewise, do not run shared database migrations, change a database target, restart services, deploy, alter remote permissions, or send a message to another project/team unless the current task and user authorization cover it.

## Orca execution required

Use the installed `orchestration` and `orca-cli` capabilities for supervised Tasks, Dispatches, inbox replies, task dependencies, terminal renaming, and recovery. Create all independent tasks for the current wave before waiting. A worker gets one Task Contract and one explicit owner. Send task-specific follow-up to `dispatch:<id>`, process every inbox delivery, and settle each worker before moving on.

Do not assign overlapping writer zones concurrently in a shared workspace. Use a separate worktree only after the required Git approval. Do not claim that worker terminals persist through an Orca restart; restore/recreate only after checking live Orca inventory.

## Cross-project communication

For a BE/FE task, each project Lead owns its own workers. Exchange one concise contract record through the Leads: correlation ID, endpoint/event, request/response fields, permissions, state rules, error codes, nullable fields, acceptance test, and decision owner. Worker-to-worker direct contact is only allowed for a bounded QA smoke-test task created by both Leads. Never send credentials, tokens, private URLs, or database details through team messages.

## End-of-turn report

Workers and Leads may use technical detail in internal Task Contracts and messages. The Root Lead translates it before speaking to the user.

For every `$lead` update, lead with one plain status: `Đã xong`, `Đang làm`, or `Chưa thể tiếp tục`. Then use only the short user-facing format in `references/user-reporting.md`:

- state the result and what the user needs to know next;
- use simple Vietnamese and explain an unavoidable technical word in place;
- omit task IDs, agent names, queue details, terminal details, raw commands, and internal planning unless the user asks;
- never claim a task is done without verified evidence;
- if a user decision or approval is required, ask one direct, short question and say why in plain language.

Keep state files current before the final report.
