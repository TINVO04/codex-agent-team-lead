# Mẫu trạng thái team dự án

`TEAM_STATE.md` là trạng thái điều phối bền vững trong `.orca-team/`. Nó không thay cho identity terminal thật; sau Orca restart phải đối chiếu với inventory live.

```markdown
# Trạng thái team

Cập nhật gần nhất: <ISO 8601 giờ địa phương>
Dự án: <tên>
Chế độ Lead: <active | recovering | idle>
Orca Run: <run ID hoặc unbound>
Terminal Lead: <live handle hoặc unbound>
Nhãn Big Lead: <00 | BIG | project | RUN hoặc unassigned>
Lease Lead: <ACTIVE | VIEWER_ONLY | RECOVERY_REQUIRED | TRANSFERRED>

## Mục tiêu hiện tại

<một mục tiêu hoặc không có>

## Rule team đang hiệu lực

| Rule ID | Rule ngắn | Phạm vi | Task/owner ảnh hưởng | Evidence cần có | Đã xác nhận |
|---|---|---|---|---|---|

Toàn bộ nội dung/lịch sử rule nằm trong `TEAM_RULES.md`. Ghi mọi thay đổi rule tại đây để Root Lead biết ai cần xác nhận.

## Bảng task

| ID | Yêu cầu | Ưu tiên | Trạng thái | Owner | Vùng sở hữu | Phụ thuộc | Evidence nhận task | Ghi chú |
|---|---|---|---|---|---|---|---|---|
| T-001 | ... | P1 | READY | API | src/... | — | dotnet test ... | ... |

Trạng thái: `INTAKE`, `READY`, `QUEUED`, `ACTIVE`, `READY_FOR_VERIFICATION`, `VERIFYING`, `BLOCKED`, `WAITING_USER`, `DONE`, `FAILED`, `CANCELLED`.

## Cấu trúc team và năng lực

| Team/domain | Nhãn Lead | Parent | Capacity được cấp | Task sở hữu | Trạng thái | Điều kiện thu gọn |
|---|---|---|---:|---|---|---|
| Root | 00 | BIG | project | RUN | none | <global max> | ... | active | không thu gọn khi đang xử lý yêu cầu |

Không tính capacity riêng cho từng dòng. Tổng worker active phải không vượt `max_workers` toàn cục.

## Phân công đang chạy

| Task | Nhãn role | Nhãn parent | Lần thử | Dispatch | Terminal | Model/effort yêu cầu và thực tế | Checkpoint | Kết quả gần nhất |
|---|---|---|---:|---|---|---|---|---|

Chỉ ghi ID Orca trả về trong runtime live. Sau restart, đổi assignment thành `RECOVERY_REQUIRED` đến khi inventory live xác minh. Lead không được là owner triển khai/nghiên cứu của task có ý nghĩa.

## Cấu hình model và hook

| Policy revision | Model status đã kiểm tra | Hook revision | Config check gần nhất | Ghi chú |
|---|---|---|---|---|

Chi tiết model ở `MODEL_POLICY.md` và `MODEL_STATUS.md`; checklist event ở `PROJECT_HOOKS.md`. Model chưa `verified` không được launch. Hook chỉ là checklist, không phải script tự chạy.

## Model và recovery

| Role/task | Lần thử | Model/effort yêu cầu | Model/effort thực tế | Thứ tự fallback | Evidence lỗi | Quyết định recovery |
|---|---:|---|---|---|---|---|

Không retry model từ state unknown. Giữ ownership đến khi worker failed/stopped, file checkpoint và replacement path đã xác minh. Replacement dùng cùng task ID và là writer duy nhất trong vùng đó.

## First-Pass Gate

| Task | Route kiểm tra | Evidence đã nộp | Phần chưa kiểm tra | Trạng thái xác minh | Quyết định Lead |
|---|---|---|---|---|---|

Worker chuyển task sang `READY_FOR_VERIFICATION`; Big Lead chỉ ghi `DONE` sau `VERIFYING` và evidence phù hợp. Chi tiết ở `first-pass-verification.md`.

## Ownership và Parallel Gate

| Task | Vùng ownership/tài nguyên chung | Parallel Gate | Giữ đến | Conflict/contract |
|---|---|---|---|---|

Reserve ownership trước khi worker thay đổi. Giá trị Gate: `pass`, `hard dependency`, `ownership conflict`, `contract-first`.

## Quyết định và contract

| ID | Quyết định/contract | Owner | Task ảnh hưởng | Ngày |
|---|---|---|---|---|

## Quyết định capability và skill

Chi tiết ở `SKILL_REGISTRY.md`; chỉ giữ quyết định active hoặc chặn task ở đây.

| Registry ID | Capability | Quyết định | Task ảnh hưởng | Owner | Kiểm tra tiếp |
|---|---|---|---|---|---|

## Vai trò Agency

Chi tiết ở `AGENCY_PROFILE_REGISTRY.md`; chỉ giữ role đang active, baseline pending hoặc đang chặn task ở đây.

| Role ID | Vai trò | Trạng thái | Task ảnh hưởng | Owner | Kiểm tra tiếp |
|---|---|---|---|---|---|

## Quyết định nghiên cứu

Chi tiết ở `RESEARCH_NOTES/`; chỉ giữ brief đang dùng, dùng lại hoặc chặn task.

| Research ID | Câu hỏi quyết định | Cấp | Task ảnh hưởng | Trạng thái evidence | Owner |
|---|---|---|---|---|---|

## Quyết định xem trước

| Preview ID | Thay đổi/câu hỏi | Chế độ | Người dùng đã chốt | Task ảnh hưởng | Ngày |
|---|---|---|---|---|---|

## Blocker và approval người dùng

| Task | Blocker hoặc quyền cần | Từ lúc | Owner tiếp theo |
|---|---|---|---|
```

Giữ board ngắn. Giữ task đã xong chỉ khi nó còn giải thích dependency, evidence hoặc recovery sau này.
