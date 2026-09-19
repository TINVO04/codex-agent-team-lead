[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath
)

$resolvedProjectPath = (Resolve-Path -LiteralPath $ProjectPath -ErrorAction Stop).Path
$teamPath = Join-Path $resolvedProjectPath '.orca-team'
[System.IO.Directory]::CreateDirectory($teamPath) | Out-Null

$policyPath = Join-Path $teamPath 'TEAM_POLICY.md'
$rulesPath = Join-Path $teamPath 'TEAM_RULES.md'
$statePath = Join-Path $teamPath 'TEAM_STATE.md'
$leasePath = Join-Path $teamPath 'LEAD_LEASE.md'
$dashboardPath = Join-Path $teamPath 'TEAM_DASHBOARD.md'
$skillRegistryPath = Join-Path $teamPath 'SKILL_REGISTRY.md'
$agencyRegistryPath = Join-Path $teamPath 'AGENCY_PROFILE_REGISTRY.md'
$externalResearchPolicyPath = Join-Path $teamPath 'EXTERNAL_RESEARCH_POLICY.md'
$researchNotesPath = Join-Path $teamPath 'RESEARCH_NOTES'
$researchReadmePath = Join-Path $researchNotesPath 'README.md'
$qualityGatesPath = Join-Path $teamPath 'QUALITY_GATES.md'
$modelPolicyPath = Join-Path $teamPath 'MODEL_POLICY.md'
$modelStatusPath = Join-Path $teamPath 'MODEL_STATUS.md'
$projectHooksPath = Join-Path $teamPath 'PROJECT_HOOKS.md'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

