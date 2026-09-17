# Orca Codex Team Lead

`$lead` là quy trình điều phối nhiều agent **chỉ dùng cho Codex chạy trong Orca**. Nó biến terminal Codex đầu tiên của dự án thành Big Lead, có thể tạo Lead phụ/worker, đổi tên từng terminal để dễ nhìn, giữ quyền sở hữu code rõ ràng và báo cáo ngắn gọn cho người dùng.

Repository này không hỗ trợ Codex chạy độc lập ngoài Orca. Orca là phần bắt buộc để theo dõi worker, đổi tên terminal, trao đổi giữa agent và khôi phục khi terminal/model lỗi.

## Quy trình làm được gì

- Có đúng một Big Lead cho mỗi dự án.
- Có Lead phụ khi một mảng công việc đủ lớn, ví dụ `ADMIN`, `AUTH`, `JOBS`.
- Có worker lập trình, QA và worker kiểm tra cuối.
- Tự tạo worker cho việc rõ ràng, độc lập và không đụng vùng code worker khác đang sửa.
- Big Lead/Lead phụ chỉ điều phối và kiểm tra; mọi việc nghiên cứu hoặc sửa file dự án phải thuộc một worker terminal nhìn thấy được.
- Giữ danh sách việc, quyền sở hữu code, quy tắc và tình trạng team trong `.orca-team`.
- Đổi model có kiểm soát khi worker/Lead thật sự lỗi.
- Trao đổi hợp đồng API ngắn gọn giữa Lead Backend và Lead Frontend.
- Tự tạo danh sách vai trò chuyên môn phù hợp với dự án từ Agency Agents, rồi chọn đúng vai trò cho từng worker khi có yêu cầu mới.
- Khi thiếu vai trò mới, tạo worker chuyên tìm role/skill phù hợp thay vì để Lead tự ôm việc.
- Dùng Agent-Reach có kiểm soát để Research Worker tìm nguồn công khai khi thật sự cần.
- Bắt buộc nghiên cứu trước với việc UI/UX, sáng tạo, luồng người dùng, công nghệ mới hoặc phần rủi ro cao.
- Có checklist riêng cho API, UI, database, tích hợp và review trước khi báo xong.
- Có bước xem trước ngắn để người dùng chốt hướng trước khi làm màn hình/luồng lớn.
- Có `$lead audit` để kiểm tra Lead/worker có đang vận hành đúng vai trò hay không.
- Mọi agent nói trực tiếp với người dùng đều dùng tiếng Việt ngắn gọn, dễ hiểu.
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
$lead audit                              # Kiểm tra việc nào có worker thật và Lead có giữ đúng vai trò không
$lead capability <nhu cầu>               # Tìm skill/cách làm phù hợp, chưa tự cài khi bạn chưa duyệt
$lead roles                               # Xem các vai trò Agency đang phù hợp, đang dùng hoặc đang chờ kiểm tra
$lead research <chủ đề>                  # Tạo bản nghiên cứu ngắn trước một quyết định quan trọng
$lead preview <chủ đề>                   # Chuẩn bị bản xem trước để bạn chốt hướng UI/UX lớn
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

Nếu bạn giao một việc có sửa code/file dự án mà không thấy worker terminal riêng, hãy dùng:

```text
$lead audit
```

Lead phải báo rõ việc đó đang chờ gì; Lead không được tự làm thay worker để cho nhanh. Quét file, tìm web, đọc tài liệu sâu, debug, chạy test và tìm skill cũng là việc của worker. Chỉ các việc như hỏi trạng thái, thêm rule hoặc trả lời ngắn mới không cần worker.

## Vai trò Agency và tìm nguồn bên ngoài

Ngay sau khi bạn khởi tạo team, Big Lead không tự làm code. Nếu Orca còn chỗ, Lead tạo một worker chỉ-đọc để xem dự án thuộc loại gì, rồi lập danh sách vai trò phù hợp trong:

```text
.orca-team/AGENCY_PROFILE_REGISTRY.md
```

Ví dụ dự án API có thể có các vai trò nền như thiết kế backend, kiểm tra API, tối ưu database và kiểm tra quyền. Dự án FE có thể có vai trò frontend, UI/UX, accessibility và test giao diện. Danh sách này chỉ để chọn người phù hợp khi có việc; nó **không** tự mở sẵn nhiều terminal.

Khi bạn giao yêu cầu mới, Big Lead làm theo thứ tự:

```text
Vai trò dự án đã duyệt
        ↓ chưa có
Worker tìm role phù hợp trong Agency Agents
        ↓ vẫn chưa đủ
Research Worker tìm tài liệu/nguồn công khai
        ↓
Worker triển khai nhận card vai trò ngắn và làm đúng phần việc
```

Agency Agents chỉ là bộ hướng dẫn nghề nghiệp cho worker. Nó không tạo một Big Lead khác, không tự mở terminal, không tự đổi model và không tự có quyền Git, database, deploy hay dùng tài khoản.

Agent-Reach chỉ được Research Worker dùng để tìm/đọc nguồn **công khai** nếu công cụ đã có hoặc bạn đã duyệt cài. Mặc định nó không được dùng cookie, tài khoản đăng nhập, token, Chrome profile, proxy, dữ liệu dự án riêng hay bất kỳ thao tác đăng/gửi/tạo gì ở bên ngoài. Nếu cần cài thêm công cụ hoặc dùng đăng nhập, Lead sẽ hỏi bạn trước.

## Khi nào Lead tìm hiểu trước

Với việc nhỏ, rõ và đã có cách làm trong dự án, worker làm trực tiếp. Với UI/UX, dashboard, mobile, nội dung, luồng người dùng, thư viện/công nghệ mới, kiến trúc, bảo mật, hiệu năng hoặc tích hợp lớn, Lead tạo bản nghiên cứu ngắn trước khi giao phần quyết định cho worker.

Kết quả nghiên cứu được lưu trong `.orca-team/RESEARCH_NOTES/`, để những lần sau không phải tìm lại từ đầu. Khi cần role/skill mới, worker chỉ đề xuất; Lead kiểm tra nguồn, nội dung và rủi ro trước. Mặc định Lead phải hỏi bạn trước khi tải, cài hoặc chạy skill/công cụ mới.

## Khi nào bạn cần chốt trước

Với màn hình mới, đổi giao diện lớn, menu/điều hướng, hoặc thay đổi luồng người dùng quan trọng, Lead gửi bạn bản tóm tắt ngắn trước khi worker làm phần quyết định hướng. Bản tóm tắt chỉ gồm mục tiêu, đề xuất, ảnh hưởng trên mobile/các trạng thái và đúng một điều cần bạn chốt.

Trước khi báo xong, Lead dùng `.orca-team/QUALITY_GATES.md` để kiểm tra đúng loại việc: API, UI/UX, dữ liệu, tích hợp hoặc review. Vì vậy “build chạy được” không tự động có nghĩa là task đã xong.

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
  references/              Quy tắc giao việc, Agency role, Agent-Reach, skill, nghiên cứu, chất lượng, audit, model và khôi phục
  scripts/bootstrap-project.ps1
```

## Giấy phép

MIT. Xem [LICENSE](LICENSE).
