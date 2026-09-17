# Kiểm tra phân công

`$lead audit` trả lời một câu thực tế: team có đang làm đúng vai trò đã thống nhất không?

Audit là chỉ-đọc. Nó không mở/thay/dừng worker, không sửa file đầu ra và không dùng Git mặc định. Nó đọc state, Task Contract, dashboard, lease và inventory Run/task/terminal thật trong Orca.

## Cần kiểm tra gì

Với mọi task `ACTIVE`, `VERIFYING`, `BLOCKED` hoặc `QUEUED`, đối chiếu:

1. Đây chỉ là status/clarification/policy hay có nghiên cứu/công việc dự án thật?
2. Nếu là nghiên cứu/công việc thật, Task Contract có tên worker owner không?
3. Orca live có Task/Dispatch và terminal handle của worker, hoặc có completion/recovery đã xác minh giải thích vì sao không còn terminal không?
4. Terminal title và dashboard có đúng vai trò/trạng thái hiện tại không?
5. Root/Domain Lead có chỉ là coordinator, decision owner, verifier hoặc reporter; không phải research/delivery owner không?
6. Có worker trùng hoặc ownership zone xung đột không?

## Kết quả audit

- `OK`: owner, trạng thái live và terminal hiển thị khớp nhau.
- `WAITING`: chưa cần worker vì đang chờ quyết định người dùng, dependency thật hoặc worker slot.
- `RECOVERY_REQUIRED`: worker cũ mất/chưa rõ, phải khôi phục ownership trước khi làm lại.
- `GAP`: task nghiên cứu/dự án đang chạy hoặc được nói là xong nhưng không có evidence worker/terminal hợp lệ.
- `CONFLICT`: worker trùng, ownership overlap hoặc Lead bị ghi thành owner nghiên cứu/triển khai.

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