if (-not (Test-Path -LiteralPath $policyPath)) {
    $policyContents = @'
# Chính sách team

max_workers: 3
max_hierarchy_depth: 2
default_priority: P1
scaling_policy: ưu tiên làm song song nhưng phải qua dependency và ownership gate
git_policy: mọi thao tác Git cần người dùng duyệt rõ ràng
database_policy: thay đổi database dùng chung cần người dùng duyệt rõ ràng
service_policy: restart service hoặc deploy cần người dùng duyệt rõ ràng
cross_project_policy: cần contract Lead-to-Lead trước khi triển khai
terminal_policy: bắt buộc dùng Orca; terminal giữ lại có thể mất sau restart, phải recovery từ inventory live
lead_identity_policy: mỗi dự án chỉ một Big Lead; terminal thứ hai là viewer đến khi recovery/takeover được xác minh
skill_discovery_policy: suggest-only; Lead duyệt mọi candidate, không tự cài global
agency_profile_policy: baseline theo dự án; Agency role chỉ là card hướng dẫn cho worker, không tự tạo Lead/terminal/cài agent; role task-approved phải có nguồn/revision rõ và không có quyền ngoài
external_research_policy: ưu tiên source local/tài liệu chính thức; Agent-Reach chỉ do Research Worker dùng ở chế độ public-only khi đã được duyệt/có sẵn, không login/cookie/token/dữ liệu riêng
research_policy: research-first cho thiết kế, UX, nội dung, user flow, kiến trúc/thư viện mới, bảo mật, hiệu năng và integration lớn
quality_policy: mọi task phải có evidence quan sát được; dùng checklist phù hợp trước DONE
test_policy: chọn risk tier và test route fast/boundary/release; có test budget; không thêm test trùng assertion; flaky chỉ retry một lần để phân loại
cost_observability_policy: task có giới hạn thời gian/tool/model call/token khi có thể; ghi thời gian chờ/làm/test, retry/handoff/rework và trace ID nếu có; chạm budget thì dừng và báo
first_pass_policy: lần triển khai đầu chỉ READY_FOR_VERIFICATION; phải qua VERIFYING với evidence phù hợp trước DONE
preview_policy: hỏi người dùng chốt ngắn trước trang mới, redesign UI/UX đáng kể, đổi navigation hoặc user flow, trừ khi người dùng yêu cầu làm trực tiếp
delegation_policy: Lead có 0 task nghiên cứu/triển khai; tìm web/tài liệu, scan file, phân tích, code, test, config, tài liệu, asset và output đều thuộc worker terminal Orca hiển thị rõ, trừ status, clarification, policy hoặc câu trả lời một dòng
user_language_policy: mọi agent nói trực tiếp với người dùng dùng tiếng Việt ngắn, dễ hiểu và giải thích từ kỹ thuật bắt buộc ngay trong câu
audit_policy: $lead audit chỉ-đọc, kiểm tra mọi nghiên cứu/thay đổi có worker thật; Git inspection vẫn cần người dùng duyệt riêng
model_policy: người dùng có thể chỉnh MODEL_POLICY.md; chỉ model verified trong MODEL_STATUS.md mới được phân công; không tự dùng model ngoài policy
hook_policy: PROJECT_HOOKS.md chỉ là checklist dạng chữ; cấm script tự chạy, thay đổi ngoài, quyền mới, vòng hook hoặc mở worker không kiểm soát

## Vai trò

1. Lead: nhận yêu cầu, xếp lịch, ghi quyết định, kiểm tra và lập kế hoạch tích hợp.
2. Worker triển khai: nghiên cứu, thay đổi module hoặc service được giao.
3. QA/tích hợp: bằng chứng test và contract kiểm tra luồng chính.
4. Reviewer: review chỉ-đọc độc lập, trừ khi được giao sửa rõ ràng.

## Hàng đợi và làm song song

Mọi việc mới được ghi trước khi giao. Nó không tự hủy việc đang làm, trừ khi Lead đánh dấu P0 và chuyển worker tại checkpoint an toàn.

Trước khi giao writer, ghi Parallel Gate là pass, hard dependency, ownership conflict hoặc contract-first. Gom việc nhỏ theo module/context. Giới hạn worker là toàn cục, kể cả khi có Domain Lead.

## Rule và quyền

Chỉ dẫn người dùng và policy này không được làm yếu. Root Lead có thể ghi rule vào TEAM_RULES.md và phải nêu rule ID trong Task Contract. Domain Lead chỉ đề xuất. Rule không cấp quyền Git, database, service, deploy hoặc thay đổi ngoài.

## Báo người dùng

Nội bộ có thể dùng chi tiết kỹ thuật. Khi báo người dùng, nói Đã xong, Đang làm hoặc Chưa thể tiếp tục trước; chỉ nêu kết quả, kiểm tra, blocker hay lựa chọn cần thiết bằng tiếng Việt dễ hiểu. Không nêu task ID, agent, terminal, log dài hay nội bộ nếu người dùng không hỏi.

## Skill và nghiên cứu

Lead xem registry/context rồi giao skill-scout worker nếu cần. Worker không tự tải/cài/bật/chạy skill ngoài. Chế độ mặc định suggest-only: phải hỏi người dùng trước khi tải/cài/bật/chạy skill mới. Trusted-instruction-only chỉ là opt-in theo dự án, chỉ cho skill nguồn uy tín, đọc được toàn bộ, chỉ có hướng dẫn/reference, không script/hook/credential/upload/Git/DB/deploy.

Agency Agents là nguồn card vai trò, không thay Lead/worker Orca. Sau khi khởi tạo, nếu Orca còn slot, Lead giao worker CAPABILITY-BASELINE chỉ-đọc để xác định role phù hợp với stack/domain và ghi AGENCY_PROFILE_REGISTRY.md. Khi task thiếu role, chỉ CAPABILITY-SCOUT mới được đọc Agency gốc; Lead dùng card AR-### ngắn, không dùng raw prompt dài. Role mới chỉ task-approved khi nguồn/revision rõ, chỉ là hướng dẫn, không có script/hook/package/login/quyền ngoài và không xung đột policy. Cài Agency/custom agent vẫn cần người dùng duyệt.

Agent-Reach chỉ là đường tìm nguồn công khai tùy chọn cho Research Worker, không bắt buộc cho mọi URL/nghiên cứu. Ưu tiên source local, tài liệu chính thức và standard. Chỉ dùng Agent-Reach public-only khi Task Contract cho phép, tool đã được cài/duyệt; cấm cookie, login, token, proxy, query có dữ liệu riêng và mọi thao tác ghi trên nền tảng bên ngoài. Tool chưa có phải hỏi người dùng trước khi cài.

Lead ghi routine, research-first hoặc research-deep lúc nhận task. UI/UX, visual, copy/content, user flow, framework/library mới, kiến trúc, bảo mật, hiệu năng và integration lớn cần research-first. Worker nghiên cứu chỉ-đọc tạo brief ngắn trước phần triển khai phụ thuộc nó.

## Chất lượng, preview và phân công

Mỗi task chọn checklist, risk tier và test route trong QUALITY_GATES.md, ghi evidence và test budget trong Task Contract và chỉ DONE sau Lead kiểm tra. Task liền mạch dùng một worker làm trọn gói; chỉ fan-out khi các nhánh độc lập và có integration owner. Nếu có nhiều writer, integration owner bắt buộc chạy build/test hoặc smoke check toàn cục phù hợp, vì merge không conflict không chứng minh logic đã tương thích. Dùng fast check trước; chỉ nâng lên boundary/release khi risk hoặc impact yêu cầu. Test mới phải bao phủ rủi ro cụ thể, không lặp assertion. Trang mới, redesign lớn, navigation hoặc user flow quan trọng cần bản tóm tắt để người dùng chốt trước khi worker thay đổi phần quyết định hướng.

Không thêm writer vào task đang làm dở. Nếu task phình to, owner hiện tại phải dừng ở checkpoint an toàn và ghi handover gồm quyết định, file đã đổi, test, phần còn lại, dependency, rủi ro và bước tiếp theo trước khi Lead chia nhánh. Lỗi code/test có tối đa ba lần sửa có evidence cho mỗi owner; sau đó đóng băng checkpoint và chỉ mở một resolver worker hoặc chuyển BLOCKED/WAITING_USER. Không tự động revert/xóa toàn bộ diff; rollback chỉ phần task sở hữu khi có checkpoint và quyền phù hợp.

Root/Domain Lead chỉ nhận yêu cầu, ưu tiên, mở worker, ghi quyết định, kiểm tra và báo cáo. Lead không tìm web, scan file, chạy command dài, debug, code, test, sửa config/tài liệu/asset hay tạo output dự án. Orca phải trả Task/Dispatch và terminal handle, terminal phải được đổi tên/ghi dashboard thì worker mới active. Launch lỗi thì task QUEUED/BLOCKED; Lead không làm thay.

Lead audit chỉ đọc board, contract, dashboard và inventory Orca; không mở/dừng/retry worker, không sửa output và không dùng Git nếu chưa duyệt riêng.

## Chính sách model

MODEL_POLICY.md là nguồn cấu hình thật của dự án: người dùng chỉnh model, effort, pool model và thứ tự xoay tại đây. MODEL_STATUS.md là kết quả Orca đã kiểm tra. Bảng dưới chỉ là mẫu khởi tạo, không phải danh sách model bị khóa; chỉ model `verified` trong MODEL_STATUS.md mới được launch. Model không rõ trạng thái, không có trong pool của route hoặc đã disabled không được tự dùng. Mặc định một model được thử tổng cộng 3 lần cho cùng task trước khi xoay model.

Root Lead và Domain Lead: gpt-5.6-terra với xhigh; fallback qwen3.8-max-0902 với xhigh.

Worker:
- code, sửa bug, contract/state hoặc integration: dùng route việc khó và model mạnh nhất đã verified trong pool người dùng cho phép;
- việc thường chỉ dùng cho research, tài liệu, phân loại hoặc kiểm tra hẹp nếu policy dự án không quy định khác: deepseek-v4.1-flash với medium, rồi Qwen, rồi GLM;
- việc nhanh: glm-5.3-flash với low cho đọc/kiểm tra cơ học, không mặc định cho thay đổi cần hiểu nhiều file;
- kiểm tra cuối/integration: Qwen với high, rồi DeepSeek, rồi GLM.

Ghi model yêu cầu, runtime xác nhận, pool route, effort, lần thử cùng model và fallback. Unknown/disconnected không phải lỗi model. Worker có thể đã sửa file thì giữ ownership, kiểm tra checkpoint rồi retry cùng task bằng chính model đó đến 3/3 khi lỗi model được chứng minh; chỉ sau 3/3 mới xoay sang model `verified` khác trong pool worker. Domain Lead/Root Lead cũng phải thử chính model đủ 3 lần trước replacement trong pool Lead, trừ khi runtime từ chối launch ngay từ đầu. Không lấy model của pool khác để chữa cháy. Tất cả model trong pool lỗi/không có thì WAITING_USER. Root Lead lỗi phải do caller giám sát thay bằng state đã lưu. Lỗi code/test không tự đổi model; tối đa ba lần sửa có evidence, sau đó resolver hoặc BLOCKED/WAITING_USER.

## Hook và First-Pass Gate

TEAM_RULES.md giữ rule; PROJECT_HOOKS.md giữ checklist theo event. Hook được phép kiểm tra state/contract/evidence, yêu cầu acknowledgement hoặc giữ trạng thái task. Hook không được tự chạy script/shell/Git/DB/deploy, login, external write, đổi quyền/model/ownership/scope hay tạo worker vượt capacity.

Mọi task sau lần triển khai đầu chuyển `READY_FOR_VERIFICATION`, rồi `VERIFYING`. Worker nộp evidence đã kiểm tra và phần chưa kiểm tra. Lead chỉ ghi `DONE` sau khi evidence khớp acceptance và mức kiểm tra theo rủi ro. Auth, permission, payment, database/migration/state, API public/contract hoặc dependency giữa nhiều nhóm/hệ thống cần QA độc lập hoặc smoke evidence tách riêng. Có nhiều writer thì bắt buộc Semantic Integration Gate: một integration owner chạy build/test hoặc smoke toàn cục phù hợp trước DONE. Flaky test phải được ghi riêng, retry tối đa một lần để phân loại; quarantine phải có owner/ticket/expiry, không âm thầm coi là pass.

## Big Lead và khả năng quan sát

Chỉ một Big Lead active được điều phối. Terminal claim lease dùng 00 | BIG | <project> | RUN. Terminal thứ hai là viewer đến khi Big Lead giao role hẹp hoặc recovery/takeover xác minh. Dùng TEAM_DASHBOARD.md và nhãn role để thể hiện ownership; trạng thái Orca live mới là nguồn quyết định worker sống/lỗi.
'@
    [System.IO.File]::WriteAllText($policyPath, $policyContents, $utf8NoBom)
}

