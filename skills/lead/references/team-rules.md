# Quy tắc team

`TEAM_RULES.md` là sổ rule ngắn của dự án. Nó cho Root Lead ghi một chỉ dẫn rõ rồi yêu cầu mọi Domain Lead/worker bị ảnh hưởng áp dụng. Nó không phải transcript và không được dùng để vượt user approval. Đọc [rule và hook dự án](project-rules-and-hooks.md) nếu chỉ dẫn cần chạy tại một thời điểm cụ thể như trước khi mở worker hoặc trước DONE.

## Rule nào cần ghi

Ghi rule nếu nó thay đổi cách làm của hơn một task/owner. Ví dụ:

- Mọi thay đổi API/DTO/permission phải cập nhật Swagger, có test và có contract gửi FE.
- Đổi auth phải kiểm tra tương thích ngược.
- Release này không được đổi schema database.

Ràng buộc chỉ dành cho một task thì để trong Task Contract, trừ khi có khả năng ảnh hưởng task khác.

## Ai được đổi rule

| Vai trò | Được làm |
|---|---|
| Người dùng | Thêm, đổi, ngừng mọi rule; chỉ dẫn người dùng là cao nhất. |
| Root Lead | Ghi chỉ dẫn rõ của người dùng; thêm rule vận hành tạm để bảo vệ task đã nhận; cấp rule ID và thông báo owner ảnh hưởng. |
| Domain Lead | Đề xuất rule hoặc báo conflict; không được ghi/ngừng rule dự án hay làm yếu policy. |
| Worker | Tuân thủ rule, báo blocker/cần quyết định; không đổi rule. |

Rule không được làm yếu `TEAM_POLICY.md`, cho phép Git/DB/deploy/thay đổi ngoài chưa duyệt, lộ secret hoặc đổi scope người dùng đã chốt. Rule task có thể chặt hơn rule dự án. Hook chỉ là checklist dạng chữ; không được biến thành script tự chạy hoặc cấp thêm quyền.

## Thứ tự ưu tiên

1. Chỉ dẫn hiện tại của người dùng và yêu cầu an toàn nền tảng.
2. `TEAM_POLICY.md`.
3. Rule active trong `TEAM_RULES.md` và checklist active trong `PROJECT_HOOKS.md`.
4. Ràng buộc riêng của task.

Không giải quyết được conflict theo thứ tự trên thì dừng task ảnh hưởng thành `WAITING_USER` hoặc báo `NEED_DECISION`.

## Mẫu rule

```markdown
# Rule team

Cập nhật gần nhất: <ISO 8601 giờ địa phương>

## Rule đang hiệu lực

### R-001 — Bằng chứng cho thay đổi API

Nguồn: chỉ dẫn người dùng ngày <ngày> | quyết định Root Lead ngày <ngày>
Phạm vi: project | domain:<tên> | tasks:<ID>
Áp dụng cho: <owner/task>
Rule: Mọi thay đổi API, DTO, permission hoặc business-state phải cập nhật contract/Swagger, có test phù hợp và ghi FE contract khi FE bị ảnh hưởng.
Điểm kiểm tra: trước khi giao; trước DONE
Evidence bắt buộc: <OpenAPI/test/contract record>
Nếu bị chặn: báo BLOCKED hoặc NEED_DECISION; không đánh dấu DONE.
Trạng thái: active

## Rule đã ngừng

### R-000 — <tiêu đề>

Ngừng bởi: người dùng ngày <ngày>
Lý do: <vì sao>
```

Dùng ID tăng dần `R-001`, `R-002`... Ngừng rule vẫn giữ lịch sử, không xóa. Rule có hiệu lực ngay với task mới. Task đang chạy chỉ bắt buộc sau khi owner xác nhận tại checkpoint an toàn, trừ khi người dùng yêu cầu dừng ngay.

## Áp dụng rule

Khi người dùng nói: `Từ giờ mọi API phải cập nhật Swagger, có test và báo FE`, Root Lead:

1. Viết rule ngắn có phạm vi/evidence.
2. Ghi vào `TEAM_RULES.md` và phần rule trong `TEAM_STATE.md`.
3. Xác định task active/queued bị ảnh hưởng.
4. Thêm rule ID vào Task Contract bị ảnh hưởng.
5. Gửi update ngắn cho owner đang chạy, ghi acknowledgement tại checkpoint an toàn.
6. Kiểm tra evidence trước khi nhận `DONE`.

Rule checkpoint là điểm kiểm tra của Lead, không phải shell hook ẩn. Nếu cần test/lint command thật, ghi nó trong acceptance của task hoặc tooling dự án sau đúng approval. Hook chỉ được yêu cầu kiểm tra state/evidence, dừng trạng thái hay thông báo checkpoint; không tự chạy lệnh hoặc tự tạo worker.
