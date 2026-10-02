# Mô hình vận hành khi có nhiều yêu cầu

## Nhận yêu cầu và xếp hàng

### Tiếp nhận Hàng loạt & Cơ chế Chống bỏ quên Task (Zero-Drop Batch Ingestion)
Khi người dùng giao nhiều việc cùng lúc (từ 2 đến 20+ yêu cầu trong một prompt):
1. **Turn-1 Atomic Breakdown:** Tuyệt đối không nhảy vào code hoặc mở worker bừa bãi. Big Lead bóc tách toàn bộ các yêu cầu thành từng mục nguyên tử độc lập, gán ID duy nhất (`T-001` đến `T-NNN`).
2. **Durable Task Ledger:** Ghi cứng toàn bộ danh sách vào bảng task trong `.orca-team/TEAM_STATE.md` với trạng thái ban đầu là `QUEUED` (hoặc `READY` cho task đầu). Xuất bảng checklist trực quan cho người dùng.
3. **WIP-Constrained Execution (Giới hạn WIP):** Tối đa 1 đến 3 worker chạy đồng thời (`IN_PROGRESS`). Toàn bộ task còn lại nằm chờ trong hàng đợi (`QUEUED`), mỗi worker chỉ nhận đúng 1 Task Contract độc lập để bảo toàn context sạch.
4. **Deterministic Reconciliation Loop:** Khi mỗi task hoàn thành qua tín hiệu callback (Exit code 0), Big Lead thức dậy cập nhật `DONE`, tính toán tỷ lệ tiến độ dạng `[Tiến độ: X/N hoàn thành]`, pop task tiếp theo từ queue để dispatch, rồi tiếp tục ngủ (Sleep on Dispatch).
5. **Khóa Hoàn Thành (Deterministic Termination Gate):** Big Lead chỉ được phép kết luận `Hoàn thành toàn bộ` khi số task `DONE` trên đĩa bằng đúng $N/N$. Tuyệt đối không xảy ra tình trạng "quên việc ở giữa".

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

## Cổng phân công và Triage Fast-Path

Root/Domain Lead là coordinator. Để tối ưu tốc độ phản hồi và tránh micro-dispatch thrashing:
- **Triage Fast-Path:** Các tác vụ tra cứu nhanh chỉ-đọc (định vị file, grep 1 biểu thức, đọc lướt config/hàm cụ thể) tốn ≤ 2 tool calls và không ghi sửa mã nguồn thì Lead được phép thực hiện trực tiếp trong terminal Lead và trả lời người dùng ngay.
- **Worker Delegation:** Mọi tác vụ có ý nghĩa — ghi/sửa mã nguồn, chạy test kéo dài (>10s), debug sâu đa file, phân tích log diện rộng, tìm/đánh giá skill, code, config hoặc output lớn — bắt buộc phải thuộc một worker Orca hiển thị rõ, có Task Contract.

Lead không chạy scan rộng bừa bãi, test nặng hay sửa file mã nguồn dự án trong terminal của mình.

Status, clarification, rule hoặc câu trả lời một dòng không cần terminal. Nhiều thay đổi nhỏ liên quan có thể gom một worker. Không có slot/ownership an toàn/launch Orca thành công thì giữ `QUEUED`/`BLOCKED`; Lead không tự làm thay.

Dispatch chỉ thật khi Orca trả Task/Dispatch, terminal handle live và worker xác nhận bắt đầu. Lệnh đổi tên terminal gửi bất đồng bộ (non-blocking). Khi thấy đúng Task Contract còn nằm ở ô nhập sau một lần chờ ngắn, Lead có thể dùng handle mới gửi **một** Enter; sau đó xác nhận activity `working`. Không gửi lại toàn bộ prompt, không Enter lặp và không mở worker trùng. Task research sâu/implementation không có worker hiển thị hoặc chưa bắt đầu phải được điều tra trước khi báo tiến độ.