if (-not (Test-Path -LiteralPath $modelPolicyPath)) {
    $modelPolicyContents = @'
# Cấu hình model

Cập nhật gần nhất: chưa khởi tạo
Revision: MP-001
Tự đổi sang dự phòng: có
Same-model max attempts: 3

Bảng này do người dùng chỉnh và là nguồn sự thật cho route/pool của dự án. Big Lead chỉ được phân công model có trạng thái `verified` trong MODEL_STATUS.md. Pool Qwen/DeepSeek/GLM chỉ là mẫu mặc định; model nào được thêm rõ vào pool trong file đều có thể dùng sau khi kiểm tra. `Same-model max attempts: 3` nghĩa là cùng model chạy tổng cộng ba lần cho một task; chỉ lỗi lần 3 mới xoay model trong đúng pool. Đổi model, pool hoặc effort phải tăng Revision rồi chạy `$lead models validate`; không tự dùng model mới trước khi Orca kiểm tra.

| Route | Dùng cho | Model chính | Effort | Pool được xoay khi lỗi | Ghi chú |
|---|---|---|---|---|---|
| big-lead | Big Lead mở mới | gpt-5.6-terra | xhigh | gpt-5.6-terra → qwen3.8-max-0902 | Pool Lead |
| domain-lead | Lead phụ | gpt-5.6-terra | xhigh | gpt-5.6-terra → qwen3.8-max-0902 | Pool Lead |
| difficult-worker | Code, bug, contract/state, integration | qwen3.8-max-0902 | high | qwen3.8-max-0902 → deepseek-v4.1-flash → glm-5.3-flash | Route mạnh cho thay đổi cần hiểu sâu |
| normal-worker | Research, tài liệu, phân loại hoặc kiểm tra hẹp | deepseek-v4.1-flash | medium | deepseek-v4.1-flash → qwen3.8-max-0902 → glm-5.3-flash | Không mặc định cho thay đổi code nhiều file |
| quick-worker | Đọc hoặc kiểm tra cơ học | glm-5.3-flash | low | glm-5.3-flash → deepseek-v4.1-flash → qwen3.8-max-0902 | Không mặc định cho thay đổi cần suy luận sâu |
| final-review | Kiểm tra cuối hoặc integration | qwen3.8-max-0902 | high | qwen3.8-max-0902 → deepseek-v4.1-flash → glm-5.3-flash | Có thể làm integration owner |
'@
    [System.IO.File]::WriteAllText($modelPolicyPath, $modelPolicyContents, $utf8NoBom)
}

