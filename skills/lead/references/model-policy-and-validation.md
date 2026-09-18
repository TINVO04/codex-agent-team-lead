# Model theo từng dự án và kiểm tra trước khi dùng

`MODEL_POLICY.md` là nơi người dùng chọn model cho dự án. `MODEL_STATUS.md` là nơi Big Lead ghi kết quả Orca đã kiểm tra thực tế. Hai file này tách riêng để người dùng có thể đổi lựa chọn mà không làm lẫn với lịch sử kiểm tra.

## Nguyên tắc

- Bảng model mặc định của skill chỉ là gợi ý ban đầu. Nếu `MODEL_POLICY.md` có cấu hình hợp lệ thì file đó được ưu tiên.
- Nếu dự án cũ chưa có dòng `Same-model max attempts`, áp dụng mặc định là `3`; nên thêm dòng này để cấu hình nhìn thấy rõ.
- Không suy đoán model hoạt động chỉ vì model được ghi trong policy. Chỉ model có trạng thái `verified` trong `MODEL_STATUS.md` mới được phân công.
- Big Lead chỉ được dùng model chính hoặc model dự phòng mà người dùng đã ghi. Không được tự chọn model ngoài danh sách để "chữa cháy".
- Mỗi worker task chốt một `worker model pool` đúng theo `MODEL_POLICY.md` lúc launch. Khi model lỗi, chỉ được xoay trong pool đó; model verified ở route khác vẫn không được dùng.
- Pool Qwen/DeepSeek/GLM trong mẫu bootstrap chỉ là cấu hình mặc định. Nếu người dùng sửa pool trong `MODEL_POLICY.md`, pool mới trong file là nguồn sự thật và được dùng thay cho mẫu. Không có model nào bị cấm cứng nếu người dùng đã thêm nó rõ vào route, đã kiểm tra và policy cho phép.
- Mỗi model khác nhau chỉ kiểm tra một lần cho mỗi revision policy. Không tạo nhiều worker chỉ để kiểm tra cùng một model.
- Đổi cấu hình Big Lead chỉ áp dụng cho Big Lead được mở ở lần sau hoặc takeover hợp lệ. Không được thay Big Lead hiện tại giữa chừng chỉ vì người dùng đổi file.

## Mẫu `MODEL_POLICY.md`

```markdown
# Cấu hình model

Cập nhật gần nhất: <ISO 8601 giờ địa phương>
Revision: MP-001
Tự đổi sang dự phòng: có
Same-model max attempts: 3

| Route | Dùng cho | Model chính | Effort | Pool được xoay khi lỗi | Ghi chú |
|---|---|---|---|---|---|
| big-lead | Big Lead mở mới | gpt-5.6-terra | xhigh | gpt-5.6-terra → qwen3.8-max-0902 | Pool của Lead |
| domain-lead | Lead phụ | gpt-5.6-terra | xhigh | gpt-5.6-terra → qwen3.8-max-0902 | Pool của Lead |
| difficult-worker | Việc khó | qwen3.8-max-0902 | high | qwen3.8-max-0902 → deepseek-v4.1-flash → glm-5.3-flash | Pool worker |
| normal-worker | Việc thường | deepseek-v4.1-flash | medium | deepseek-v4.1-flash → qwen3.8-max-0902 → glm-5.3-flash | Pool worker |
| quick-worker | Việc nhỏ | glm-5.3-flash | low | glm-5.3-flash → deepseek-v4.1-flash → qwen3.8-max-0902 | Pool worker |
| final-review | Kiểm tra cuối | qwen3.8-max-0902 | high | qwen3.8-max-0902 → deepseek-v4.1-flash → glm-5.3-flash | Pool worker |
```

Người dùng có thể thay model, effort, pool, thứ tự xoay và bật/tắt tự đổi sang dự phòng. `Same-model max attempts: 3` nghĩa là cùng model được chạy tổng cộng ba lần cho một task rồi mới được đổi model; giữ giá trị 3 để hành vi recovery luôn rõ và giới hạn. Khi worker launch, ghi route và pool đọc từ `MODEL_POLICY.md` vào Task Contract; fallback phải lấy đúng từ pool đó, không lấy model ngẫu nhiên trong toàn hệ thống. Big Lead giữ nguyên cấu trúc route để dễ kiểm tra. Nếu cần route hoặc pool mới, ghi rõ mục đích và bổ sung vào Task Contract trước khi dùng.