## Năng lực và vùng sở hữu

`max_workers` là giới hạn, không phải chỉ tiêu. Mặc định ba worker khi môi trường có một Lead và bốn slot. Ưu tiên dùng lại terminal đã settle nếu context phù hợp.

Hai writer không được có allowed path trùng nhau trong shared workspace. Nếu dùng Git worktree để cô lập, phải có Git approval. DTO, public contract, migration, config, package/solution manifest và fixture chung phải reserve ownership và tuần tự hóa/trích contract-first.

Trước khi coi dependency là cứng, thử gỡ bằng versioned contract, mock, fixture, stub hoặc test. Ghi contract và reservation rõ.

## Vòng lặp Điều phối Hướng Sự Kiện (Event-Driven Reactive Loop & Sleep on Dispatch)

Big Lead **tuyệt đối không chạy vòng lặp thăm dò liên tục** (Cấm Polling Loop / Zero Busy-Waiting, không gọi `worker-show` hay kiểm tra terminal lặp đi lặp lại, không thăm dò model/connection). Big Lead vận hành hoàn toàn dựa trên sự kiện (Event-Driven):

1. **Giai đoạn Xử lý Yêu cầu (Request Phase):**
   - Đưa user request mới vào task board (`TEAM_STATE.md`).
   - Triage theo cấp độ (Level 0 Direct / Level 1 Fast-Path / Level 2 Solo / Level 3 Swarm).
   - Nếu cần mở Worker: Lập Task Contract kèm thông tin `Lead Terminal Handle` và Lệnh Callback Wakeup.
   - Khởi chạy worker bằng lệnh Orca (non-blocking rename).

2. **Giai đoạn Ngủ tiết kiệm Token (Sleep on Dispatch - 0 Token):**
   - Cập nhật task sang `IN_PROGRESS` trong `TEAM_STATE.md`.
   - Xuất đúng 1 dòng thông báo cho người dùng: `⚡ [DISPATCHED: Worker <handle> đang thực thi <task_id>. Big Lead chuyển sang trạng thái SLEEP chờ callback.]`.
   - **KẾT THÚC LƯỢT NGAY LẬP TỨC (END TURN / YIELD)**. Không gọi thêm bất kỳ tool nào. Tiêu thụ 0 token trong suốt thời gian worker đang làm việc.

3. **Giai đoạn Thức dậy phản ứng (Dual-Trigger Reactive Wakeup):**
   Big Lead CHỈ thức dậy khi có 1 trong 2 sự kiện:
   - **Trigger 1 (User Event):** Người dùng gửi tin nhắn hoặc yêu cầu mới trong chat $\to$ Lead thức dậy tiếp nhận, cập nhật task board, ưu tiên P0 hoặc xếp queue.
   - **Trigger 2 (Worker Callback Event):** Worker hoàn tất và kiểm thử máy đạt (Exit code 0), worker gửi tin nhắn qua `orca terminal send` vào terminal của Big Lead:
     `orca terminal send --terminal <LEAD_HANDLE> --text "TASK_FINISHED: [<TaskID>] đã hoàn tất nghiệm thu máy (exit 0). Mời Big Lead thức dậy tổng kết." --enter`
     (Hoặc gửi `TASK_BLOCKED` nếu gặp blocker).
   - Khi nhận callback, Big Lead thức dậy:
     + Đọc báo cáo và bằng chứng của worker.
     + Kiểm tra First-Pass Gate và Semantic Integration Gate (nếu có nhiều writer).
     + Cập nhật `TEAM_STATE.md` sang `DONE` (hoặc `BLOCKED`).
     + Settle/giải phóng hoặc tái sử dụng terminal worker.
     + Nếu còn task `READY` trong queue: dispatch task tiếp theo rồi lại Sleep on Dispatch.
     + Nếu hết việc: Báo cáo kết quả trực tiếp và ngắn gọn cho người dùng.

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