if (-not (Test-Path -LiteralPath $modelStatusPath)) {
    $modelStatusContents = @'
# Trạng thái model đã kiểm tra

Policy revision đã kiểm tra: chưa có
Kiểm tra gần nhất: chưa khởi tạo

Chỉ model `verified` trong bảng này mới được Big Lead dùng để mở Lead/worker. `unknown` nghĩa là chưa đủ bằng chứng, không phải lỗi. Mỗi model chỉ kiểm tra một lần cho mỗi revision policy.

| Model | Effort | Trạng thái | Evidence Orca | Kiểm tra lúc | Dùng cho route |
|---|---|---|---|---|---|

Trạng thái: verified, unavailable, temporary_error, unknown, disabled.
'@
    [System.IO.File]::WriteAllText($modelStatusPath, $modelStatusContents, $utf8NoBom)
}

if (-not (Test-Path -LiteralPath $projectHooksPath)) {
    $projectHooksContents = @'
# Hook dự án

Cập nhật gần nhất: chưa khởi tạo
Revision: H-001

Hook là checklist dạng chữ, không phải script tự chạy. Hook không được chạy shell/script/Git/DB/deploy, login, request ghi bên ngoài, đọc secret, đổi model/ownership/scope hoặc mở worker vượt capacity.

## Hook đang hiệu lực

### H-001 — Kiểm tra trước khi mở worker
Event: before_worker_launch
Khi: task chuẩn bị từ READY sang ACTIVE
Bắt buộc:
- Có Task Contract, ownership và Parallel Gate rõ.
- Route model có ít nhất một model verified trong MODEL_STATUS.md.
- Còn capacity và không có writer trùng vùng.
Nếu không đạt: giữ QUEUED, BLOCKED hoặc WAITING_USER và ghi lý do.
Trạng thái: active

### H-002 — Lần làm đầu phải được kiểm tra
Event: before_done
Khi: worker báo đã hoàn thành phần việc
Bắt buộc:
- Task đi qua READY_FOR_VERIFICATION rồi VERIFYING.
- Có evidence đã kiểm tra và nêu rõ phần chưa kiểm tra.
- Task rủi ro cao có QA độc lập hoặc smoke evidence tách riêng.
Nếu không đạt: trả ACTIVE hoặc BLOCKED; không ghi DONE.
Trạng thái: active

### H-003 — Thử cùng model đủ ba lần trước khi đổi
Event: on_model_failure
Khi: Orca xác minh lỗi model hoặc provider cho task đang chạy
Bắt buộc:
- Giữ ownership và checkpoint của cùng task.
- Ghi model, effort và lần lỗi hiện tại trên 3 vào TEAM_STATE.md.
- Lỗi lần 1 hoặc 2: retry cùng model, cùng effort.
- Lỗi lần 3: mới được dùng fallback verified theo MODEL_POLICY.md; nếu tắt tự đổi fallback thì WAITING_USER.
Nếu không đạt: không được đổi model.
Trạng thái: active

## Hook đã ngừng

Chưa có.
'@
    [System.IO.File]::WriteAllText($projectHooksPath, $projectHooksContents, $utf8NoBom)
}

if (-not (Test-Path -LiteralPath $rulesPath)) {
    $rulesContents = @'
# Quy tắc team

Cập nhật gần nhất: chưa khởi tạo

## Cách rule hoạt động

Root Lead ghi rule dự án/domain/task khi người dùng đưa chỉ dẫn rõ ảnh hưởng hơn một task/owner. Chỉ dẫn người dùng và TEAM_POLICY.md luôn cao hơn. Rule không được cấp quyền Git, database, restart, deploy, remote permission hoặc thay đổi ngoài. PROJECT_HOOKS.md là checklist theo event, cũng không được là script tự chạy.

Task Contract liệt kê rule ID/evidence trước khi worker bắt đầu và trước khi Lead nhận DONE. Worker đang chạy xác nhận rule đổi tại checkpoint an toàn tiếp theo.

## Rule đang hiệu lực

Chưa có rule active.

## Rule đã ngừng

Chưa có rule nào ngừng.
'@
    [System.IO.File]::WriteAllText($rulesPath, $rulesContents, $utf8NoBom)
}

