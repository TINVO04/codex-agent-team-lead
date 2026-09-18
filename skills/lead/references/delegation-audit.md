# Kiểm tra phân công

`$lead audit` trả lời một câu thực tế: team có đang làm đúng vai trò đã thống nhất không?

Audit là chỉ-đọc. Nó không mở/thay/dừng worker, không sửa file đầu ra và không dùng Git mặc định. Nó đọc state, Task Contract, dashboard, lease và inventory Run/task/terminal thật trong Orca.

## Cần kiểm tra gì

Với mọi task `ACTIVE`, `VERIFYING`, `BLOCKED` hoặc `QUEUED`, đối chiếu:

1. Đây chỉ là status/clarification/policy hay có nghiên cứu/công việc dự án thật?
2. Nếu là nghiên cứu/công việc thật, Task Contract có tên worker owner không?
3. Orca live có Task/Dispatch và terminal handle của worker, hoặc có completion/recovery đã xác minh giải thích vì sao không còn terminal không?
4. Nhãn tab trong `visualLayouts` và dashboard có đúng vai trò/trạng thái hiện tại không? Không dùng riêng `terminals[].title`, vì đó có thể là tiêu đề nội bộ do agent tự đặt.
5. Worker có qua cổng bắt đầu thật chưa: `worker-show` có `live` + `activity: working`, hay còn chỉ `input_accepted`/prompt đang nằm ở ô nhập?
6. Root/Domain Lead có chỉ là coordinator, decision owner, verifier hoặc reporter; không phải research/delivery owner không?
7. Có worker trùng hoặc ownership zone xung đột không?
8. Task có dùng Agency role không? Nếu có, `AR-###` có tồn tại, đã thu hẹp đúng task và không tự cấp thêm quyền không?
9. Task có dùng Agent-Reach không? Nếu có, nó có thuộc Research Worker, ghi `public-only` và không có dấu hiệu login/cookie/token/thao tác ghi ngoài phạm vi không?
10. Model đã phân công có `verified` trong MODEL_STATUS.md của policy revision hiện tại không?
11. Task worker nói đã xong có đi qua `READY_FOR_VERIFICATION` và `VERIFYING` với evidence đúng mức rủi ro không?
12. Nếu task có nhiều writer, Task Contract có integration owner và Semantic Integration Gate với build/test/smoke toàn cục phù hợp không?
13. Nếu task đang mở rộng giữa chừng, có checkpoint/handover và ownership mới không chồng lấn không?
14. Worker có đang lặp sửa code/test quá ba lần mà chưa chuyển resolver, `BLOCKED` hoặc `WAITING_USER` không?

## Kết quả audit

- `OK`: owner, trạng thái live và terminal hiển thị khớp nhau.
- `WAITING`: chưa cần worker vì đang chờ quyết định người dùng, dependency thật hoặc worker slot.
- `RECOVERY_REQUIRED`: worker cũ mất/chưa rõ, phải khôi phục ownership trước khi làm lại.
- `GAP`: task nghiên cứu/dự án đang chạy hoặc được nói là xong nhưng không có evidence worker/terminal hợp lệ.
- `CONFLICT`: worker trùng, ownership overlap hoặc Lead bị ghi thành owner nghiên cứu/triển khai.
- `CONFIG_GAP`: model chưa kiểm tra, hook/rule mâu thuẫn rõ hoặc task bỏ qua First-Pass Gate.
- `INPUT_NOT_STARTED`: Dispatch đã nhận Task Contract nhưng worker chưa bắt đầu lượt làm; cần một lần Enter fallback hoặc báo blocker, không được ghi `RUN`.
- `INTEGRATION_GAP`: nhiều thay đổi đã hoàn thành nhưng chưa có owner hợp nhất hoặc chưa có kiểm tra toàn cục.
- `RETRY_LOOP`: worker đang lặp sửa/test vượt giới hạn mà không có checkpoint hoặc quyết định xử lý tiếp.

Không kết luận worker đã mất chỉ vì dashboard cũ không hiển thị. Inventory Orca live là nguồn đúng. Terminal/worker chưa rõ trạng thái cũng không tự là lỗi; dùng quy trình recovery.

## Kiểm tra ownership file tùy chọn

Audit mặc định không thể chứng minh ai đã sửa một file local. Chỉ khi người dùng đã duyệt Git riêng cho dự án, Lead mới được đối chiếu path thay đổi với ownership board. Kết quả Git chỉ là bằng chứng hỗ trợ, không chứng minh tác giả.

Không có quyền đó thì chỉ báo gap điều phối đang thấy; không chạy Git âm thầm.

## Sau khi thấy gap

1. Ghi gap vào `TEAM_STATE.md`, giữ ownership đang có.
2. Lead không tự sửa file và không mở writer trùng khi worker cũ còn chưa rõ.
3. Chỉ sau khi xác minh worker cũ dừng/lỗi hoặc người dùng quyết định, mới chuẩn bị recovery/replacement task bình thường.
4. Báo kết quả dễ hiểu; không che gap.

## Mẫu báo người dùng

```text
Đúng quy trình: các việc nghiên cứu hoặc sửa file đều có worker riêng và đang hiển thị rõ.
```

```text
Cần sửa quy trình: có một việc đang được ghi là đang làm nhưng chưa thấy worker phụ trách. Mình đã để việc đó chờ kiểm tra; Lead sẽ không tự làm thay.
```

```text
Chưa thể kết luận vì worker cũ mất kết nối. Cần kiểm tra trạng thái của worker đó trước để không tạo hai người cùng sửa một chỗ.
```
