# Codex Agent Team Lead

`/lead` turns Codex or Codex in Orca into a project Lead. It keeps a short task board, gives workers clear ownership, runs independent work in parallel when safe, and explains the result to the user in simple language.

It is intended for an existing project or a new project. It creates a small local `.orca-team` folder in the project to remember active work, rules, decisions, and recovery notes. The repository contains no project source code, credentials, tokens, or database settings.

## What it handles

- Big Lead, optional Domain Leads, implementation workers, QA, and final review.
- New requests arriving while older work is still running.
- Safe parallel work: one writer owns one code area at a time.
- Worker/Lead recovery after a model or terminal failure.
- A compact contract between a backend Lead and a frontend Lead.
- Plain-language reports for the person using the team.
- Git, database, restart, deployment, and external actions remain blocked until the user clearly approves them.

## Install in Codex

The simplest option is to ask Codex:

```text
Install the skill from https://github.com/TINVO04/codex-agent-team-lead/tree/main/skills/lead
```

Codex installs it into its own skills folder. Start a new turn after installation, open any project, then run:

```text
/lead init
```

To install manually on Windows, clone this repository and copy `skills/lead` into:

```text
%USERPROFILE%\.codex\skills\lead
```

## Install in Orca

Clone this repository, then copy the same `skills/lead` folder into:

```text
%USERPROFILE%\.agents\skills\lead
```

Restart the Orca terminal/session, open the target project, and run `/lead init`.

When both Codex and Orca are used on the same computer, install the folder in both locations.

## Daily use

```text
/lead init                 # first time in a project
/lead <your request>       # give work to the Lead
/lead status               # short view of current work
/lead recover              # after Codex or Orca was restarted
/lead rules                # show active project rules
```

The Lead does not create workers merely because a task exists. It creates them only when the work is clear, independent, has a way to verify success, and does not collide with another worker's files.

## Model policy

The default model policy in this repository is the one used by its maintainer:

| Role / work type | Primary model | Effort | Fallback |
|---|---|---|---|
| Big Lead / Domain Lead | `gpt-5.6-terra` | `xhigh` | `qwen3.8-max-0902` |
| Difficult worker task | `qwen3.8-max-0902` | `high` | DeepSeek, then GLM |
| Normal worker task | `deepseek-v4.1-flash` | `medium` | Qwen, then GLM |
| Quick worker task | `glm-5.3-flash` | `low` | DeepSeek, then Qwen |
| Final review | `qwen3.8-max-0902` | `high` | DeepSeek, then GLM |

Before using `/lead` for real work, edit the generated `.orca-team/TEAM_POLICY.md` if your Codex account exposes different model names. The active project's policy is the source of truth. The Lead records the requested and actual model instead of claiming a model was used without confirmation.

When a worker model fails, the Lead checks that it truly stopped, protects any code already written, and starts one replacement worker for the same task using the next allowed model. It never starts two writers for the same code area. A failed Domain Lead is replaced by the Big Lead; if the Big Lead is unavailable, start a new one and run `/lead recover`.

## Repository layout

```text
skills/lead/
  SKILL.md                 Main Lead workflow
  agents/openai.yaml       Codex UI metadata
  references/              Task, recovery, reporting, and coordination rules
  scripts/bootstrap-project.ps1
```

## License

MIT. See [LICENSE](LICENSE).