if (-not (Test-Path -LiteralPath $statePath)) {
    $stateContents = @'
# Trạng thái team

Cập nhật gần nhất: chưa khởi tạo
Dự án: chờ khám phá
Chế độ Lead: idle
Orca Run: unbound
Terminal Lead: unbound
Nhãn Big Lead: unassigned
Lease Lead: UNASSIGNED

## Mục tiêu hiện tại

Chưa có.

## Rule team đang hiệu lực

| Rule ID | Rule ngắn | Phạm vi | Task/owner ảnh hưởng | Evidence cần | Đã xác nhận |
|---|---|---|---|---|---|

## Bảng task

| ID | Yêu cầu | Ưu tiên | Rủi ro/route test | Trạng thái | Owner | Vùng sở hữu | Phụ thuộc | Evidence nhận task | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|

Trạng thái: INTAKE, READY, QUEUED, BLOCKED, WAITING_USER, ACTIVE, READY_FOR_VERIFICATION, VERIFYING, DONE, FAILED, CANCELLED.

## Cấu trúc team và năng lực

| Team/domain | Nhãn Lead | Parent | Capacity | Task sở hữu | Trạng thái | Điều kiện thu gọn |
|---|---|---|---:|---|---|---|

## Phân công đang chạy

| Task | Nhãn role | Nhãn parent | Lần thử | Dispatch | Terminal | Model/effort yêu cầu và thực tế | Checkpoint | Kết quả gần nhất |
|---|---|---|---:|---|---|---|---|---|

Chỉ ghi ID từ Orca runtime live. Sau restart, ghi RECOVERY_REQUIRED đến khi inventory xác minh. Lead không được là owner nghiên cứu/triển khai.

## Cấu hình model và hook

| Policy revision | Status kiểm tra | Hook revision | Config check gần nhất | Ghi chú |
|---|---|---|---|---|

Chi tiết model: MODEL_POLICY.md và MODEL_STATUS.md. Chi tiết hook: PROJECT_HOOKS.md.

## Model và recovery

| Role/task | Lần thử | Model/effort yêu cầu | Model/effort thực tế | Fallback | Evidence lỗi | Quyết định recovery |
|---|---:|---|---|---|---|---|

## First-Pass Gate

| Task | Route kiểm tra | Evidence đã nộp | Phần chưa kiểm tra | Trạng thái xác minh | Quyết định Lead |
|---|---|---|---|---|---|

## Test budget và flaky

| Task | Test bắt buộc | Test informational | Budget dự kiến/thực tế | Rerun flaky | Owner/ticket/expiry | Trạng thái |
|---|---|---|---|---|---|---|

Không coi test flaky hoặc lỗi môi trường là pass. Rerun tối đa một lần để phân loại; quarantine phải có owner, ticket và ngày hết hạn.

## Đo thời gian và chi phí

| Task | Thời gian chờ | Thời gian worker | Thời gian test | Worker/handoff | Retry/rework | Token/chi phí | First-pass |
|---|---:|---:|---:|---:|---:|---:|---|

Ghi số liệu khi có thể. Nếu không có runtime metric, ghi `unknown` thay vì đoán.

## Trace và quan sát

| Task | Trace ID | Context hash/commit | Model/version | Tool/handoff | Nút thắt hoặc lỗi |
|---|---|---|---|---|---|

Không ghi secret, token, dữ liệu riêng hoặc log nhạy cảm vào state/trace.

## Ownership và Parallel Gate

| Task | Vùng ownership/tài nguyên chung | Parallel Gate | Giữ đến | Conflict/contract |
|---|---|---|---|---|

## Quyết định và contract

| ID | Quyết định/contract | Owner | Task ảnh hưởng | Ngày |
|---|---|---|---|---|

## Capability và skill

| Registry ID | Capability | Quyết định | Task ảnh hưởng | Owner | Kiểm tra tiếp |
|---|---|---|---|---|---|

## Vai trò Agency

| Role ID | Vai trò | Trạng thái | Task ảnh hưởng | Owner | Kiểm tra tiếp |
|---|---|---|---|---|---|

## Nghiên cứu

| Research ID | Câu hỏi quyết định | Cấp | Task ảnh hưởng | Trạng thái evidence | Owner |
|---|---|---|---|---|---|

## Quyết định xem trước

| Preview ID | Thay đổi/câu hỏi | Chế độ | Người dùng đã chốt | Task ảnh hưởng | Ngày |
|---|---|---|---|---|---|

## Blocker và approval người dùng

| Task | Blocker hoặc quyền cần | Từ lúc | Owner tiếp theo |
|---|---|---|---|
'@
    [System.IO.File]::WriteAllText($statePath, $stateContents, $utf8NoBom)
}

