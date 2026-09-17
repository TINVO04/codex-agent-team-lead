# Rule dự án và hook dạng checklist

`TEAM_POLICY.md` giữ các ranh giới không được làm yếu. `TEAM_RULES.md` giữ rule thực thi đang có hiệu lực. `PROJECT_HOOKS.md` là checklist theo thời điểm để team không quên kiểm tra điều quan trọng.

Hook ở đây là **luật bằng chữ**, không phải script chạy ngầm. Nó giúp Lead biết lúc nào phải dừng, kiểm tra hoặc hỏi người dùng; không được tự gọi lệnh hay tạo thay đổi bên ngoài.

## Thứ tự ưu tiên

1. Yêu cầu hiện tại của người dùng và an toàn nền tảng.
2. `TEAM_POLICY.md`.
3. `TEAM_RULES.md` và `PROJECT_HOOKS.md`.
4. Task Contract.
5. Card vai trò Agency/skill đã duyệt.

Nếu hai điều mâu thuẫn, dùng điều ở cấp cao hơn. Không đoán cách dung hòa. Nếu vẫn không rõ, task ảnh hưởng phải `WAITING_USER` hoặc `NEED_DECISION`.

## Hook được phép làm

Hook chỉ được yêu cầu các việc sau:

- kiểm tra file state, ownership, Task Contract, evidence hoặc trạng thái Orca;
- ghi trạng thái/quyết định ngắn vào `.orca-team`;
- giữ task ở `QUEUED`, `BLOCKED`, `WAITING_USER`, `READY_FOR_VERIFICATION` hoặc `VERIFYING`;
- nhắc Lead gửi thông tin cho worker tại checkpoint an toàn;
- yêu cầu evidence phù hợp trước khi đi tiếp.

Hook không được:

- tự chạy shell command, script, Git, migration, deploy, restart, browser login hay request ghi ra bên ngoài;
- tự đọc/ghi token, cookie, credential hoặc dữ liệu nhạy cảm;
- tự mở nhiều worker, vượt capacity hoặc tạo vòng gọi hook;
- tự thay đổi model policy, Big Lead, quyền approval, ownership hay scope;
- làm yếu policy, rule cấp trên hoặc chỉ dẫn trực tiếp của người dùng.

Một hook có một điều kiện, một kết quả dừng rõ và không gọi hook khác. Hook phức tạp phải được tách thành các checklist nhỏ.

## Event chuẩn

| Event | Xảy ra khi | Dùng để |
|---|---|---|
| `on_init` | Khởi tạo/khôi phục team | Kiểm tra state, lease, model policy |
| `on_task_intake` | Nhận yêu cầu mới | Ghi task, ưu tiên, dependency |
| `before_worker_launch` | Sắp mở worker | Kiểm tra contract, ownership, model verified, capacity |
| `before_external_action` | Task cần Git/DB/deploy/remote write | Kiểm tra approval riêng |
| `before_done` | Muốn đóng task | Bắt First-Pass Gate và evidence |
| `on_model_failure` | Model/provider lỗi đã xác minh | Giữ checkpoint, dùng fallback verified |
| `on_rule_change` | Rule/policy/hook đổi | Ghi revision và lấy xác nhận checkpoint |
| `on_daily_report` | Người dùng hỏi tổng kết ngày | Chỉ dùng state/evidence đã có |

## Mẫu `PROJECT_HOOKS.md`

```markdown
# Hook dự án

Cập nhật gần nhất: chưa khởi tạo
Revision: H-001

Hook dưới đây là checklist, không phải script tự chạy.

## Hook đang hiệu lực

### H-001 — Kiểm tra trước khi mở worker
Event: before_worker_launch
Khi: task chuẩn bị từ READY sang ACTIVE
Bắt buộc:
- Có Task Contract và vùng ownership rõ.
- Model của route là verified trong MODEL_STATUS.md.
- Còn capacity, không có writer trùng vùng.
Nếu không đạt: giữ QUEUED/BLOCKED/WAITING_USER và ghi lý do.
Trạng thái: active

### H-002 — Không coi lần làm đầu là kết quả cuối
Event: before_done
Khi: worker báo đã hoàn thành phần việc
Bắt buộc:
- Task ở READY_FOR_VERIFICATION rồi VERIFYING.
- Có evidence đã kiểm tra và phần chưa kiểm tra.
- Với task rủi ro cao, có QA độc lập hoặc smoke evidence tách riêng.
Nếu không đạt: quay task về ACTIVE hoặc BLOCKED, không ghi DONE.
Trạng thái: active

## Hook đã ngừng

Chưa có.
```

## Khi người dùng đổi rule hoặc hook

Root Lead ghi revision, xác định task/owner bị ảnh hưởng, gửi update ở checkpoint an toàn và ghi acknowledgement vào `TEAM_STATE.md`. Task mới áp dụng ngay. Task đang chạy chỉ áp dụng sau acknowledgment, trừ khi người dùng yêu cầu dừng ngay vì rủi ro.

Lệnh điều phối:

- `$lead policy`: tóm tắt policy đang khóa những gì.
- `$lead hooks`: liệt kê hook active và điểm áp dụng.
- `$lead hook add ...`: chuyển yêu cầu rõ của người dùng thành hook dạng checklist, sau khi kiểm tra không xung đột cấp cao hơn.
- `$lead config check`: kiểm tra file điều phối, revision model, hook có conflict rõ hay không và route chuẩn bị dùng có model verified hay không. Đây là kiểm tra trạng thái, không tự chạy task dự án.
