# Mẫu giao việc cho worker

Mọi worker triển khai, nghiên cứu, test hoặc review phải nhận contract tự đủ. Không giao task mơ hồ.

```markdown
### Task: <ID> — <tiêu đề>

Mục tiêu: <kết quả quan sát được>
Ưu tiên: <P0 | P1 | P2 | P3>
Dự án / module: <phạm vi>
Loại task: <implementation | research | contract | test | review | integration>
Owner điều phối: <Root Lead | Domain Lead>
Rule team áp dụng: <none | R-001, R-002>

Chiến lược workload:
- Chế độ: <single-owner | reviewed-single-owner | parallel-wave | integration | research-first>
- Lý do: <vì sao một worker đủ hoặc vì sao các nhánh độc lập đáng để fan-out>
- Owner hợp nhất: <worker ID/role hoặc none; bắt buộc nếu có từ hai writer>
- Dependency bên ngoài: <none | mục tiêu, bên owner, contract/handover cần có>

Phân công và liên hệ người dùng:
- Owner triển khai: <nhãn worker; bắt buộc cho mọi nghiên cứu hoặc thay đổi file/output>
- Ranh giới Lead: <chỉ yêu cầu người dùng + state .orca-team, xếp lịch, kiểm tra, báo cáo>
- Nói với người dùng: <chỉ Root Lead | role được cho phép rõ; phải nói dễ hiểu>
- Evidence mở worker: <Orca worker-start receipt, Dispatch ID và terminal handle; `input_accepted` chỉ là pending>
- Evidence bắt đầu thật: <worker-show live + activity working, hoặc một lần Enter fallback đã được xác nhận; nếu chưa có thì INPUT_NOT_STARTED/BLOCKED>

Kế hoạch model:
- Route task: <difficult | normal | quick | final review>
- Model chính: <model ID chính xác và effort nếu có>
- Pool model của task: <danh sách model đọc từ MODEL_POLICY.md tại route đã chọn>
- Thứ tự dự phòng: <chỉ model ID được phép>
- Policy revision / model status: <MP-### | model chính hoặc fallback phải verified>
- Tự đổi sang dự phòng: <có | không; theo MODEL_POLICY.md>
- Lần thử cùng model: <1/3, 2/3 hoặc 3/3; chỉ lỗi lần 3 mới được đổi model>
- Launch thực tế: <chỉ điền sau khi runtime xác nhận model và effort>

Capability và skill:
- Capability Gate: <not needed | approved agency role | existing skill | approved project reference | candidate under review | user approval needed>
- Capability cần: <none hoặc capability cụ thể>
- Tài nguyên được dùng: <skill/path/reference đã duyệt hoặc none>
- Registry: <SK-### hoặc none>
- Cấm: <tải skill chưa duyệt, script/hook, chia sẻ credential, upload ngoài>

Vai trò Agency:
- Agency role: <none | AR-### tên vai trò>
- Trạng thái role: <baseline | task-approved | approved | active>
- Card/source revision: <AGENCY_PROFILE_REGISTRY.md record + URL/revision hoặc none>
- Phạm vi áp dụng: <module/quyết định/checklist hẹp hoặc none>
- Không được cấp quyền: <role chỉ là hướng dẫn; không tự cấp Git/cài tool/DB/deploy/credential/đổi model>

Nghiên cứu:
- Research Gate: <routine | research-first | research-deep>
- Câu hỏi cần quyết định: <evidence phải giúp chốt gì>
- Evidence local sẵn có: <path hoặc none>
- Brief nghiên cứu: <RN-### path hoặc pending; cần trước phần triển khai phụ thuộc>
- Loại nguồn được duyệt: <tài liệu chính thức, standard, public example đã nêu hoặc none>
- Ranh giới IP/dữ liệu: <chỉ học nguyên tắc; không sao chép code/asset/chữ; không đưa dữ liệu riêng ra ngoài>
- External research route: <not used | Agency source public-read | Agent-Reach public-only | nguồn khác đã được duyệt>
- Agent-Reach boundary: <none | câu hỏi public hẹp, không login/cookie/token/source nội bộ; tool đã được duyệt>

Chất lượng và xem trước:
- Checklist: <API | UI/UX | data/change | integration | research/review; các mục cần có>
- Risk tier: <low | medium | high | critical>
- Test route: <fast check | boundary check | release check; chọn theo risk tier và phần bị ảnh hưởng>
- Test budget: <thời gian tối đa, test bắt buộc, test informational, điều kiện nâng tầng>
- Impact scope: <dependency graph/path/contract bị ảnh hưởng hoặc chưa biết>
- Evidence bắt buộc: <test, screenshot, manual step, contract check hoặc none>
- First-Pass Gate: <worker evidence review | independent QA | smoke riêng | user review>
- Semantic Integration Gate: <not needed | build/test/smoke toàn cục + integration owner; bắt buộc nếu nhiều writer>
- Evidence tối thiểu trước DONE: <cụ thể>
- Phần có thể chưa kiểm tra: <phạm vi + lý do, hoặc none>
- Flaky/environment policy: <không có | rerun một lần để phân loại + owner/ticket/expiry nếu quarantine>
- Preview Gate: <not needed | internal | user review required>
- Preview record: <PV-### hoặc none>
- Phạm vi phải chờ preview: <path/quyết định hoặc none>

Giới hạn và theo dõi:
- Giới hạn thời gian thực: <phút hoặc none>
- Giới hạn tool/model call: <số lượt hoặc none>
- Giới hạn token/chi phí: <nếu runtime hỗ trợ hoặc none>
- Điều kiện dừng: <cùng lỗi, không có diff/evidence mới, chạm budget hoặc none>
- Trace/observability: <trace ID, context hash hoặc none>

Context:
- <chỉ path, contract hoặc quyết định liên quan>

Vùng ownership:
- Được chạm: `<path/glob chính xác>`
- Không được chạm: `<path chung, vùng worker khác, config/migration...>`

Phụ thuộc:
- <none, task ID hoặc contract record>

Parallel Gate:
- Kết quả: <pass | hard dependency | ownership conflict | contract-first>
- Lý do và reservation: <path/tài nguyên/contract ID cụ thể>

Checkpoint và giới hạn sửa:
- Checkpoint/handover: <path/record hoặc none; bắt buộc trước khi mở rộng task đang làm>
- Tối đa sửa lỗi code/test: <3 lần có evidence cho owner, sau đó resolver hoặc BLOCKED/WAITING_USER>
- Resolver: <none | một resolver worker, phạm vi/budget/acceptance rõ>
- Rollback: <không tự động | chỉ phần task sở hữu khi có checkpoint + quyền người dùng>

Ràng buộc:
- <môi trường, tương thích, bảo mật, approval của người dùng>

Điểm kiểm tra rule:
- Trước khi làm: <ownership/approval/contract>
- Trước DONE: <evidence Lead phải kiểm tra>

Acceptance:
1. <behavior quan sát được>
2. <test/build/manual evidence cụ thể>
3. <tương thích hoặc regression cần giữ>

Báo cáo:
- File thực tế đã thay đổi.
- Lệnh đã chạy và kết quả.
- Giả định, blocker hoặc contract follow-up cần có.
- Sau lần làm đầu, event là `READY_FOR_VERIFICATION`, không phải `DONE`.
- Event cuối phù hợp: `READY_FOR_VERIFICATION`, `BLOCKED`, `NEED_DECISION`, `CONTRACT_CHANGED` hoặc `FAILED`. Chỉ Big Lead ghi `DONE` sau VERIFYING.
- Nếu model/agent lỗi: evidence, file có thể đã đổi không và recovery an toàn cần gì.
- Nếu test vẫn hỏng sau mỗi lần sửa: log, giả thuyết, thay đổi và kết quả; đến giới hạn thì đóng băng checkpoint, không lặp vô hạn.
- Nếu task phình to: chỉ đề xuất fan-out sau khi đã ghi handover và tách được ownership độc lập; không gọi thêm writer vào vùng đang sửa.
- Thiếu capability: gửi `CAPABILITY_REQUEST`; không tự tìm/cài/chạy skill.
- Thiếu role: gửi `CAPABILITY_REQUEST`; không tự tải Agency bundle, cài custom agent hoặc dùng raw profile chưa có AR-###.
- Thiếu evidence nghiên cứu: gửi `RESEARCH_REQUEST`; không browse rộng hay dùng material bên thứ ba ngoài source plan.
- Trước `READY_FOR_VERIFICATION`: chạy/báo checklist chất lượng, nêu evidence và phần chưa kiểm tra. File đổi, build pass đơn lẻ hoặc worker claim chưa kiểm tra không đủ evidence.
- Không thêm test trùng assertion chỉ để tăng số lượng. Tóm tắt log test thay vì chuyển toàn bộ log dài sang worker tiếp theo; nếu test flaky, không coi retry pass là bằng chứng xanh.
- Khi task kết thúc, báo thời gian làm/chờ/test, số retry/handoff, rework và chi phí/token nếu có để Lead so sánh đường một worker với fan-out.

Handover recovery (chỉ điền khi retry):
- Dispatch/session trước: <ID thật hoặc none>
- Trạng thái đã chứng minh: <failed | stopped>; không dùng unknown/disconnected.
- Model/effort và lần thử cùng model: <model | effort | 1/3, 2/3 hoặc 3/3>
- File/checkpoint đã kiểm tra: <path và kết quả>
- Tiếp từ: <retry cùng model nếu đang 1/3 hoặc 2/3 | model kế tiếp trong đúng pool chỉ sau lỗi 3/3; không làm lại phần đã verify>
- Ownership: <giữ cùng task đến khi replacement settle>
```

Với điều tra/review chỉ-đọc, để ownership zone là `none` và nêu rõ output nào là acceptance. Review hoàn tất chỉ cho phép kết luận; không cho phép Lead tự sửa theo kết luận đó.
