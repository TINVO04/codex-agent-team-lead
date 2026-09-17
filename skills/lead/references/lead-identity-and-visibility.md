# Một Big Lead, tên terminal rõ và team dễ quan sát

Tài liệu này trả lời ba câu hỏi: Big Lead là ai, Lead nào quản worker nào, và terminal thứ hai có được mở worker không.

## Chỉ một Big Lead

Terminal khởi tạo dự án thành Big Lead chỉ sau khi ghi active lease. Nhãn luôn bắt đầu bằng `00`:

```text
00 | BIG | <project> | RUN
```

Big Lead sở hữu queue dự án, ownership task, policy và quyền mở Domain Lead/worker. Mỗi lúc chỉ có một owner cho các việc này.

## Bắt buộc đặt tên terminal trong Orca

Big Lead đổi tên terminal của chính mình trước khi nói khởi tạo xong:

```powershell
orca terminal rename --title "00 | BIG | <PROJECT> | RUN" --json
```

Nếu Orca không tự xác định terminal hiện tại, dùng handle thật do Orca trả về:

```powershell
orca terminal rename --terminal <runtime-handle> --title "00 | BIG | <PROJECT> | RUN" --json
```

Sau khi Orca trả handle của terminal mới, đổi tên theo cùng quy tắc ngay:

```text
00 | BIG | MEU-HIRE-FE | RUN
10 | LEAD-ADMIN | T-100 | RUN
11 | WORKER-ADMIN-API | T-101.1 | RUN
12 | WORKER-ADMIN-UI | T-101.2 | RUN
19 | QA-ADMIN | T-101.QA | CHECK
90 | VIEW | MEU-HIRE-FE
```

Big Lead chỉ gọi `orca terminal rename` sau khi Lead/worker mở thành công và trước khi ghi role active trong dashboard. Nếu đổi tên lỗi, vẫn giữ task/worker chạy, ghi lỗi và hiện role đúng trong `TEAM_DASHBOARD.md`; không đoán handle hoặc đổi nhầm terminal.

## Khi mở terminal Codex thứ hai trong cùng dự án

Khi người dùng gọi `$lead` hoặc `$lead init` ở terminal khác:

1. Đọc `LEAD_LEASE.md`, `TEAM_STATE.md`, `TEAM_DASHBOARD.md` trước.
2. Dùng inventory Orca live kiểm tra Run/terminal của Big Lead đã ghi. Owner còn sống vẫn là Big Lead.
3. Nếu Big Lead đang sống, đổi terminal mới thành `90 | VIEW | <project>` khi có handle. Viewer chỉ dùng `$lead status`, không mở worker, không đổi owner, không thành Big Lead thứ hai.
4. Chỉ thay Big Lead khi Orca chứng minh Big Lead cũ đã lỗi/dừng, hoặc người dùng xác nhận cũ không dùng được và gọi `$lead take over`. Ghi transfer trước khi mở worker.

Hai terminal init cùng lúc là race condition mà Markdown không thể khóa hoàn toàn. Khi đó cả hai không được mở worker đến khi một terminal thấy lease active duy nhất hoặc người dùng chọn Big Lead. Ownership lock vẫn ngăn writer bị cố ý nhân đôi.

## File lease

`LEAD_LEASE.md` là bản ghi ownership ngắn, không phải trình theo dõi process nền:

```markdown
# Lease Big Lead

Trạng thái: ACTIVE
Nhãn Big Lead: 00 | BIG | <project> | RUN
Chế độ: Orca
Orca Run: <run ID hoặc unbound>
Terminal Lead: <runtime handle hoặc unbound>
Bắt đầu: <thời gian>
Xác nhận gần nhất: <thời gian và bằng chứng>

Chỉ Big Lead này được xếp lịch worker. Viewer cần recovery đã xác minh hoặc người dùng takeover rõ ràng để thành Big Lead.
```

Các trạng thái hợp lệ: `UNASSIGNED`, `ACTIVE`, `VIEWER_ONLY`, `RECOVERY_REQUIRED`, `TRANSFERRED`. Không ghi đè `ACTIVE` chỉ vì có terminal thứ hai mở ra.

## Mẫu tên

Tên là nhãn cho người đọc, không xác định model và không thay cho terminal/Dispatch thật của Orca.

| Vai trò | Nhãn terminal | Ý nghĩa |
|---|---|---|
| Big Lead | `00 | BIG | <project> | RUN` | Điều phối duy nhất toàn dự án |
| Domain Lead | `10 | LEAD-ADMIN | T-100 | RUN` | Quản nhánh Admin; nhánh khác dùng `20`, `30`... |
| Worker | `11 | WORKER-ADMIN-API | T-101.1 | RUN` | Worker thuộc Lead Admin, giữ số trong nhóm đó |
| QA | `19 | QA-ADMIN | T-101.QA | CHECK` | Kiểm tra/test cho nhánh |
| Viewer | `90 | VIEW | <project>` | Chỉ xem, không được xếp lịch |

Dùng domain code ngắn, ổn định như `ADMIN`, `AUTH`, `JOBS`, `REPORTS`, `PAYMENT`, `BE`, `FE`. Không dùng lại số role đang live cho role khác. State word hợp lệ: `RUN`, `WAIT`, `BLOCK`, `CHECK`, `DONE`, `MODEL_ERROR`, `RECOVERING`.

## Dashboard

Mỗi dự án dùng `.orca-team/TEAM_DASHBOARD.md` như bản đồ team bên cạnh tab terminal:

```markdown
# Bảng theo dõi team

Cập nhật: <thời gian>
Dự án: <project>

00 | BIG | <project> | RUN
|
|- 10 | LEAD-ADMIN | T-100 | RUN
|  |- 11 | WORKER-ADMIN-API | T-101.1 | RUN
|  |- 12 | WORKER-ADMIN-UI | T-101.2 | BLOCK
|  `- 19 | QA-ADMIN | T-101.QA | WAIT
|
`- 20 | LEAD-AUTH | T-200 | RUN
   |- 21 | WORKER-AUTH-API | T-201.1 | RUN
   `- 22 | WORKER-AUTH-UI | T-201.2 | CHECK

## Đọc nhanh

| Nhãn | Owner / việc | Trạng thái | Điểm kiểm tra tiếp |
|---|---|---|---|
| 12 | Giao diện Admin | BLOCK | Chờ API contract T-101 |
| 22 | Giao diện Auth | CHECK | Chạy test tập trung |
```

Cập nhật khi role bắt đầu, state thực sự đổi, worker được thay hoặc role bị thu gọn. Terminal im lặng không đủ để khẳng định có thay đổi.

## Khi Domain Lead kết thúc

Khi nhánh không còn task `READY`/`ACTIVE`, Big Lead settle worker, đánh dấu Domain Lead `DONE` trên dashboard và trả queue còn lại về Root. Có thể giữ dòng lịch sử ngắn, nhưng không dùng lại số role cho tới khi dòng cũ đã đóng rõ ràng.
