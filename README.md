# Orca Codex Team Lead

`$lead` là quy trình điều phối nhiều agent **chỉ dùng cho Codex chạy trong Orca**. Nó biến terminal Codex đầu tiên của dự án thành Big Lead, có thể tạo Lead phụ/worker, đổi tên từng terminal để dễ nhìn, giữ quyền sở hữu code rõ ràng và báo cáo ngắn gọn cho người dùng.

Repository này không hỗ trợ Codex chạy độc lập ngoài Orca. Orca là phần bắt buộc để theo dõi worker, đổi tên terminal, trao đổi giữa agent và khôi phục khi terminal/model lỗi.

## Quy trình làm được gì

- Có đúng một Big Lead cho mỗi dự án.
- Có Lead phụ khi một mảng công việc đủ lớn, ví dụ `ADMIN`, `AUTH`, `JOBS`.
- Có worker lập trình, QA và worker kiểm tra cuối.
- Tự tạo worker cho việc rõ ràng, độc lập và không đụng vùng code worker khác đang sửa.
- Giữ danh sách việc, quyền sở hữu code, quy tắc và tình trạng team trong `.orca-team`.
- Đổi model có kiểm soát khi worker/Lead thật sự lỗi.
- Trao đổi hợp đồng API ngắn gọn giữa Lead Backend và Lead Frontend.
- Không tự chạy Git, migration database, restart, deploy hay thay đổi bên ngoài khi chưa được người dùng duyệt.

## Điều kiện dùng

1. Cài Orca và dùng terminal Codex bên trong Orca.
2. Orca phải đang chạy và có thể mở terminal/worker.
3. Chỉ cài một bản skill `lead` cho Orca để không xuất hiện hai dòng trùng tên trong danh sách skill.

## Cài đặt cho Orca

Clone repository này, sau đó copy thư mục `skills/lead` vào:

```text
%USERPROFILE%\.agents\skills\lead
```

Khởi động lại Orca hoặc mở một terminal Codex mới trong Orca. Trong ô chat Codex, gõ `$`, chọn `Orca Codex Team Lead`, rồi gửi:

```text
Khởi tạo team cho dự án này.
```

Không gõ `/lead`, vì `/` là nhóm lệnh có sẵn của Codex Terminal. Có thể gõ `$lead Khởi tạo team cho dự án này.` nếu skill đã được chọn.

## Dùng hằng ngày

```text
$lead Khởi tạo team cho dự án này.       # Dùng một lần đầu tiên trong mỗi dự án
$lead <yêu cầu của bạn>                  # Giao yêu cầu cho Big Lead
$lead status                             # Xem tình hình team
$lead recover                            # Dùng sau khi Orca bị khởi động lại
$lead take over                          # Chỉ khi Big Lead cũ đã lỗi/dừng hoặc bạn xác nhận nó không còn dùng được
$lead rules                              # Xem quy tắc đang áp dụng
```

## Nhìn team qua tên terminal

Khi khởi tạo xong, terminal em đang dùng được Orca đổi tên ngay thành Big Lead:

```text
00 | BIG | MEU-HIRE-FE | RUN
```

Khi Big Lead tạo Lead phụ và worker, Orca cũng đổi tên các terminal mới ngay sau khi terminal đó được tạo:

```text
10 | LEAD-ADMIN | T-100 | RUN
11 | WORKER-ADMIN-API | T-101.1 | RUN
12 | WORKER-ADMIN-UI | T-101.2 | RUN
19 | QA-ADMIN | T-101.QA | CHECK
20 | LEAD-AUTH | T-200 | RUN
21 | WORKER-AUTH-API | T-201.1 | RUN
```

Nhìn số đầu là biết quan hệ: `11`, `12`, `19` là worker của `10 | LEAD-ADMIN`; `21` thuộc `20 | LEAD-AUTH`.

Nếu mở thêm terminal trong cùng dự án rồi gọi `$lead`, terminal đó không trở thành Big Lead thứ hai. Nó được đặt tên:

```text
90 | VIEW | MEU-HIRE-FE
```

Terminal xem có thể chạy `$lead status`, nhưng không được tự mở worker, giao việc hoặc đổi quyền sở hữu task. Chỉ Big Lead mới tạo Lead phụ/worker. Khi Big Lead đã thật sự lỗi hoặc dừng, terminal khác mới được takeover sau khi kiểm tra Orca hoặc có xác nhận của người dùng.

Ngoài các tab terminal, Big Lead duy trì `.orca-team/TEAM_DASHBOARD.md` để nhìn sơ đồ toàn team và tình trạng từng nhánh công việc.

## Chính sách model mặc định

| Vai trò / loại việc | Model chính | Mức suy nghĩ | Model dự phòng |
|---|---|---|---|
| Big Lead / Lead phụ | `gpt-5.6-terra` | `xhigh` | `qwen3.8-max-0902` |
| Worker việc khó | `qwen3.8-max-0902` | `high` | DeepSeek, sau đó GLM |
| Worker việc bình thường | `deepseek-v4.1-flash` | `medium` | Qwen, sau đó GLM |
| Worker việc nhỏ | `glm-5.3-flash` | `low` | DeepSeek, sau đó Qwen |
| Kiểm tra cuối | `qwen3.8-max-0902` | `high` | DeepSeek, sau đó GLM |

Trước khi giao việc thật, sửa `.orca-team/TEAM_POLICY.md` nếu Orca/Codex của bạn dùng tên model khác. Lead ghi lại model yêu cầu và model chạy thật.

Khi worker bị lỗi model, Big Lead/Lead phụ chỉ tạo worker thay thế sau khi Orca xác nhận worker cũ đã dừng/lỗi. Code đã làm được giữ lại, vùng code tiếp tục được khóa và worker mới làm tiếp cùng task bằng model dự phòng kế tiếp. Vì thế không có hai worker cùng sửa một vùng code.

## Cấu trúc repository

```text
skills/lead/
  SKILL.md                 Quy trình Big Lead, Lead phụ và worker trong Orca
  agents/openai.yaml       Tên hiển thị trong Codex của Orca
  references/              Quy tắc giao việc, model, khôi phục và nhận diện terminal
  scripts/bootstrap-project.ps1
```

## Giấy phép

MIT. Xem [LICENSE](LICENSE).
