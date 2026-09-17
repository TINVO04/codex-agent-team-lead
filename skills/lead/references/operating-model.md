# Mô hình vận hành khi có nhiều yêu cầu

## Nhận yêu cầu và xếp hàng

Mọi yêu cầu mới thành root task trước khi giao:

| Kết quả | Ý nghĩa | Lead làm gì |
|---|---|---|
| `READY` | Scope/acceptance rõ, không dependency/ownership conflict | Giao khi còn slot, không thì `QUEUED` |
| `QUEUED` | Task hợp lệ nhưng chưa có worker phù hợp | Xếp theo ưu tiên rồi thời điểm đến |
| `BLOCKED` | Có dependency triển khai thật | Ghi task upstream |
| `WAITING_USER` | Cần lựa chọn, quyền hoặc trạng thái ngoài | Hỏi đúng câu hỏi cần thiết |
| `INTAKE` | Scope chưa đủ rõ | Làm rõ hoặc giao worker điều tra hẹp |

Yêu cầu mới không tự hủy task cũ. Ghi vào board và báo vị trí. Nguyên nhân lỗi chưa rõ thì giao worker điều tra chỉ-đọc có acceptance nêu nguyên nhân, path ảnh hưởng và task tiếp theo; không giao implementation mơ hồ.

Khi người dùng đưa rule toàn dự án, Root Lead ghi rule ngắn trong `TEAM_RULES.md`, ghi owner/task bị ảnh hưởng trong `TEAM_STATE.md`, thêm rule ID vào Task Contract. Nếu rule là checklist theo một thời điểm, ghi vào `PROJECT_HOOKS.md`; hook không được tự chạy lệnh hay tạo thay đổi ngoài. Domain Lead chỉ đề xuất, worker xác nhận rule/hook mới tại checkpoint an toàn.

## Ưu tiên

- `P0`: production/bảo mật/mất dữ liệu; có thể ưu tiên hơn queue và yêu cầu writer đến checkpoint an toàn.
- `P1`: feature/lỗi người dùng yêu cầu hoặc blocker chính.
- `P2`: cải thiện/lỗi không chặn.
- `P3`: nghiên cứu, dọn dẹp, hardening tùy chọn.

Cùng ưu tiên: task `READY` đến trước làm trước. P1 mới không tự ngắt writer P1 đang chạy.

## Cổng phân công

Root/Domain Lead là coordinator, không phải worker nghiên cứu/triển khai. Lead có **0 task research/delivery**. Mọi việc có ý nghĩa — tìm web/tài liệu, scan file, phân tích log, debug, tìm skill, code, test, config, tài liệu, asset hay output — phải thuộc một worker Orca hiển thị rõ, có Task Contract.

Lead chỉ đọc yêu cầu người dùng và `.orca-team`, phân loại/xếp task, mở worker, ghi quyết định, kiểm tra evidence và báo người dùng. Lead không chạy scan rộng, web/document search, command dài, test, debug hay sửa file dự án trong terminal của mình.

Status, clarification, rule hoặc câu trả lời một dòng không cần terminal. Nhiều thay đổi nhỏ liên quan có thể gom một worker. Không có slot/ownership an toàn/launch Orca thành công thì giữ `QUEUED`/`BLOCKED`; Lead không tự làm thay.

Dispatch chỉ thật khi Orca trả Task/Dispatch và terminal handle live. Đổi tên terminal, ghi dashboard ngay. Task research/implementation không có worker hiển thị là thiếu phân công và phải điều tra trước khi báo tiến độ.

## Năng lực và vùng sở hữu

`max_workers` là giới hạn, không phải chỉ tiêu. Mặc định ba worker khi môi trường có một Lead và bốn slot. Ưu tiên dùng lại terminal đã settle nếu context phù hợp.

Hai writer không được có allowed path trùng nhau trong shared workspace. Nếu dùng Git worktree để cô lập, phải có Git approval. DTO, public contract, migration, config, package/solution manifest và fixture chung phải reserve ownership và tuần tự hóa/trích contract-first.

Trước khi coi dependency là cứng, thử gỡ bằng versioned contract, mock, fixture, stub hoặc test. Ghi contract và reservation rõ.

## Vòng lặp Lead

Ở mỗi checkpoint:

1. Đưa user request mới vào task board.
2. Đọc inbox Orca theo thứ tự và trả lời worker.
3. Kiểm tra lỗi model/agent trước khi retry/release; chỉ dùng fallback đã `verified` theo MODEL_POLICY.
4. Xử lý acknowledgement rule/hook mới.
5. Kiểm tra task `READY_FOR_VERIFICATION`/`VERIFYING`, evidence và First-Pass Gate.
6. Kiểm tra task đã settle và cập nhật state.
7. Tính lại task `READY`, conflict, dependency, capacity.
8. Giao task an toàn tiếp theo hoặc báo blocker.

Khi user gửi task mới lúc worker chạy, làm bước 1 và 4 ngay; không chờ wave xong. Task settle thì verify, xử lý event, release/retain terminal và xếp task mới ngay nhưng không vượt dependency/ownership.

## Mở rộng và thu gọn team

Mặc định là `Root Lead → worker`. Chỉ tạo Domain Lead cho nhánh cô lập có đủ việc độc lập và cần điều phối cục bộ; vẫn tính vào capacity toàn cục và không được vượt depth policy.

Domain Lead không được mở rộng team quá policy. Khi domain không còn task `READY`/`ACTIVE`, settle/release worker, thu gọn Lead và trả task queue về Root. Terminal không được giả định còn tồn tại sau Orca restart.

## Recovery

Sau Orca restart, bind lại Run nếu có, đối chiếu state với inventory live. Handle không thấy là `RECOVERY_REQUIRED`, không tự coi đã dừng. Ghi evidence có sẵn rồi chỉ mở dispatch mới khi cần rework đã xác minh. Không dùng handle cũ như quyền thao tác.

## Phối hợp BE/FE

Hai Lead ghi contract trước khi code:

```text
Contract ID:
Lead sở hữu:
Endpoint hoặc sự kiện:
Request / response:
Permission:
State transition / error mapping:
Version / tương thích ngược:
Người chịu trách nhiệm smoke test và evidence:
```

Contract có thể cho BE/FE làm song song bằng mock/fixture, nhưng không cho phép thay đổi không tương thích. Contract đổi phải ghi quyết định mới và thông báo cả hai Lead.
