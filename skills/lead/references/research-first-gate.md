# Cổng nghiên cứu trước

Dùng cổng này trước khi triển khai nếu bằng chứng/ví dụ hiện hành có thể làm quyết định tốt hơn. Nó tránh hai lỗi: đoán mò ở quyết định quan trọng, hoặc tìm kiếm mãi khi task đã rõ.

Nghiên cứu trước khác với tìm skill: mục tiêu là học đủ để chọn hướng đúng. Chỉ đánh giá skill nếu team thực sự cần một quy trình chuyên biệt dùng lại được.

## Phân loại task một lần

Lead ghi một cấp vào Task Contract:

| Cấp | Dùng khi | Kết quả cần có |
|---|---|---|
| `routine` | Sửa/triển khai hẹp, pattern local rõ, ít ảnh hưởng thiết kế/rủi ro. | Làm theo context dự án. |
| `research-first` | UI/UX, hình ảnh, nội dung, luồng người dùng, thư viện/framework mới, kiến trúc, hiệu năng, bảo mật hoặc tích hợp cần evidence hiện hành. | Brief ngắn trước phần triển khai phụ thuộc nó. |
| `research-deep` | Ảnh hưởng rộng đến sản phẩm, chi phí, an toàn, tuân thủ hoặc khó quay lại. | Kế hoạch evidence, brief so sánh và Lead chốt hướng. |

Mặc định `research-first` cho màn hình/luồng mới, dashboard, redesign mobile/responsive, brand/visual, nội dung ảnh hưởng tin cậy/chuyển đổi, vendor/framework mới, auth, payment, file storage, public API, tối ưu hiệu năng đáng kể hoặc task có nhiều hướng hợp lý.

Không gắn research-first cho typo, lỗi cục bộ, pattern đã biết hoặc thay đổi cơ học chỉ để thêm quy trình.

## Brief nghiên cứu

Task nghiên cứu là chỉ-đọc, trừ khi contract nói khác. Worker nghiên cứu ghi một file `RN-###-short-topic.md` trong `.orca-team/RESEARCH_NOTES/` theo mẫu sẵn có.

Brief phải trả lời:

1. Dự án cần quyết định chính xác điều gì?
2. Code, yêu cầu sản phẩm và người dùng hiện có đang đòi hỏi gì?
3. Nguồn đáng tin nào đã được kiểm tra?
4. Nguyên tắc/ràng buộc thực tế nào áp dụng?
5. Đã cân nhắc lựa chọn nào và đánh đổi gì?
6. Nên chọn hướng nào cho dự án và vì sao?
7. Worker triển khai/QA phải chứng minh điều gì sau đó?

Brief phải ngắn để worker dùng được. Link và kết luận chắt lọc tốt hơn chép nguyên trang web.

## Thứ tự nguồn

1. Rule, design system, yêu cầu, user research, code pattern và research note sẵn có của dự án.
2. Tài liệu chính thức của sản phẩm/framework/platform.
3. Tiêu chuẩn và hướng dẫn được công nhận, ví dụ accessibility/bảo mật.
4. Một số ít sản phẩm/ví dụ công khai nổi tiếng để học nguyên tắc tương tác/thông tin.
5. Nguồn chuyên gia uy tín khi các nguồn trên chưa giải quyết câu hỏi.

Agent-Reach chỉ là một đường lấy nguồn công khai ở bước 4–5, không đứng trên tài liệu chính thức và không phải lựa chọn mặc định. Chỉ Research Worker được dùng nó khi Task Contract ghi `Agent-Reach public-only`; xem [vai trò Agency và Agent-Reach](agency-profiles-and-agent-reach.md). Mỗi kết luận quan trọng phải dẫn tới nguồn gốc đã đọc, không chỉ dẫn tới kết quả tìm kiếm/tóm tắt của công cụ.

Nghiên cứu visual/design phải xem hierarchy, mật độ thông tin, trạng thái, responsive và accessibility; không chỉ nhìn màu/screenshot. Nghiên cứu kỹ thuật phải xem compatibility, maintenance, bảo mật, chi phí vận hành, lỗi và khả năng migration/rollback.

## Ranh giới an toàn

- Học nguyên tắc, không sao chép code, asset, chữ hay toàn bộ thiết kế bên thứ ba.
- Không đưa source riêng, token, dữ liệu khách hàng, log chưa lọc hay chi tiết DB production vào web query/issue/service ngoài.
- Upload, login, công cụ trả phí, plugin, crawler, script hay API ngoài vẫn theo rule user approval và Skill Discovery riêng.
- Agent-Reach chưa được cài/duyệt là `user approval needed`. Khi đã có, chỉ dùng kênh public không đăng nhập; không gửi query chứa source nội bộ, tên khách hàng, URL private, token, log chưa lọc hay dữ liệu production.
- Worker chỉ đọc brief và nguồn được contract cho phép. Cần tìm thêm thì gửi `RESEARCH_REQUEST` cho Lead.

## Cách chạy với worker

Mọi task `research-first`/`research-deep` bắt buộc có worker nghiên cứu chỉ-đọc. Lead chỉ tạo task và kiểm tra brief, không scan file, tìm web hay đọc tài liệu sâu. Worker triển khai bắt đầu sau khi brief được chấp nhận nếu quyết định đó ảnh hưởng hướng làm. Có thể chạy scaffolding sớm nếu nó không khóa hướng đang tranh luận và không trùng writer.

Task vừa research vừa implementation nên tách `research -> implementation`, hoặc đặt checkpoint: worker phải nộp brief trước khi sửa file nhạy cảm với quyết định.

## Điểm dừng và chất lượng

Nghiên cứu đủ khi brief có đề xuất rõ, hợp ràng buộc dự án, có evidence tin cậy đúng cấp, giải thích đánh đổi thật và cho QA tiêu chí quan sát được.

Nếu còn hai hướng tốt mà quyết định thay đổi scope, thiết kế, chi phí hay quyền bên ngoài, Lead hỏi người dùng một câu dễ hiểu thay vì đoán. Kết quả dùng lại được được ghi `TEAM_STATE.md`; chỉ ghi skill registry khi thực sự đã đánh giá skill.
