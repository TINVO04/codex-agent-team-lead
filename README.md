<div align="center">

# ⚡ Orca Codex Team Lead

### Bộ quy trình điều phối agent cho Codex chạy bên trong Orca

Một Big Lead giữ hướng đi. Worker làm việc thật. Mỗi người một phần rõ ràng.

<p>
  <img src="https://img.shields.io/badge/Runtime-Orca-111827?style=for-the-badge" alt="Orca" />
  <img src="https://img.shields.io/badge/Language-Ti%E1%BA%BFng%20Vi%E1%BB%87t-0f766e?style=for-the-badge" alt="Tiếng Việt" />
  <img src="https://img.shields.io/badge/License-MIT-f59e0b?style=for-the-badge" alt="MIT License" />
</p>

<p>
  <strong>Chia việc đúng người · Làm song song có kiểm soát · Báo cáo dễ hiểu</strong>
</p>

</div>

> Đây là quy trình dành cho **Codex chạy trong Orca**. Orca phải đang chạy để tạo terminal, theo dõi worker, đổi tên terminal, gửi thông báo và khôi phục sau khi có lỗi.

## 🌟 Vì sao nên dùng

Khi dự án có nhiều việc cùng lúc, vấn đề thường không phải thiếu agent mà là:

- Không biết agent nào đang làm việc gì.
- Hai agent sửa trùng một vùng code.
- Lead tự làm hết nên không còn điều phối.
- Terminal bị lỗi nhưng task vẫn bị xem là đang chạy.
- Có kết quả nhưng không có bằng chứng để biết đã thật sự xong chưa.

Quy trình này giải quyết bằng một nguyên tắc đơn giản:

```text
Big Lead giữ bản đồ và quyết định
        ↓
Lead phụ chỉ xuất hiện khi một mảng đủ lớn
        ↓
Worker nghiên cứu, code, test và tạo bằng chứng
        ↓
QA kiểm tra lại
        ↓
Big Lead báo kết quả ngắn gọn cho người dùng
```

## 🚀 Bắt đầu nhanh

### 1. Cài quy trình vào Orca

Copy thư mục `skills/lead` vào thư mục skill của Orca:

```text
%USERPROFILE%\.agents\skills\lead
```

Sau đó khởi động lại Orca hoặc mở một terminal Codex mới.

### 2. Khởi tạo trong dự án

Trong terminal Codex của Orca, gõ `$`, chọn **Orca Codex Team Lead**, rồi gửi:

```text
Khởi tạo team cho dự án này.
```

Hoặc gửi trực tiếp:

```text
$lead init
```

Lần đầu khởi tạo sẽ tạo thư mục `.orca-team/` và kiểm tra một Big Lead duy nhất cho dự án.

> Không dùng `/lead`. Dấu `/` là lệnh có sẵn của Codex Terminal; `$lead` là skill điều phối của Orca.

### 3. Giao việc

```text
$lead Thêm API suspend/restore cho job và viết smoke test.
```

Big Lead sẽ ghi task, kiểm tra vùng code, chọn worker phù hợp và chỉ mở worker khi Orca trả về terminal thật.

## 🧭 Nhìn toàn bộ quy trình

```mermaid
flowchart TD
    U["Người dùng giao yêu cầu"] --> B["00 | BIG | Big Lead"]
    B --> T{"Task đã rõ và không trùng ownership?"}
    T -- "Chưa" --> Q["QUEUED / BLOCKED / hỏi người dùng"]
    T -- "Rồi" --> R{"Đã có vai trò phù hợp?"}
    R -- "Có" --> W["Worker nhận Task Contract"]
    R -- "Chưa" --> C["CAPABILITY-SCOUT tìm role/skill"]
    C --> W
    W --> E["Worker nghiên cứu / code / test"]
    E --> V["QA hoặc Final Review"]
    V --> B
    B --> O["Báo cáo ngắn gọn cho người dùng"]
```

## 👥 Ai làm việc gì?

