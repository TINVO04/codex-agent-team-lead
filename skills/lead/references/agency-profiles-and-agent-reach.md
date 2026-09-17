# Vai trò Agency và Agent-Reach

Dùng tài liệu này khi khởi tạo năng lực cho dự án, chọn vai trò chuyên môn cho worker, team thiếu vai trò phù hợp, hoặc task cần tìm thông tin công khai bên ngoài.

Mục tiêu là giúp worker có đúng chuyên môn mà không tạo thêm một hệ điều phối cạnh tranh với Orca. Big Lead/Lead phụ vẫn chỉ điều phối; Agency Agents chỉ là nguồn tham khảo vai trò và Agent-Reach chỉ là công cụ tìm dữ liệu công khai.

## Hai thứ này khác nhau

| Thành phần | Dùng để làm gì | Không được làm gì |
|---|---|---|
| Agency Agents | Chọn một vai trò chuyên môn cho worker, ví dụ API Tester hay Database Optimizer. | Không tạo Lead mới, không tự mở terminal, không tự đổi model/quyền hay tự sửa dự án. |
| Agent-Reach | Hỗ trợ Research Worker tìm/đọc nguồn công khai khi nguồn local và tài liệu chính thức chưa đủ. | Không là nguồn kết luận duy nhất, không tự cài tool, không dùng tài khoản/cookie hay gửi dữ liệu riêng ra ngoài. |

Nguồn Agency ưu tiên là repository gốc `msitarzewski/agency-agents`. Chỉ đọc profile bằng URL/revision cụ thể mà worker đã ghi trong registry; không chép nguyên bộ profile dài vào task. Nguồn Agent-Reach ưu tiên là repository gốc `Panniantong/Agent-Reach` và chỉ dùng khi công cụ đã được người dùng cho phép cài/sử dụng.

## Khởi tạo năng lực cho dự án

Khi `$lead init` đã tạo state và Big Lead đã có lease, Lead tạo hoặc dùng lại một worker chỉ-đọc `CAPABILITY-BASELINE` nếu Orca còn slot và dự án có context để xem. Worker chỉ đọc manifest, README, cấu trúc module, tài liệu kiến trúc và yêu cầu người dùng cần thiết để trả lời:

1. Dự án dùng stack/domain gì?
2. Các vai trò chuyên môn nào thường cần trong dự án này?
3. Vai trò nào là `baseline` đã có sẵn, vai trò nào chỉ là candidate?
4. Có rủi ro hoặc câu hỏi nào cần Research Worker trước khi chọn không?

Worker ghi kết quả vào `AGENCY_PROFILE_REGISTRY.md`. Lead không tự quét source hay duyệt catalog dài. Nếu Orca chưa trả worker thật, registry giữ `baseline pending`; Lead không đoán đã chọn xong vai trò.

Baseline chỉ là danh sách có thể dùng, không tạo terminal và không mở worker sẵn. Ví dụ:

| Dấu hiệu dự án | Vai trò baseline thường phù hợp |
|---|---|
| API/backend + dữ liệu | Backend Architect, API Tester, Database Optimizer, Identity & Access Engineer |
| Web/FE | Frontend Developer, UI Designer, Accessibility Auditor, Test Automation Engineer |
| Hệ thống nhạy cảm về quyền/dữ liệu | Application Security Engineer, Privacy Engineer, Code Reviewer |
| UI/kiến trúc/thư viện mới | UX Researcher hoặc Research Synthesist trước worker triển khai |

## Chọn vai trò cho từng yêu cầu mới

Lead không tự mở web để tìm. Lead chỉ đọc `AGENCY_PROFILE_REGISTRY.md`, Task Contract và `TEAM_STATE.md`, rồi dùng thứ tự sau:

1. Vai trò `approved` của chính dự án có đúng task và còn phù hợp.
2. Vai trò `baseline` đã có card ngắn trong registry.
3. Nếu chưa có, giao worker `CAPABILITY-SCOUT` chỉ-đọc tìm profile phù hợp trong Agency gốc.
4. Nếu Agency không có hoặc câu hỏi là về công nghệ/cách làm hơn là vai trò, giao `RESEARCH-WORKER` tìm evidence công khai theo Research Gate; chỉ khi được phép mới dùng Agent-Reach.

Không tìm role mới cho task hẹp đã có pattern rõ. Không dùng nhiều role chỉ vì tên nghe gần giống. Một worker chỉ nhận một role chính; role phụ chỉ thêm khi acceptance thật sự cần nó.

