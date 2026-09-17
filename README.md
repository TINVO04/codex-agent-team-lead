# Codex Agent Team Lead

`/lead` biến Codex hoặc Codex chạy trong Orca thành một Lead cho dự án. Lead ghi nhớ các việc đang làm, giao đúng việc cho worker, chỉ chạy song song khi không đụng nhau, và cuối cùng báo lại cho người dùng bằng tiếng Việt ngắn gọn, dễ hiểu.

Skill dùng được cho dự án mới lẫn dự án đang làm. Khi khởi tạo, nó tạo thư mục `.orca-team` nhỏ ngay trong dự án để lưu danh sách việc, quy tắc, quyết định và thông tin cần thiết khi khôi phục sau lỗi. Repository này không chứa source dự án, token, mật khẩu hay cấu hình database.

## Skill làm được gì

- Có Big Lead, Lead phụ khi thật sự cần, worker lập trình, QA và worker kiểm tra cuối.
- Nhận thêm yêu cầu mới khi những việc cũ vẫn đang chạy.
- Không để hai worker cùng sửa một vùng code.
- Khôi phục khi worker hoặc Lead bị lỗi model/terminal.
- Trao đổi hợp đồng API ngắn gọn giữa Lead dự án Backend và Frontend.
- Báo cáo cho người dùng bằng ngôn ngữ đơn giản, không kéo dài lan man.
- Không tự chạy Git, migration database, restart, deploy hay thay đổi bên ngoài khi chưa có người dùng duyệt.

## Cài cho Codex

Cách đơn giản nhất là mở Codex và gửi câu này:

```text
Install the skill from https://github.com/TINVO04/codex-agent-team-lead/tree/main/skills/lead
```

Codex sẽ cài skill vào thư mục skills của nó. Mở một turn mới, vào dự án cần làm, rồi gõ:

```text
/lead init
```

Nếu muốn cài thủ công trên Windows, clone repository này rồi copy thư mục `skills/lead` vào:

```text
%USERPROFILE%\.codex\skills\lead
```

## Cài cho Orca

Clone repository này, sau đó copy cùng thư mục `skills/lead` vào:

```text
%USERPROFILE%\.agents\skills\lead
```

Khởi động lại terminal/session Orca, mở dự án cần làm rồi gõ `/lead init`.

Nếu cùng một máy vừa dùng Codex vừa dùng Orca, hãy cài thư mục `lead` vào cả hai vị trí trên.

## Dùng hằng ngày

```text
/lead init                 # Dùng một lần đầu tiên trong mỗi dự án
/lead <yêu cầu của bạn>    # Giao yêu cầu cho Lead
/lead status               # Xem tình hình ngắn gọn
/lead recover              # Dùng sau khi Codex hoặc Orca bị khởi động lại
/lead rules                # Xem các quy tắc đang áp dụng
```

Lead không tự tạo worker chỉ vì có việc. Worker chỉ được tạo khi việc đã rõ ràng, có cách kiểm tra kết quả, có vùng code riêng và không đụng vào phần worker khác đang sửa.

## Chính sách model

Chính sách model mặc định trong repository này là cấu hình của tác giả:

| Vai trò / loại việc | Model chính | Mức suy nghĩ | Model dự phòng |
|---|---|---|---|
| Big Lead / Lead phụ | `gpt-5.6-terra` | `xhigh` | `qwen3.8-max-0902` |
| Worker việc khó | `qwen3.8-max-0902` | `high` | DeepSeek, sau đó GLM |
| Worker việc bình thường | `deepseek-v4.1-flash` | `medium` | Qwen, sau đó GLM |
| Worker việc nhỏ | `glm-5.3-flash` | `low` | DeepSeek, sau đó Qwen |
| Kiểm tra cuối | `qwen3.8-max-0902` | `high` | DeepSeek, sau đó GLM |

Trước khi giao việc thật, hãy sửa `.orca-team/TEAM_POLICY.md` được tạo trong dự án nếu Codex của bạn không có các model trên. Chính sách của dự án đang làm là nguồn quyết định cuối cùng. Lead luôn ghi lại model yêu cầu và model chạy thật, không tự nhận là đã chạy đúng model khi chưa kiểm tra được.

Khi model của worker lỗi, Lead chỉ đổi worker sau khi xác nhận worker cũ thật sự đã dừng/lỗi. Code đã làm được giữ lại, vùng code đó vẫn được khóa, sau đó Lead mở đúng một worker mới cho cùng task với model dự phòng tiếp theo. Vì vậy không có hai worker cùng sửa một phần code. Nếu Lead phụ lỗi, Big Lead thay Lead phụ; nếu Big Lead không còn hoạt động, mở Big Lead mới rồi dùng `/lead recover`.

## Cấu trúc repository

```text
skills/lead/
  SKILL.md                 Quy trình chính của Lead
  agents/openai.yaml       Tên và mô tả hiển thị trong Codex
  references/              Quy tắc giao việc, khôi phục, báo cáo và phối hợp
  scripts/bootstrap-project.ps1
```

## Giấy phép

MIT. Xem [LICENSE](LICENSE).