| Vai trò | Trách nhiệm | Không làm |
|---|---|---|
| **Big Lead** | Nhận yêu cầu, chia việc, xếp ưu tiên, giữ state, kiểm tra bằng chứng, báo người dùng | Không tự code, debug, test hay nghiên cứu thay worker |
| **Lead phụ** | Điều phối một mảng lớn như `AUTH`, `ADMIN`, `JOBS` | Không sở hữu toàn bộ dự án, policy hoặc Git |
| **Worker** | Nghiên cứu, sửa code, viết test, cập nhật tài liệu và báo kết quả | Không tự đổi scope, tự dùng quyền ngoài task |
| **QA / Final Review** | Kiểm tra acceptance, regression, contract và bằng chứng cuối | Không tự sửa phần của worker khác nếu chưa được giao |
| **Capability Scout** | Tìm vai trò Agency/skill phù hợp khi team đang thiếu năng lực | Không tự cài tool hoặc biến role thành Lead mới |
| **Research Worker** | Tìm và tổng hợp nguồn cần thiết cho quyết định | Không đưa dữ liệu riêng ra ngoài |

### Quy tắc quan trọng

**Lead điều phối, worker làm việc thật.** Nếu một task có nghiên cứu, code, test, debug hoặc sửa file mà không có worker terminal hiển thị, dùng:

```text
$lead audit
```

Lead phải để task chờ kiểm tra, không tự làm thay chỉ để báo nhanh hơn.

## 🖥️ Nhận diện terminal

Tên terminal luôn bắt đầu bằng số để nhìn ra quan hệ:

```text
00 | BIG          | MEU-HIRE-FE     | RUN
10 | LEAD-ADMIN   | T-100           | RUN
11 | WORKER-API   | T-101.1         | RUN
12 | WORKER-UI    | T-101.2         | RUN
19 | QA-ADMIN     | T-101.QA        | CHECK
90 | VIEW         | MEU-HIRE-FE     | VIEWER_ONLY
```

- `00`: Big Lead duy nhất của dự án.
- `10–19`: một nhánh Lead phụ và các worker của nhánh đó.
- `20–29`: nhánh tiếp theo.
- `90`: terminal xem trạng thái, không được tự mở worker.

Mở terminal thứ hai trong cùng dự án **không** tạo Big Lead thứ hai. Terminal đó là viewer cho đến khi recovery/takeover được xác minh.

## 🧠 Agency Agents: chọn đúng chuyên môn

Agency Agents được dùng như **thư viện vai trò chuyên môn**, không phải hệ thống điều phối thứ hai.

Khi chạy `$lead init`, nếu còn slot, Big Lead giao một worker chỉ-đọc lập danh sách vai trò phù hợp với dự án trong:

```text
.orca-team/AGENCY_PROFILE_REGISTRY.md
```

Ví dụ:

| Loại dự án | Vai trò thường phù hợp |
|---|---|
| API / Backend | Backend Architect, API Tester, Database Optimizer, Identity & Access Engineer |
| Frontend / Web | Frontend Developer, UI Designer, Accessibility Auditor, Test Automation Engineer |
| Auth / dữ liệu nhạy cảm | Application Security Engineer, Privacy Engineer, Code Reviewer |
| Công nghệ hoặc kiến trúc mới | Research Synthesist trước, rồi worker triển khai |

Khi gặp yêu cầu mới:

```text
Role đã duyệt trong dự án
        ↓ chưa có
CAPABILITY-SCOUT tìm profile phù hợp trong Agency
        ↓ vẫn chưa đủ
Research Worker tìm tài liệu công khai
        ↓
Worker triển khai nhận card role ngắn
```

Role Agency không tự:

- tạo Lead hoặc terminal;
- đổi model;
- cấp quyền Git, database, deploy hoặc service;
- tự cài bundle agent;
- thay đổi scope mà người dùng đã giao.

## 🌐 Agent-Reach: tìm nguồn công khai có kiểm soát

Agent-Reach chỉ dành cho **Research Worker** khi tài liệu nội bộ, tài liệu chính thức và standard chưa đủ.

Được phép mặc định:

