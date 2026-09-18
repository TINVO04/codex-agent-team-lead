# Chọn model và khôi phục khi lỗi

Đây là rule cho Root Lead/Domain Lead khi worker thật sự lỗi do model hoặc provider. Mục tiêu: tiếp tục **cùng task** bằng model được cho phép tiếp theo, không mất công việc và không có hai worker sửa cùng vùng. Trước khi chọn/đổi model, đọc [model policy và kiểm tra runtime](model-policy-and-validation.md).

Rule này chạy khi Lead đang điều phối, không phải Windows service nền. Nếu Orca/Codex đóng, `$lead recover` đọc state, kiểm tra worker live trước rồi chỉ tiếp tục task đã được chứng minh là lỗi/dừng.

## Lộ trình mặc định

Chỉ dẫn hiện tại của người dùng và `TEAM_POLICY.md` luôn cao hơn. `MODEL_POLICY.md` là nguồn sự thật để dự án chọn model, effort, pool và thứ tự xoay; `MODEL_STATUS.md` là bằng chứng Orca đã kiểm tra. Bảng dưới chỉ là mẫu bootstrap khi dự án chưa đổi policy. Nếu file setup khác bảng này, luôn dùng file setup.

| Vai trò/loại việc | Model chính | Mức suy nghĩ | Pool được xoay theo thứ tự |
|---|---|---|---|
| Root Lead | `gpt-5.6-terra` | `xhigh` | Pool Lead: `gpt-5.6-terra` → `qwen3.8-max-0902` |
| Domain Lead | `gpt-5.6-terra` | `xhigh` | Pool Lead: `gpt-5.6-terra` → `qwen3.8-max-0902` |
| Worker khó | `qwen3.8-max-0902` | `high` | Pool worker: `qwen3.8-max-0902` → `deepseek-v4.1-flash` → `glm-5.3-flash` |
| Worker thường | `deepseek-v4.1-flash` | `medium` | Pool worker: `deepseek-v4.1-flash` → `qwen3.8-max-0902` → `glm-5.3-flash` |
| Worker nhanh | `glm-5.3-flash` | `low` | Pool worker: `glm-5.3-flash` → `deepseek-v4.1-flash` → `qwen3.8-max-0902` |
| Kiểm tra cuối | `qwen3.8-max-0902` | `high` | Pool worker: `qwen3.8-max-0902` → `deepseek-v4.1-flash` → `glm-5.3-flash` |

Fallback worker dùng cùng effort trừ khi runtime từ chối. Chỉ model có trạng thái `verified` trong `MODEL_STATUS.md` được launch. Thiếu model, status `unknown`, hoặc policy mới chưa kiểm tra thì giữ task `QUEUED`/`WAITING_USER`; không dùng model ngoài pool của route. Model verified ở pool khác cũng không được dùng để chữa cháy. Không probe lại một model đã `verified` trong cùng revision policy.

## Chọn model theo phần việc thật

Route `quick` chỉ phù hợp cho đọc, phân loại, tài liệu hoặc thay đổi cơ học có acceptance hẹp. Worker viết code, sửa bug, thay đổi contract/state hoặc làm integration phải dùng model mạnh nhất đã `verified` trong pool mà người dùng cho phép; không hạ xuống model nhanh chỉ vì task được gọi là “bình thường”. Reviewer/integration cũng phải đủ mạnh để đọc toàn bộ kết quả. Nếu người dùng chọn route khác, `MODEL_POLICY.md` của dự án vẫn là nguồn sự thật.

## Thử lại cùng model trước khi đổi

Mặc định mỗi model được chạy **tối đa ba lần liên tiếp cho cùng một task**: lần đầu, lần 2 và lần 3. Đây là tổng số lần chạy, không phải ba lần cộng thêm sau lần đầu.

Khi có lỗi model/provider đã xác minh:

1. Nếu mới lỗi lần 1 hoặc lần 2 với model hiện tại, giữ ownership và checkpoint rồi mở worker retry cho **cùng task, cùng model, cùng effort**.
2. Nếu lỗi lần 3 với cùng model, cập nhật `MODEL_STATUS.md` là `temporary_error` hoặc `unavailable` tùy evidence, sau đó mới xét model fallback `verified` theo policy.
3. Đổi sang model kế tiếp trong **pool của cùng route** cũng bắt đầu lại bộ đếm riêng: model mới được thử tối đa ba lần trước khi xoay tiếp trong pool.