## Kiểm tra model

Khi `$lead init`, `$lead models validate` hoặc policy đổi revision:

1. Big Lead đọc `MODEL_POLICY.md`, gom các model không trùng nhau và xem inventory Orca nếu runtime cung cấp.
2. Nếu inventory chưa đủ bằng chứng và còn slot, Big Lead mở worker chỉ-đọc `MODEL-VALIDATOR` lần lượt cho từng model cần kiểm tra. Chỉ một validator chạy tại một thời điểm; sau khi settle có thể dùng lại terminal để kiểm tra model kế tiếp. Worker không đọc source, không đổi file dự án, không dùng Git và chỉ thực hiện probe Orca tối thiểu được phép.
3. Worker ghi kết quả có bằng chứng vào `MODEL_STATUS.md`. Khi không mở được probe do hết slot/ràng buộc runtime, ghi `unknown`, không đoán là model hỏng.
4. Big Lead chỉ phân công task sau khi route có một model `verified`. Nếu chưa có, task giữ `QUEUED` hoặc `WAITING_USER` tùy nguyên nhân.

Trạng thái được dùng:

| Trạng thái | Ý nghĩa | Big Lead được làm gì |
|---|---|---|
| `verified` | Orca đã xác nhận model/effort dùng được | Có thể phân công |
| `unavailable` | Runtime từ chối model hoặc model không tồn tại | Bỏ qua đến khi policy/retry đổi |
| `temporary_error` | Lỗi provider tạm thời có bằng chứng sau lần lỗi thứ ba | Dùng fallback đã verified hoặc chờ |
| `unknown` | Chưa có đủ bằng chứng | Không được phân công |
| `disabled` | Người dùng tắt model này | Không được phân công |

## Mẫu `MODEL_STATUS.md`

```markdown
# Trạng thái model đã kiểm tra

Policy revision đã kiểm tra: MP-001
Kiểm tra gần nhất: <ISO 8601 giờ địa phương>

| Model | Effort | Trạng thái | Evidence Orca | Kiểm tra lúc | Dùng cho route |
|---|---|---|---|---|---|
| gpt-5.6-terra | xhigh | verified | <launch/inventory reference> | <time> | big-lead, domain-lead |
```

`MODEL_STATUS.md` là trạng thái quan sát, không phải lời hứa model sẽ không lỗi về sau. Nếu provider lỗi trong lúc chạy, xử lý theo recovery trong Task Contract và cập nhật status.

## Lỗi trong khi chạy

Chỉ đổi worker khi có bằng chứng worker thật sự lỗi/dừng hoặc Orca từ chối launch. Giữ ownership và checkpoint; retry cùng task bằng **chính model đang dùng** ở lần 2 và lần 3. Chỉ sau lần lỗi thứ ba mới xoay sang model `verified` kế tiếp trong **pool của chính route worker**. Không dùng model có trạng thái `unknown`, model ở route khác hoặc fallback ngoài pool.

Nếu route hết model `verified`, chuyển task thành `WAITING_USER` và hỏi người dùng một lựa chọn rõ: đổi policy, chờ thử lại, hoặc cho phép model khác. Nếu Big Lead/Domain Lead lỗi, quy tắc takeover/replacement cũ vẫn áp dụng; agent mới cũng phải đọc hai file model trước khi mở worker.

## Các lệnh điều phối

- `$lead models`: nói ngắn route nào đang dùng được, model nào chưa kiểm tra hay đang lỗi.
- `$lead models validate`: tạo một wave kiểm tra khi policy đổi hoặc status cũ; không kiểm tra lại model đã verified cùng revision.
- `$lead models set ...`: ghi đúng yêu cầu model của người dùng vào `MODEL_POLICY.md`, tăng revision, đánh dấu status liên quan là cần kiểm tra lại và không tự dùng model mới trước khi xác minh.
