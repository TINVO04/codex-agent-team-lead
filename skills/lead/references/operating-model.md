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

Dispatch chỉ thật khi Orca trả Task/Dispatch, terminal handle live và `worker-show` xác nhận agent đang hoạt động. Receipt `input_accepted` chỉ chứng minh nội dung đã vào terminal, chưa chứng minh prompt đã chạy. Đổi tên terminal, kiểm tra lại tab và cổng bắt đầu thật rồi mới ghi dashboard `RUN`. Khi thấy đúng Task Contract còn nằm ở ô nhập sau một lần chờ ngắn, Lead có thể dùng handle mới gửi **một** Enter; sau đó phải xác nhận activity `working`. Không gửi lại toàn bộ prompt, không Enter lặp và không mở worker trùng. Task research/implementation không có worker hiển thị hoặc chưa qua cổng bắt đầu là thiếu phân công và phải điều tra trước khi báo tiến độ.

## Năng lực và vùng sở hữu

`max_workers` là giới hạn, không phải chỉ tiêu. Mặc định ba worker khi môi trường có một Lead và bốn slot. Ưu tiên dùng lại terminal đã settle nếu context phù hợp.

Hai writer không được có allowed path trùng nhau trong shared workspace. Nếu dùng Git worktree để cô lập, phải có Git approval. DTO, public contract, migration, config, package/solution manifest và fixture chung phải reserve ownership và tuần tự hóa/trích contract-first.

Trước khi coi dependency là cứng, thử gỡ bằng versioned contract, mock, fixture, stub hoặc test. Ghi contract và reservation rõ.

## Vòng lặp Lead

Ở mỗi checkpoint:

1. Đưa user request mới vào task board.
2. Đọc inbox Orca theo thứ tự và trả lời worker.
3. Kiểm tra lỗi model/agent trước khi retry/release; lỗi model được xác minh phải retry cùng model đến hết lần 3, rồi mới xoay sang model `verified` tiếp theo trong pool của đúng route theo MODEL_POLICY.
4. Xử lý acknowledgement rule/hook mới.
5. Kiểm tra task `READY_FOR_VERIFICATION`/`VERIFYING`, evidence và First-Pass Gate.
6. Kiểm tra task đã settle và cập nhật state.
7. Tính lại task `READY`, conflict, dependency, capacity.
8. Giao task an toàn tiếp theo hoặc báo blocker.

Ở bước kiểm tra, đọc thêm risk tier/test route và test budget. Không nâng lên full suite chỉ vì task đã có worker; chỉ nâng khi acceptance, impact hoặc policy yêu cầu. Ghi thời gian chờ, test, retry và handoff để biết nút thắt nằm ở điều phối hay ở code.

Khi user gửi task mới lúc worker chạy, làm bước 1 và 4 ngay; không chờ wave xong. Task settle thì verify, xử lý event, release/retain terminal và xếp task mới ngay nhưng không vượt dependency/ownership.

## Workload thích ứng và mở rộng có kiểm soát

Lead không mặc định chia nhiều worker. Task liền mạch ưu tiên một worker làm trọn gói; task vừa chỉ thêm reviewer khi rủi ro cần; task lớn chỉ fan-out khi các nhánh độc lập và có integration owner từ đầu. Số worker là giới hạn, không phải mục tiêu. Đọc [workload thích ứng và hợp nhất](adaptive-workload-and-integration.md) trước khi fan-out, mở rộng giữa chừng, xử lý semantic conflict hoặc lặp sửa test.

Sau khi nhiều worker hoàn thành, integration owner phải kiểm tra trạng thái hợp nhất bằng build/test hoặc smoke check toàn cục phù hợp. Git merge không conflict không phải bằng chứng hệ thống đúng. Nếu cổng hợp nhất hỏng, chỉ mở một resolver worker nhận đầy đủ log, checkpoint, file đã đổi và acceptance; không ném cùng lỗi đồng thời cho các writer cũ.

Integration owner dùng test ladder: fast check trước, boundary check khi chạm contract/schema/state, release check khi rủi ro cao hoặc trước release. Test flaky được phân loại riêng, không âm thầm tính là pass.

## Checkpoint khi task phình to

Không thêm writer vào cùng ownership zone khi worker hiện tại còn sửa dở. Worker phải dừng ở checkpoint an toàn và ghi handover gồm quyết định, file đã đổi, test, phần còn lại, dependency, rủi ro và bước kế tiếp. Lead chỉ chia nhánh sau khi xác nhận các nhánh độc lập; worker mới phải đọc handover và state thật trước khi làm. Nếu không tạo được nhánh độc lập, giữ một worker chính làm tiếp.

## Giới hạn vòng sửa

Lỗi provider/model và lỗi code/test là hai loại khác nhau. Lỗi model tuân theo retry cùng model tối đa ba lần trong policy. Lỗi test hoặc contract có tối đa ba lần sửa có bằng chứng cho một owner; sau đó đóng băng checkpoint và mở nhiều nhất một resolver worker có ngân sách riêng, hoặc chuyển `BLOCKED`/`WAITING_USER`. Không tự động revert toàn bộ diff hay xóa phần đã làm đúng; rollback chỉ được thực hiện với checkpoint, ownership rõ và quyền phù hợp.

## Mở rộng và thu gọn team

Mặc định là `Root Lead → worker`. Chỉ tạo Domain Lead cho nhánh cô lập có đủ việc độc lập và cần điều phối cục bộ; vẫn tính vào capacity toàn cục và không được vượt depth policy.

Domain Lead không được mở rộng team quá policy. Khi domain không còn task `READY`/`ACTIVE`, settle/release worker, thu gọn Lead và trả task queue về Root. Terminal không được giả định còn tồn tại sau Orca restart.

## Recovery

Sau Orca restart, bind lại Run nếu có, đối chiếu state với inventory live. Handle không thấy là `RECOVERY_REQUIRED`, không tự coi đã dừng. Ghi evidence có sẵn rồi chỉ mở dispatch mới khi cần rework đã xác minh. Không dùng handle cũ như quyền thao tác.

## Phối hợp bên ngoài tùy nhu cầu

Khi task có dependency với nhóm, dự án hoặc hệ thống bên ngoài, các Lead ghi contract trước khi code:

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

Contract có thể cho các bên làm song song bằng mock/fixture, nhưng không cho phép thay đổi không tương thích. Nếu không có dependency thật thì bỏ qua phần phối hợp này. Contract đổi phải ghi quyết định mới và thông báo các owner bị ảnh hưởng.