if (-not (Test-Path -LiteralPath $leasePath)) {
    $leaseContents = @'
# Lease Big Lead

Trạng thái: UNASSIGNED
Nhãn Big Lead: unassigned
Chế độ: unbound
Orca Run: unbound
Terminal Lead: unbound
Bắt đầu: chưa khởi tạo
Xác nhận gần nhất: chưa khởi tạo

Chỉ Big Lead active được xếp lịch worker. Terminal thứ hai là viewer đến khi recovery đã xác minh hoặc người dùng yêu cầu takeover rõ ràng.
'@
    [System.IO.File]::WriteAllText($leasePath, $leaseContents, $utf8NoBom)
}

if (-not (Test-Path -LiteralPath $dashboardPath)) {
    $dashboardContents = @'
# Bảng theo dõi team

Cập nhật gần nhất: chưa khởi tạo
Dự án: chờ khám phá

Chưa có Big Lead nào claim dự án.

## Đọc nhanh

| Nhãn | Owner / task | Trạng thái | Checkpoint tiếp |
|---|---|---|---|
'@
    [System.IO.File]::WriteAllText($dashboardPath, $dashboardContents, $utf8NoBom)
}

if (-not (Test-Path -LiteralPath $skillRegistryPath)) {
    $skillRegistryContents = @'
# Sổ đăng ký skill

Cập nhật gần nhất: chưa khởi tạo
Chế độ: suggest-only

Lead/skill-scout kiểm tra sổ này và skill Codex sẵn có trước khi tìm ngoài. Worker chỉ yêu cầu capability, không tự tải/cài/bật/chạy skill ngoài. Trong suggest-only, phải hỏi người dùng trước khi tải/cài/bật/chạy skill mới. Trusted-instruction-only là opt-in theo dự án và vẫn cấm script/hook/credential/upload/Git/database/deploy/nguồn không rõ nếu chưa có approval riêng.

## Danh sách

| ID | Capability / skill | Nguồn và độ tin cậy đã kiểm tra | Cần cho | Rủi ro | Quyền cần | Trạng thái | Quyết định/evidence |
|---|---|---|---|---|---|---|---|

Trạng thái: candidate, approved, active, rejected, retired.

## Chi tiết khi cần

~~~
### SK-001 — <skill hoặc capability>
Nguồn: <publisher/repository/URL>
Lý do: <task nào được hỗ trợ>
Đã kiểm tra: <publisher, mức dùng, repo, toàn bộ SKILL.md/reference/script>
Có gì: <chỉ hướng dẫn | script | hook | dependency>
Dữ liệu và quyền: <none hoặc quyền/thay đổi ngoài cụ thể>
Phạm vi: <một task | dự án này>
Quyết định: <vì sao duyệt/loại và ai duyệt>
~~~
'@
    [System.IO.File]::WriteAllText($skillRegistryPath, $skillRegistryContents, $utf8NoBom)
}

if (-not (Test-Path -LiteralPath $agencyRegistryPath)) {
    $agencyRegistryContents = @'
# Sổ vai trò Agency

Cập nhật gần nhất: chưa khởi tạo
Nguồn ưu tiên: msitarzewski/agency-agents (chỉ đọc profile gốc theo URL/revision được ghi)

Sổ này lưu card vai trò chuyên môn cho worker. Vai trò Agency không phải terminal, Lead mới, model route hay tool được cài. TEAM_POLICY.md, rule người dùng, ownership, Git/DB/deploy approval và Quality Gate luôn cao hơn card vai trò.

## Baseline dự án

| Role ID | Vai trò | Phù hợp với dự án vì | Trạng thái | Bằng chứng / worker xác định |
|---|---|---|---|---|
| AR-BL-001 | baseline pending | Chờ CAPABILITY-BASELINE đọc context dự án | pending | chưa có |

## Danh sách role

| ID | Vai trò | Nguồn/revision | Dùng cho | Trạng thái | Evidence |
|---|---|---|---|---|---|

Trạng thái: baseline, candidate, task-approved, approved, active, rejected, retired.

## Card chi tiết khi cần

~~~
### AR-001 — <tên vai trò>
Nguồn: <URL file/repository gốc>
Revision đã kiểm tra: <commit SHA hoặc ngày/version>
Phù hợp vì: <task/domain cụ thể>
Dùng cho: <module/task và kết quả cần có>
Checklist áp dụng: <3-5 nguyên tắc liên quan>
Không được cấp quyền: <không tự cấp Git/cài tool/DB/deploy/credential/đổi model>
Trạng thái: <baseline | candidate | task-approved | approved | active | rejected | retired>
Evidence: <brief/test/review hoặc lý do loại>
~~~

Role `task-approved` chỉ được dùng cho một worker khi profile nguồn đọc được toàn bộ, nguồn/revision rõ, chỉ là hướng dẫn và không có script/hook/package/login/quyền ngoài. Không chép raw prompt dài vào Task Contract; chỉ dùng card đã thu hẹp phạm vi. Xem `references/agency-profiles-and-agent-reach.md` trong skill Lead để biết đầy đủ quy trình.
'@
    [System.IO.File]::WriteAllText($agencyRegistryPath, $agencyRegistryContents, $utf8NoBom)
}