## Card vai trò và vòng đời

Skill-scout phải đọc đủ profile dự định dùng, kiểm tra nguồn/revision và ghi một card `AR-###` ngắn. Card không sao chép prompt, code hay "personality" dài của bên thứ ba.

```markdown
### AR-001 — <tên vai trò>
Nguồn: <URL repository/file gốc>
Revision đã kiểm tra: <commit SHA hoặc version/date>
Phù hợp vì: <task/domain cụ thể>
Dùng cho: <module/task và kết quả cần có>
Checklist áp dụng: <3-5 nguyên tắc thật sự liên quan>
Không được cấp quyền: <Git, cài tool, DB, deploy, credential... đều không tự có>
Trạng thái: <baseline | candidate | task-approved | approved | active | rejected | retired>
Evidence: <brief/test/review chứng minh role hữu ích hoặc lý do loại>
```

`task-approved` được phép khi profile là hướng dẫn đọc được toàn bộ, nguồn gốc rõ, không yêu cầu script/hook/package/login/quyền ngoài và card đã thu hẹp đúng task. Đây chỉ là tham khảo cho **một** worker; không phải cài agent mới. Khi task xong, Lead đổi thành `approved` nếu evidence cho thấy có thể dùng lại, hoặc `retired` nếu chỉ hợp task đó. Profile cần cài đặt, script, quyền ngoài hoặc có chỉ dẫn mâu thuẫn policy phải chuyển `user approval needed`/`rejected`.

Mọi policy dự án, rule người dùng, quyền Git/DB/deploy, ownership, model route, Quality Gate và Preview Gate luôn cao hơn profile Agency. Profile không được tự quyết định scope sản phẩm hoặc cho phép worker mở/đóng worker khác.

## Dùng Agent-Reach an toàn

Agent-Reach là đường tìm nguồn **tùy chọn**, không phải rule bắt buộc cho mọi URL hay mọi nghiên cứu. Research Worker ưu tiên source local, tài liệu chính thức và standard trước. Chỉ dùng Agent-Reach khi nó thực sự giúp lấy nguồn công khai mà các đường này chưa đủ.

Trước khi dùng, Task Contract phải ghi `External research route` là `Agent-Reach public-only`, câu hỏi hẹp và dữ liệu được phép đưa vào query. Research Worker chỉ được dùng các kênh công khai, không đăng nhập, ví dụ đọc webpage public, RSS, YouTube public hoặc GitHub public. Mỗi kết luận vẫn phải trỏ về nguồn gốc, không chỉ trỏ về kết quả tìm kiếm.

Mặc định cấm:

- cài Agent-Reach, package, plugin, browser extension hoặc dependency mới khi chưa được người dùng duyệt;
- dùng cookie, Chrome profile, token, GitHub đăng nhập, proxy, tài khoản mạng xã hội hoặc API key;
- gửi source nội bộ, tên khách hàng, URL private, credential, log chưa lọc, dữ liệu DB hay thông tin production vào query/URL/service ngoài;
- đăng bài, nhắn tin, like, tạo issue/PR hoặc bất kỳ thao tác ghi nào trên nền tảng bên ngoài.

Nếu Agent-Reach chưa có, không tự cài. Ghi `user approval needed` cùng danh sách thay đổi máy dự kiến. Nếu đã được cài/duyệt trước, vẫn chỉ dùng đúng kênh public trong Task Contract và dừng ngay khi tool đòi login hoặc dữ liệu nhạy cảm.

## Liên hệ với Task Contract và báo cáo

Worker dùng role Agency phải ghi `AR-###`, phạm vi role và checklist rút gọn trong Task Contract. Worker dùng Agent-Reach phải ghi nguồn, query an toàn ở mức khái quát và kết quả vào `RN-###`; không ghi secret, cookie hay câu lệnh chứa credential.

Khi báo người dùng, chỉ nói kết quả đơn giản, ví dụ:

> Đang làm: phần này cần chuyên môn thanh toán. Team đã chọn vai trò phù hợp cho worker và chỉ áp dụng trong phần chống giao dịch trùng. Không cài thêm công cụ hay dùng dữ liệu riêng.

Hoặc:

> Chưa thể tiếp tục: để nghiên cứu nguồn bên ngoài, team cần cài một công cụ mới. Công cụ này sẽ thay đổi máy và có thể gửi từ khóa tìm kiếm ra dịch vụ bên ngoài. Bạn có đồng ý không?