Ghi rõ `model + effort + lần thử/3` trong Task Contract và `TEAM_STATE.md`. Nếu người dùng tắt tự đổi sang dự phòng, sau lần lỗi thứ ba task chuyển `WAITING_USER` thay vì tự đổi model.

## Bằng chứng cần kiểm tra

Lead chỉ điều tra lỗi model khi có một trong các bằng chứng:

1. Orca báo Dispatch `failed` hoặc `stopped`.
2. Worker gửi completion `FAILED` nêu rõ lỗi provider/model.
3. Launch receipt từ chối model/effort đã chọn.
4. Output có lỗi provider, không tìm thấy model, xác thực provider, provider outage hoặc runtime model không thể phục hồi.

`unknown`, terminal cũ, timeout, im lặng hay server mất kết nối **không** tự là lỗi model. Kiểm tra worker trước. Code lỗi, test fail hay câu trả lời chưa đủ cũng không tự là lỗi model; xem như vấn đề task bình thường trước khi tiêu một lượt fallback.

## Cách thay worker trong Orca

1. Đọc state/final output, xác nhận worker thật sự `failed`/`stopped`.
2. Giữ ownership reservation của task. Kiểm tra file được phép và ghi phần đã đổi/đã xác minh.
3. Thêm recovery handover ngắn vào Task Contract và `TEAM_STATE.md`: model/effort, lần thử hiện tại trên ba, evidence, checkpoint file và quyết định retry/fallback.
4. Nếu lỗi mới ở lần 1 hoặc 2, chọn **chính model hiện tại** cho worker retry. Chỉ khi lỗi lần 3 mới chọn model kế tiếp vừa có trong **pool của route hiện tại**, vừa `verified` trong `MODEL_STATUS.md`.
5. Nếu dự án tắt tự đổi sang dự phòng và model đã lỗi lần 3, chuyển `WAITING_USER` thay vì tự mở fallback.
6. Mở một worker Codex mới cho **cùng task**; dùng Dispatch lỗi với `--retry-of`, giữ worktree và yêu cầu đúng model/effort đã chọn.
7. Đọc launch receipt. `launch.requested` chỉ là yêu cầu; chỉ ghi model/effort khi `launch.effective` xác nhận. Launch bị từ chối là một lần lỗi của model đó: cập nhật state, giữ task reserved và áp dụng lại quy tắc tối đa ba lần.
8. Worker mới đọc handover, kiểm tra file đang có và tiếp tục đúng bước kế tiếp; không làm lại phần đã xác minh trừ khi thay đổi yêu cầu.

Ví dụ dạng lệnh, thay mọi placeholder bằng ID thật do Orca trả:

```powershell
orca orchestration worker-start `
  --task <task-id> `
  --retry-of <failed-dispatch-id> `
  --worktree <đường-dẫn-worktree> `
  --model <same-model-or-fallback-after-third-failure> `
  --effort <effort> `
  --json
```

## Lead lỗi model

Domain Lead lỗi: Root Lead xác minh đủ 3 lần lỗi trên chính model hiện tại, retry cùng model ở lần 2 và 3, rồi mới mở replacement bằng fallback của Lead, cùng phạm vi/domain và state đã ghi. Root Lead lỗi: nó không thể tự thay; caller giám sát cũng phải tôn trọng đủ 3 lần thử model hiện tại trước khi mở Root Lead mới bằng fallback Qwen, trừ khi runtime đã báo model không thể launch ngay từ đầu. Caller đọc `TEAM_STATE.md`, đối chiếu inventory live và tiếp quản chỉ sau khi lease được chuyển hợp lệ.

Nếu model chính và toàn bộ fallback được policy cho phép đều không khả dụng/lỗi, task là `WAITING_USER`. Hỏi người dùng chọn model khác hoặc chờ thử lại; không tự dùng model không có trong policy. Khi user đổi policy, kiểm tra revision mới trước launch; không tự thay Big Lead hiện tại.

## Báo người dùng

Không nêu tên provider/model trừ khi người dùng hỏi. Nói ví dụ: `Worker xử lý phần này bị lỗi hệ thống. Mình đã chuyển đúng phần việc đó sang worker mới và giữ lại phần đã làm.` Nếu hết fallback: `Phần này chưa thể tiếp tục vì các model đã được cho phép đều không chạy được. Bạn muốn chọn model khác hay chờ thử lại?`