if (-not (Test-Path -LiteralPath $externalResearchPolicyPath)) {
    $externalResearchPolicyContents = @'
# Chính sách nghiên cứu bên ngoài

Trạng thái Agent-Reach: chưa cài/chưa xác nhận
Chế độ mặc định: public-only

## Thứ tự nguồn

1. Rule, tài liệu, code pattern và research note nội bộ của dự án.
2. Tài liệu chính thức và standard phù hợp.
3. Nguồn công khai đáng tin khi hai nhóm trên chưa đủ.

Agent-Reach chỉ là công cụ tùy chọn cho Research Worker ở bước 3. Nó không tự trở thành bắt buộc khi có URL, không thay thế nguồn gốc và không được dùng bởi Big Lead/Lead phụ.

## Public-only

Được dùng khi Task Contract ghi rõ câu hỏi hẹp, `Agent-Reach public-only`, loại nguồn và tool đã được người dùng duyệt/có sẵn:

- đọc web/RSS/YouTube/GitHub public;
- tìm thông tin công khai không chứa dữ liệu dự án nhạy cảm;
- ghi source, kết luận và giới hạn evidence vào RN-###.

## Cấm mặc định

- cài Agent-Reach, package, plugin, browser extension hoặc dependency khi chưa có user approval;
- cookie, Chrome profile, login, token, GitHub auth, proxy hoặc API key;
- source nội bộ, tên khách hàng, URL private, credential, log chưa lọc, dữ liệu DB/production trong query hay URL gửi ra ngoài;
- đăng bài, nhắn tin, like, tạo issue/PR hoặc thao tác ghi trên bất kỳ nền tảng ngoài nào.

Nếu tool chưa có hoặc đòi login/quyền ngoài, Research Worker dừng phần đó và báo Lead để chuyển `WAITING_USER`. Approval dùng tool không thay thế các approval Git, database, deploy hoặc service khác.
'@
    [System.IO.File]::WriteAllText($externalResearchPolicyPath, $externalResearchPolicyContents, $utf8NoBom)
}

if (-not (Test-Path -LiteralPath $researchNotesPath)) {
    [System.IO.Directory]::CreateDirectory($researchNotesPath) | Out-Null
}

if (-not (Test-Path -LiteralPath $researchReadmePath)) {
    $researchReadmeContents = @'
# Ghi chú nghiên cứu

Thư mục này giữ các brief ngắn, dùng lại được. Brief giúp Lead/worker sau hiểu evidence và quyết định; không phải bài web sao chép hay nơi chứa dữ liệu riêng.

## Khi nào cần brief

Worker nghiên cứu tạo brief trước triển khai khi task là research-first hoặc research-deep: UI/UX, visual, responsive, accessibility, nội dung, user flow, product experience, framework/kiến trúc mới, bảo mật, hiệu năng, payment, identity, integration lớn hay vấn đề chưa rõ có nhiều hướng.

Lỗi nhỏ, pattern đã rõ và implementation hẹp không cần brief chỉ để đủ quy trình.

## Mẫu brief

Dùng file RN-###-short-topic.md:

~~~
# RN-### — <chủ đề>

Câu hỏi: <quyết định cần evidence>
Phạm vi: <task/module và phần ngoài scope>
Context local: <path/ràng buộc liên quan>
Nguồn đã xem: <tài liệu chính thức, standard, public example ít nhưng phù hợp>
Phát hiện: <fact/nguyên tắc ngắn, không sao chép>
Lựa chọn đã cân nhắc: <lựa chọn và đánh đổi>
Quyết định cho dự án: <hướng chọn và lý do>
Ảnh hưởng acceptance: <implementation/QA cần chứng minh>
Quyết định skill: <none | skill/path sẵn có | SK-### candidate>
Ranh giới dữ liệu/IP: <không chia sẻ dữ liệu riêng; học nguyên tắc, không copy code/asset/chữ>
Ngày / owner: <ngày và worker nghiên cứu>
~~~

## Cấp nghiên cứu

- routine: không cần brief, trừ khi có câu hỏi thật.
- research-first: brief tập trung để chọn hướng an toàn.
- research-deep: kế hoạch evidence và brief so sánh trước quyết định rủi ro/cost cao.

Không tìm vô hạn. Dừng khi brief trả lời đủ bằng evidence đáng tin. Thiếu evidence hoặc cần nguồn login/trả phí thì báo Lead để hỏi người dùng.

## Nghiên cứu bên ngoài

Khi dùng nguồn ngoài, ưu tiên tài liệu chính thức. Agent-Reach chỉ dùng nếu Task Contract ghi `Agent-Reach public-only`, tool đã được duyệt/có sẵn và chỉ cần nguồn public. Không đưa dữ liệu riêng, không dùng login/cookie/token/proxy và không thao tác ghi trên nền tảng bên ngoài.
'@
    [System.IO.File]::WriteAllText($researchReadmePath, $researchReadmeContents, $utf8NoBom)
}

