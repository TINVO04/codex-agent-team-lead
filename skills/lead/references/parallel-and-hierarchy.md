# Parallel scheduling and bounded hierarchy

Use this model when incoming work competes for capacity or when a task may warrant a Domain Lead. The objective is useful parallelism, not the largest possible agent tree.

## Continuous scheduler

At every Lead checkpoint:

1. Add every incoming request to the task board and classify it as implementation, research, contract, test, review, or integration.
2. Rank valid work by user priority, real dependency, risk, and arrival order. Group small tasks that share context.
3. Apply the Parallel Gate and reserve the ownership zone for each dispatched writer.
4. Dispatch the highest-priority non-conflicting `READY` work up to global capacity.
5. On a worker event, verify its evidence, update the board, release or retain the settled terminal, and immediately schedule newly unblocked work. Do not wait for an artificial "wave" to finish.

The current task board is the shared blackboard. Store only decisions that alter work: API/schema contracts, ownership reservations, blockers, test evidence, and escalation decisions.

## Dependency rules

| Situation | Lead decision |
|---|---|
| A task needs another task's verified behavior or state transition | Record a hard dependency and serialize it. |
| Two writers touch the same file/module, migration, DTO, public contract, config, or test fixture | Reserve one ownership zone; serialize or split contract work first. |
| Frontend awaits a stable backend interface, or one component awaits a schema shape | Publish a contract with examples and let both sides use mocks/stubs or fixtures. |
| A bug cause is unknown | Dispatch a read-only investigation first. Convert its evidence into a bounded implementation task. |
| Many small fixes are in the same surface | Group them by context affinity under one owner. |

An API, schema, event, or fixture contract must state its owner, version/compatibility expectation, error/state mapping, and acceptance test. A contract breaks only a fake dependency; it never authorizes incompatible changes.

## Bounded hierarchy

The default topology is flat:

```text
Root Lead -> leaf workers
```

Use a Domain Lead only for a genuinely large branch. It is a local scheduler, not another unrestricted Root Lead:

```text
Root Lead
|- Auth Domain Lead -> Auth leaf tasks
`- Billing Domain Lead -> Billing leaf tasks
```

Create it only when all are true:

- the branch has at least two independently executable or imminently executable tasks;
- its files/contracts can be isolated from other branches;
- a named local decision owner is useful;
- global worker capacity remains after reserving a slot for coordination; and
- no user authorization, shared migration, Git action, or external change remains unresolved.

Use `max_hierarchy_depth` as a hard ceiling. Depth counts Root Lead as zero. Under the default value of two, only `Root Lead -> Domain Lead -> leaf worker` is allowed. Do not create a tree merely because a request has many nouns.

## Scale up, retain, collapse

Scale up only when the number of non-conflicting `READY` tasks exceeds suitable idle capacity. A busy worker does not prove that a new worker is useful; a hard dependency or overlapping writer never becomes parallel merely by creating more workers.

After a verified task, prefer reusing a settled terminal for an immediately related task while its project context is warm. Retention is a deliberate Orca lifecycle choice, not evidence that a terminal survives restart. Release the terminal when its domain has no likely ready work or capacity is needed elsewhere.

When a Domain Lead has no owned `READY`/`ACTIVE` work, collapse it after processing its final events. Reassign remaining queued tasks to the Root board. Never delete task history just because a worker or terminal was released.

## Required event messages

A Lead or worker reports concise events rather than full transcripts:

| Event | Minimum content |
|---|---|
| `DONE` | task ID, outcome, evidence, actual files/contract affected |
| `BLOCKED` | task ID, exact blocker, dependency or authorization needed |
| `NEED_DECISION` | options, owner, deadline/impact if known |
| `CONTRACT_CHANGED` | contract ID, old/new behavior, compatibility impact, affected tasks |
| `FAILED` | task ID, failed evidence, preserved state, recommended recovery |

The Root Lead processes these events before it acknowledges the Orca delivery or schedules additional work.