- đọc website công khai, RSS, YouTube công khai, GitHub công khai;
- tìm ví dụ và thảo luận công khai để hỗ trợ quyết định;
- ghi nguồn, kết luận và giới hạn evidence vào `.orca-team/RESEARCH_NOTES/`.

Không được phép mặc định:

- tự cài Agent-Reach hoặc dependency mới;
- dùng cookie, token, tài khoản đăng nhập, Chrome profile hoặc proxy;
- gửi source nội bộ, URL private, log chưa lọc, thông tin khách hàng hoặc dữ liệu production;
- đăng bài, nhắn tin, like, tạo issue/PR hoặc thao tác ghi bên ngoài.

Nếu cần cài tool, dùng login/cookie hoặc gửi dữ liệu ra dịch vụ ngoài, task chuyển sang `WAITING_USER` để hỏi bạn trước.

## 📋 Các lệnh thường dùng

| Lệnh | Dùng khi |
|---|---|
| `$lead` | Khôi phục state và xem việc đang làm |
| `$lead init` | Khởi tạo team lần đầu trong dự án |
| `$lead status` | Chỉ xem trạng thái, không mở worker |
| `$lead audit` | Kiểm tra Lead có ôm việc hoặc task có thiếu worker không |
| `$lead roles` | Xem vai trò Agency đang có/chờ duyệt/đang dùng |
| `$lead capability <nhu cầu>` | Tìm năng lực hoặc role còn thiếu |
| `$lead research <chủ đề>` | Tạo nghiên cứu có phạm vi rõ |
| `$lead preview <chủ đề>` | Xin người dùng chốt hướng UI/UX hoặc flow lớn |
| Yêu cầu `$lead report today` | Tổng hợp hôm nay đã làm gì, đang vướng gì và bước tiếp theo |
| `$lead recover` | Khôi phục sau khi Orca restart |
| `$lead take over` | Thay Big Lead cũ khi đã xác minh lỗi/dừng hoặc có xác nhận của người dùng |
| `$lead rules` | Xem rule đang áp dụng |

## 📝 Báo cáo cuối ngày

Khi bạn hỏi “hôm nay team đã làm gì?”, **Big Lead** sẽ tổng hợp từ state và báo cáo của worker:

1. Đã hoàn thành.
2. Đang thực hiện.
3. Bị chặn.
4. Đã kiểm tra.
5. Việc tiếp theo.

Ví dụ:

```text
Hôm nay team đã:

- Hoàn thành API suspend/restore job.
- Thêm kiểm tra Idempotency-Key.
- Chạy smoke test cho các trạng thái chính.
- Đang chờ cấp permission mới từ backend.

Việc tiếp theo: lấy JWT mới và chạy smoke test end-to-end.
```

Nếu cần tạo báo cáo thành file, Big Lead có thể giao `Technical Writer`, `Meeting Notes Specialist` hoặc `Executive Summary Generator`. Các role này chỉ viết từ bằng chứng đã có, không tự đoán kết quả.

## 🔁 Khi có nhiều yêu cầu cùng lúc

Yêu cầu mới không tự hủy việc đang làm:

```text
Yêu cầu 1 đang chạy
        + Yêu cầu 2 đến
        + Yêu cầu 3 đến
                ↓
Big Lead ghi cả 3 vào task board
                ↓
Task độc lập → READY / chạy song song
Task cần việc khác → QUEUED hoặc BLOCKED
Task cần bạn chọn → WAITING_USER
```

Mặc định một Big Lead có tối đa ba worker triển khai. Chỉ tạo Lead phụ khi có ít nhất hai nhánh độc lập, đủ việc dài hạn và Orca còn capacity. Khi hết việc, Lead phụ và worker được thu gọn.

## 🧪 Cổng chất lượng

Một worker nói “xong” chưa đủ để task được đóng. Big Lead phải kiểm tra checklist phù hợp:

- **API/backend:** request, response, status/error, permission, state, idempotency và test.
- **UI/UX:** desktop/mobile, loading, empty, error, accessibility và visual check.
- **Database/state:** migration, null/legacy data, rollback và compatibility.
- **Tích hợp BE/FE:** contract, field nullable, permission, error mapping và smoke test.
- **Research/review:** nguồn, kết luận, đánh đổi, giới hạn và quyết định.