if (-not (Test-Path -LiteralPath $qualityGatesPath)) {
    $qualityGatesContents = @'
# Cổng chất lượng

Lead chỉ chọn checklist đúng task và ghi evidence cụ thể vào Task Contract; không bắt task hẹp làm checklist không liên quan.

## Risk tier và test ladder

Mỗi task ghi risk tier (`low`, `medium`, `high`, `critical`), phần bị ảnh hưởng, test route và test budget. Chọn tầng thấp nhất vẫn đủ bằng chứng:

- `fast`: format/lint, typecheck/compile và unit deterministic liên quan.
- `boundary`: API/contract, serialization, migration/state, permission hoặc integration bị ảnh hưởng.
- `release`: suite rộng, E2E hoặc smoke production-like khi rủi ro cao, module dùng chung hoặc trước release.

Không chạy release suite sau mọi sửa nhỏ. Test mới phải trả lời một rủi ro cụ thể, không lặp assertion. Tách test `required` khỏi `informational`, cache artifact khi an toàn và chỉ chạy song song test độc lập. Ghi thời gian dự kiến/thực tế và điều kiện nâng tầng.

## Test chập chờn và budget

- Flaky chỉ retry tối đa một lần để phân loại, không retry vô hạn.
- Tách `product-failure`, `environment-failure` và `flaky`; retry pass không tự thành xanh.
- Quarantine phải có owner, ticket và ngày hết hạn; không dùng làm bằng chứng duy nhất cho task rủi ro cao.
- Task có giới hạn thời gian, tool/model call và token/chi phí nếu runtime hỗ trợ. Cùng lỗi lặp lại hoặc chạm budget thì đóng băng checkpoint và chuyển resolver/BLOCKED/WAITING_USER.
- Handoff chỉ đưa tóm tắt log, kết quả và context hash; không lặp toàn bộ log dài.

## First-Pass Gate

Lần triển khai đầu có thể đúng nhưng không tự là DONE. Worker báo `READY_FOR_VERIFICATION`, nêu evidence đã kiểm tra và phần chưa kiểm tra. Lead chuyển task sang `VERIFYING`, đối chiếu acceptance/rule/checklist rồi mới ghi DONE.

- Task hẹp, rủi ro thấp: worker evidence + Lead review evidence.
- Task trung bình: có test hoặc manual smoke tập trung.
- Auth/permission, payment, database/migration/state, API public/contract hoặc dependency giữa nhiều nhóm/hệ thống: có QA độc lập hoặc smoke evidence tách riêng.
- Có từ hai writer: chỉ định integration owner, chạy build/test hoặc smoke check toàn cục phù hợp; merge không conflict không đủ.
- Test/code hỏng ba lần sửa có evidence: đóng băng checkpoint, chỉ mở một resolver worker hoặc chuyển BLOCKED/WAITING_USER; không tự động revert toàn bộ diff.

Không nói chắc chắn không còn lỗi hoặc sẵn sàng production khi evidence không chứng minh được phạm vi đó.

## Thay đổi API / backend

- Request, response, status/error, validation, authorization, idempotency/state rõ khi áp dụng.
- Endpoint/DTO công khai cập nhật contract/docs/examples.
- Test tập trung pass, hoặc ghi rõ vì sao không chạy được và manual check an toàn.
- Client/bên phụ thuộc cũ tương thích, hoặc contract ghi breaking change đã phối hợp.

## Thay đổi UI / UX

- Khớp preview/research đã chốt và quy ước design của dự án.
- Hoạt động ở kích thước desktop/mobile đã thống nhất.
- Có loading, empty, error, disabled, long-content state phù hợp.
- Kiểm tra keyboard, label dễ đọc, focus, contrast và semantic structure khi áp dụng.
- Có visual check/screenshot và test/manual step tập trung.

## Thay đổi dữ liệu / migration / state

- State transition, validation, null/legacy data và failure/rollback rõ.
- Xem migration/seed/backfill và compatibility nếu áp dụng.
- Không chạy thay đổi database chung khi chưa có approval riêng theo TEAM_POLICY.

## Tích hợp / thay đổi giữa dự án

- Lead-to-Lead contract ghi field, permission, error, state, nullable behavior và smoke test.
- Không bên nào nhận integration xong trước khi bên kia xác nhận contract/mock/fixture đã thống nhất.
- Không có secret, token, private URL hay dữ liệu production/khách hàng thô trong tin nhắn/evidence.

## Task nghiên cứu / review

- Brief/review nêu câu hỏi, nguồn/path đã xem, evidence, kết luận và action/quyết định.
- Tách rõ fact, giả định và khuyến nghị.
- Không thay file ngoài phạm vi chỉ-đọc/output được giao.

## Mẫu xem trước

~~~
Mục tiêu: <điều cải thiện cho người dùng>
Đề xuất: <bố cục/luồng/hành vi ngắn>
Trên mobile và các trạng thái: <điểm quan trọng>
Điểm cần chốt: <một lựa chọn trực tiếp hoặc đồng ý hướng này>
~~~

Ghi câu trả lời thành PV-### trong TEAM_STATE.md và Task Contract. Preview chỉ chốt hướng, không cấp quyền Git/database/deploy/thay đổi ngoài.
'@
    [System.IO.File]::WriteAllText($qualityGatesPath, $qualityGatesContents, $utf8NoBom)
}

[pscustomobject]@{
    project = $resolvedProjectPath
    teamDirectory = $teamPath
    policy = $policyPath
    rules = $rulesPath
    state = $statePath
    lease = $leasePath
    dashboard = $dashboardPath
    skillRegistry = $skillRegistryPath
    agencyRegistry = $agencyRegistryPath
    externalResearchPolicy = $externalResearchPolicyPath
    researchNotes = $researchNotesPath
    qualityGates = $qualityGatesPath
    modelPolicy = $modelPolicyPath
    modelStatus = $modelStatusPath
    projectHooks = $projectHooksPath
} | ConvertTo-Json -Depth 3
