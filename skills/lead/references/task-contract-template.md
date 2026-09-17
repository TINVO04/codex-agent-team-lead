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

Phân công và liên hệ người dùng:
- Owner triển khai: <nhãn worker; bắt buộc cho mọi nghiên cứu hoặc thay đổi file/output>
- Ranh giới Lead: <chỉ yêu cầu người dùng + state .orca-team, xếp lịch, kiểm tra, báo cáo>
- Nói với người dùng: <chỉ Root Lead | role được cho phép rõ; phải nói dễ hiểu>
- Evidence mở worker: <Orca Task/Dispatch và terminal handle; để pending đến khi Orca trả>

Kế hoạch model:
- Route task: <difficult | normal | quick | final review>
- Model chính: <model ID chính xác và effort nếu có>
- Thứ tự dự phòng: <chỉ model ID được phép>
- Lần thử: <1/3, 2/3 hoặc 3/3>
- Launch thực tế: <chỉ điền sau khi runtime xác nhận model và effort>

Capability và skill:
- Capability Gate: <not needed | existing skill | approved project reference | candidate under review | user approval needed>
- Capability cần: <none hoặc capability cụ thể>
- Tài nguyên được dùng: <skill/path/reference đã duyệt hoặc none>
- Registry: <SK-### hoặc none>
- Cấm: <tải skill chưa duyệt, script/hook, chia sẻ credential, upload ngoài>

Nghiên cứu:
- Research Gate: <routine | research-first | research-deep>
- Câu hỏi cần quyết định: <evidence phải giúp chốt gì>
- Evidence local sẵn có: <path hoặc none>
- Brief nghiên cứu: <RN-### path hoặc pending; cần trước phần triển khai phụ thuộc>
- Loại nguồn được duyệt: <tài liệu chính thức, standard, public example đã nêu hoặc none>
- Ranh giới IP/dữ liệu: <chỉ học nguyên tắc; không sao chép code/asset/chữ; không đưa dữ liệu riêng ra ngoài>

Chất lượng và xem trước:
- Checklist: <API | UI/UX | data/change | integration | research/review; các mục cần có>
- Evidence bắt buộc: <test, screenshot, manual step, contract check hoặc none>
- Preview Gate: <not needed | internal | user review required>
- Preview record: <PV-### hoặc none>
- Phạm vi phải chờ preview: <path/quyết định hoặc none>

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
- Một event: `DONE`, `BLOCKED`, `NEED_DECISION`, `CONTRACT_CHANGED` hoặc `FAILED`.
- Nếu model/agent lỗi: evidence, file có thể đã đổi không và recovery an toàn cần gì.
- Thiếu capability: gửi `CAPABILITY_REQUEST`; không tự tìm/cài/chạy skill.
- Thiếu evidence nghiên cứu: gửi `RESEARCH_REQUEST`; không browse rộng hay dùng material bên thứ ba ngoài source plan.
- Trước `DONE`: chạy/báo checklist chất lượng. File đổi, build pass đơn lẻ hoặc worker claim chưa kiểm tra không đủ evidence.

Handover recovery (chỉ điền khi retry):
- Dispatch/session trước: <ID thật hoặc none>
- Trạng thái đã chứng minh: <failed | stopped>; không dùng unknown/disconnected.
- File/checkpoint đã kiểm tra: <path và kết quả>
- Tiếp từ: <bước kế tiếp cụ thể; không làm lại phần đã verify>
- Ownership: <giữ cùng task đến khi replacement settle>
```

Với điều tra/review chỉ-đọc, để ownership zone là `none` và nêu rõ output nào là acceptance. Review hoàn tất chỉ cho phép kết luận; không cho phép Lead tự sửa theo kết luận đó.
