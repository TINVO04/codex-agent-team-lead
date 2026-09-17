# Delegation Audit

Use `$lead audit` to answer one practical question: is the project team visibly following the agreed roles?

The audit is read-only. It does not launch a replacement worker, stop a worker, edit delivery files, or use Git by default. It reads the project state, task contracts, dashboard, lease, and live Orca Run/task/terminal inventory.

## What to check

For each task that is `ACTIVE`, `VERIFYING`, `BLOCKED`, or `QUEUED`, compare:

1. Does it change a project deliverable, or is it only a status/clarification/policy answer?
2. If it changes a deliverable, does its Task Contract name a worker as delivery owner?
3. Does live Orca show that worker Task/Dispatch and a terminal handle, or has a verified completion/recovery event explained its absence?
4. Does the terminal title and dashboard show the correct role and current state?
5. Is a Root/Domain Lead recorded only as coordinator, contract/research owner, verifier, or reporter — never as delivery owner for project files?
6. Are there duplicate workers or conflicting ownership zones?

## Audit result

Classify each relevant task as:

- `OK`: its owner, live state, and visible terminal agree;
- `WAITING`: no worker is required yet because it is waiting for a user decision, real dependency, or worker capacity;
- `RECOVERY_REQUIRED`: an earlier worker is missing/unknown and ownership must be recovered before rework;
- `GAP`: a task that changes project files is active or claimed complete but has no valid worker ownership/terminal evidence;
- `CONFLICT`: duplicate writer, overlapping ownership, or an unauthorized Lead delivery owner is recorded.

Do not assume a terminal disappeared merely because it is not visible in an old dashboard. Live Orca inventory is the authority. Do not assume an unknown terminal failed; use recovery rules.

## Optional file-ownership check

The default audit cannot prove who wrote a local file. If the user has separately approved Git inspection for this project, the Lead may compare changed paths with the ownership board. It may report a suspicious path when a product file changed but no worker ever owned that path. Git output is supporting evidence, not proof of authorship.

Without that approval, report only the visible coordination gap. Never run Git silently during an audit.

## What the Lead does after a gap

1. Update `TEAM_STATE.md` with the gap and preserve existing ownership.
2. Do not make delivery changes itself and do not launch a duplicate writer while worker state is unknown.
3. If the task is safe and a worker slot is available, prepare a normal replacement/recovery task only after the prior state is proven stopped/failed or the user decides.
4. Report the simple outcome to the user. Do not hide the gap.

## User-facing report

The user does not need raw Orca handles or internal task IDs. Use one of these forms:

```text
Đúng quy trình: các việc đang sửa file đều có worker riêng và đang hiển thị rõ.
```

```text
Cần sửa quy trình: có một việc đang được ghi là đang làm nhưng chưa thấy worker phụ trách. Mình đã để việc đó chờ kiểm tra, Lead sẽ không tự làm thay.
```

```text
Chưa thể kết luận vì worker cũ mất kết nối. Mình cần kiểm tra lại trạng thái của worker đó trước để không tạo hai người cùng sửa một chỗ.
```
