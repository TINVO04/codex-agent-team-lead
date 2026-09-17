# Chọn model và khôi phục khi lỗi

Đây là rule cho Root Lead/Domain Lead khi worker thật sự lỗi do model hoặc provider. Mục tiêu: tiếp tục **cùng task** bằng model được cho phép tiếp theo, không mất công việc và không có hai worker sửa cùng vùng.

Rule này chạy khi Lead đang điều phối, không phải Windows service nền. Nếu Orca/Codex đóng, `$lead recover` đọc state, kiểm tra worker live trước rồi chỉ tiếp tục task đã được chứng minh là lỗi/dừng.

## Lộ trình mặc định

`TEAM_POLICY.md` của dự án là nguồn cao nhất và có thể thay bảng này trước khi launch. Mỗi project phải ghi rõ model chính, effort và fallback cho role được bật.

| Vai trò/loại việc | Model chính | Mức suy nghĩ | Chỉ được dự phòng theo thứ tự |
|---|---|---|---|
| Root Lead | `gpt-5.6-terra` | `xhigh` | `qwen3.8-max-0902` với `xhigh` |
| Domain Lead | `gpt-5.6-terra` | `xhigh` | `qwen3.8-max-0902` với `xhigh` |
| Worker khó | `qwen3.8-max-0902` | `high` | `deepseek-v4.1-flash` → `glm-5.3-flash` |
| Worker thường | `deepseek-v4.1-flash` | `medium` | `qwen3.8-max-0902` → `glm-5.3-flash` |
| Worker nhanh | `glm-5.3-flash` | `low` | `deepseek-v4.1-flash` → `qwen3.8-max-0902` |
| Kiểm tra cuối | `qwen3.8-max-0902` | `high` | `deepseek-v4.1-flash` → `glm-5.3-flash` |

Fallback worker dùng cùng effort trừ khi runtime từ chối. Máy mới phải xác nhận tên model có tồn tại trước lần launch đầu. Thiếu model thì ghi evidence và đi fallback kế tiếp, không dùng model ngoài bảng.

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
3. Thêm recovery handover ngắn vào Task Contract và `TEAM_STATE.md`: model đã thử, evidence, checkpoint file và model kế tiếp được phép.
4. Mở một worker Codex mới cho **cùng task**; dùng Dispatch lỗi với `--retry-of`, giữ worktree và yêu cầu model/effort fallback tiếp theo.
5. Đọc launch receipt. `launch.requested` chỉ là yêu cầu; chỉ ghi model/effort khi `launch.effective` xác nhận. Launch bị từ chối thì giữ task reserved và thử fallback hợp lệ kế tiếp.
6. Worker mới đọc handover, kiểm tra file đang có và tiếp tục đúng bước kế tiếp; không làm lại phần đã xác minh trừ khi thay đổi yêu cầu.

Ví dụ dạng lệnh, thay mọi placeholder bằng ID thật do Orca trả:

```powershell
orca orchestration worker-start `
  --task <task-id> `
  --retry-of <failed-dispatch-id> `
  --worktree <đường-dẫn-worktree> `
  --model <fallback-model> `
  --effort <effort> `
  --json
```

## Lead lỗi model

Domain Lead lỗi: Root Lead xác minh rồi mở replacement với fallback của Lead, cùng phạm vi/domain và state đã ghi. Root Lead lỗi: nó không thể tự thay. Caller giám sát mở Root Lead mới bằng Qwen fallback, đọc `TEAM_STATE.md`, đối chiếu inventory live và tiếp quản chỉ sau khi lease được chuyển hợp lệ.

Nếu model chính và toàn bộ fallback được policy cho phép đều không khả dụng/lỗi, task là `WAITING_USER`. Hỏi người dùng chọn model khác; không tự dùng model không có trong policy.

## Báo người dùng

Không nêu tên provider/model trừ khi người dùng hỏi. Nói ví dụ: `Worker xử lý phần này bị lỗi hệ thống. Mình đã chuyển đúng phần việc đó sang worker mới và giữ lại phần đã làm.` Nếu hết fallback: `Phần này chưa thể tiếp tục vì các model đã được cho phép đều không chạy được. Bạn muốn chọn model khác hay chờ thử lại?`