Với màn hình mới, redesign lớn hoặc đổi flow, Big Lead gửi preview để bạn chốt hướng trước khi worker làm phần quyết định.

## 🤖 Model và khôi phục lỗi

| Vai trò / việc | Model chính | Dự phòng |
|---|---|---|
| Big Lead / Lead phụ | `gpt-5.6-terra` · `xhigh` | `qwen3.8-max-0902` |
| Worker việc khó | `qwen3.8-max-0902` · `high` | DeepSeek → GLM |
| Worker việc thường | `deepseek-v4.1-flash` · `medium` | Qwen → GLM |
| Worker việc nhỏ | `glm-5.3-flash` · `low` | DeepSeek → Qwen |
| Kiểm tra cuối | `qwen3.8-max-0902` · `high` | DeepSeek → GLM |

Nếu worker lỗi model:

1. Orca xác nhận worker cũ thật sự lỗi hoặc đã dừng.
2. Giữ ownership vùng code cũ.
3. Kiểm tra checkpoint và file đã thay đổi.
4. Tạo worker retry cho **cùng task** bằng model dự phòng.
5. Không để hai worker cùng sửa một vùng.

Nếu cả model chính và dự phòng đều lỗi, task chuyển `WAITING_USER`.

## 🗂️ Những gì được tạo trong mỗi dự án

```text
.orca-team/
├── TEAM_POLICY.md                  # Ranh giới và chính sách team
├── TEAM_RULES.md                   # Rule do người dùng/Root Lead đặt
├── TEAM_STATE.md                   # Mục tiêu, task, owner, dependency
├── LEAD_LEASE.md                   # Big Lead duy nhất
├── TEAM_DASHBOARD.md               # Bảng nhìn nhanh toàn team
├── AGENCY_PROFILE_REGISTRY.md      # Vai trò Agency theo dự án
├── SKILL_REGISTRY.md               # Skill chờ duyệt/đã duyệt/đang dùng
├── EXTERNAL_RESEARCH_POLICY.md     # Luật Agent-Reach và nguồn ngoài
├── QUALITY_GATES.md                # Checklist trước khi báo xong
└── RESEARCH_NOTES/                 # Brief nghiên cứu dùng lại được
```

State trong `.orca-team` là sổ điều phối, không thay thế inventory Orca live. Sau khi Orca restart, phải dùng `$lead recover` để kiểm tra terminal thật trước khi giao lại việc.

## 🔐 Ranh giới an toàn

- Không tự chạy Git nếu người dùng chưa duyệt theo policy dự án.
- Không tự chạy migration database dùng chung.
- Không tự đổi DB target, restart service, deploy hoặc đổi permission remote.
- Không gửi credential, token, private URL, log nhạy cảm hay dữ liệu khách hàng qua tin nhắn team.
- Không coi dashboard cũ là bằng chứng worker còn sống sau khi Orca restart.
- Agent nói với người dùng phải nói tiếng Việt ngắn gọn, kết quả trước, không đẩy log nội bộ.

## 🛠️ Cấu trúc repository

```text
skills/lead/
├── SKILL.md
├── agents/openai.yaml
├── references/
│   ├── agency-profiles-and-agent-reach.md
│   ├── capability-discovery-and-skill-gate.md
│   ├── research-first-gate.md
│   ├── task-contract-template.md
│   └── ...
└── scripts/bootstrap-project.ps1
```

## 📚 Nguồn tham khảo

- [Agency Agents](https://github.com/msitarzewski/agency-agents) — thư viện vai trò chuyên môn.
- [Agent-Reach](https://github.com/Panniantong/Agent-Reach) — công cụ tìm nguồn công khai, chỉ dùng theo policy.
- [Codex Skills](https://developers.openai.com/codex/skills/) — cấu trúc và cách Codex sử dụng skill.

## 📄 Giấy phép

MIT. Xem [LICENSE](LICENSE).

<div align="center">

### Làm đúng người · Đúng việc · Đúng bằng chứng

</div>
