# Model switching and recovery

This is the controller rule used by the Root Lead and Domain Leads. Its purpose is simple: when a worker really fails because of its model or provider, a Lead can continue the **same job** with the next allowed model without losing work or allowing two workers to edit the same area.

The controller acts while a Root Lead or Domain Lead is actively coordinating work. It is not a background Windows service. If Orca/Codex was closed, the next `$lead recover` reads the saved state, checks live workers first, and only then continues a proven failed task.

## Default routes

This table is the package default. The active project's `TEAM_POLICY.md` is authoritative and may replace it before tasks are launched. A project must list an exact primary, effort, and fallback order for every role it enables.

| Role or work type | First choice | Effort | Then use only these fallbacks |
|---|---|---|---|
| Root Lead | `gpt-5.6-terra` | `xhigh` | `qwen3.8-max-0902` with `xhigh` |
| Domain Lead | `gpt-5.6-terra` | `xhigh` | `qwen3.8-max-0902` with `xhigh` |
| Difficult worker task | `qwen3.8-max-0902` | `high` | `deepseek-v4.1-flash` -> `glm-5.3-flash` |
| Normal worker task | `deepseek-v4.1-flash` | `medium` | `qwen3.8-max-0902` -> `glm-5.3-flash` |
| Quick worker task | `glm-5.3-flash` | `low` | `deepseek-v4.1-flash` -> `qwen3.8-max-0902` |
| Final review | `qwen3.8-max-0902` | `high` | `deepseek-v4.1-flash` -> `glm-5.3-flash` |

Use the same effort for a worker fallback unless the runtime rejects that effort. A new machine must confirm that every named model is available before the first launch. If one is unavailable, record that evidence and move to the next entry in this table. Do not use a model outside this table.

## What the Lead watches

The Lead treats the following as evidence that requires investigation:

1. Orca reports the current Dispatch as `failed` or `stopped`.
2. A worker sends an explicit failed completion that includes a provider/model error.
3. The launch receipt refuses the selected model or effort.
4. Worker output contains a clear provider failure, model-not-found, authentication/provider outage, or an unrecoverable model runtime error.

`unknown`, a stale terminal, a timeout, silence, and a disconnected server are **not** model-failure evidence. The Lead keeps waiting or inspects the worker first. A normal code failure, a failed test, or an incomplete answer is also not automatically a model failure; the Lead reviews it as an ordinary task problem before spending a fallback attempt.

## Orca replacement flow

Use this flow for every supervised Codex worker. It is the required way to change a worker model in Orca.

1. Read the worker state and its final output. Confirm it is actually `failed` or `stopped`; do not act merely because the pane looks inactive.
2. Keep that task's ownership reservation. Check the permitted files and note what was already changed or verified.
3. Add a compact recovery handover to the Task Contract and `TEAM_STATE.md`: attempted model, exact evidence, file checkpoint, and next allowed model.
4. Start one fresh Codex worker for the **same Task**. Use the failed Dispatch as `--retry-of`, repeat the intended worktree, and request the next model and effort.
5. Read the launch receipt. `launch.requested` is only a request; record the model and effort only if `launch.effective` confirms them. If the launch is refused before a worker is ready, keep the task reserved and try the next permitted fallback.
6. The new worker reads the handover first, checks the existing files, and continues at the named next step. It must not repeat completed verification unless the change requires it.

Example command shape; replace every placeholder with IDs returned by the live Orca Run:

```powershell
orca orchestration worker-start `
  --task <task-id> `
  --retry-of <failed-dispatch-id> `
  --worktree <same-explicit-worktree> `
  --agent codex `
  --model <next-allowed-model> `
  --effort <route-effort> `
  --run <run-id> `
  --json
```

Do not add `--terminal` to that command. Orca cannot apply `--model` or `--effort` while reusing a terminal, so a fresh worker is required for a real model change. There may be only one active writer for the task's ownership zone.

## Limits and escalation

Each route has one primary plus two fallbacks: at most three model attempts for the same task. Orca also protects a task with its own retry limit. If every permitted entry is unavailable or fails, mark the task `WAITING_USER` and report the three attempts in plain language. Do not open a fourth worker or substitute another model.

A failed Domain Lead is replaced by the Root Lead using its Lead fallback and the saved state. A failed Root Lead cannot restart itself; the supervising caller starts its replacement from `.orca-team/TEAM_STATE.md`.

## Minimum state record

For every launch/replacement, write one short row:

```text
Task: T-012, attempt 2 of 3
Requested: deepseek-v4.1-flash / high
Effective: deepseek-v4.1-flash / high
Evidence: previous worker stopped after provider timeout; files reviewed: JobsService.cs
Next step: continue the uncompleted validation test
```

This lets any replacement Lead continue without guessing what happened.
