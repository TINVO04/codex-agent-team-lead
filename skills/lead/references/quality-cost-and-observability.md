# Cổng chất lượng, thời gian và chi phí

Đọc tài liệu này khi Lead chọn cách chạy một hay nhiều worker, lập kế hoạch kiểm thử, xử lý test chập chờn, xem task bị chậm hoặc quyết định có nên mở rộng team. Mục tiêu là giữ chất lượng ổn định mà không biến mọi task thành một vòng kiểm thử dài và tốn token.

## Nguyên tắc chọn đường chạy

Đo từ lúc nhận yêu cầu đến lúc được chấp nhận, không chỉ đo thời gian worker viết code.

```text
Thời gian thật = chờ + đọc context + làm việc + test + sửa lỗi + bàn giao + review + hợp nhất
```

- Task nhỏ, rõ, một vùng: một worker mạnh làm trọn gói.
- Task vừa, một luồng chính: một worker chính; thêm reviewer hoặc smoke check khi rủi ro cần.
- Task lớn, các nhánh độc lập: fan-out theo wave, ownership tách biệt và chỉ định integration owner ngay từ đầu.
- Task chưa rõ: worker khảo sát chỉ-đọc trước; chưa chia writer khi chưa biết phạm vi.

Không mở worker chỉ để đủ số lượng. Sau mỗi task, ghi lại thời gian chờ, thời gian kiểm thử, số lần handoff và số lần làm lại. Nếu nhiều worker không cải thiện độ đúng hoặc làm p95 chậm hơn, quay về đường một worker.

## Xếp mức rủi ro

Mỗi Task Contract ghi một mức:

| Mức | Ví dụ | Kiểm tra tối thiểu |
|---|---|---|
| Thấp | sửa text, đổi tên nội bộ, logic cục bộ | fast check + đối chiếu acceptance |
| Vừa | một API, một module, thay đổi UI có phạm vi rõ | fast check + boundary check hoặc smoke tập trung |
| Cao | auth, permission, public API, migration, state, dữ liệu nhạy cảm | fast + boundary + QA/smoke độc lập |
| Rất cao | thay đổi ảnh hưởng rộng, release, dữ liệu dùng chung | tất cả tầng phù hợp + integration/review độc lập + approval nếu cần |

Mức rủi ro quyết định độ sâu kiểm tra; số lượng worker hay số lượng test không tự quyết định chất lượng.

## Test ladder — kiểm tra theo rủi ro và phần bị ảnh hưởng

### 1. Fast check

Chạy sớm sau thay đổi:

- format/lint;
- typecheck/compile;
- unit test deterministic liên quan trực tiếp;
- kiểm tra import, route hoặc schema bị ảnh hưởng.

Mục tiêu là phản hồi nhanh. Không chạy full suite sau mọi lần sửa nhỏ.

### 2. Boundary check

Chạy khi thay đổi ranh giới giữa các phần:

- API request/response và status/error;
- contract hoặc serialization;
- database/migration/state transition;
- permission, idempotency hoặc tích hợp service.

Ưu tiên test có thể chạy cục bộ, dùng fixture/mock ổn định và chỉ bao phủ boundary đang thay đổi.

### 3. Release check

Chỉ chạy suite rộng, E2E hoặc smoke production-like khi rủi ro yêu cầu, trước merge/release hoặc khi thay đổi module dùng chung. E2E chỉ giữ các luồng quan trọng; không tạo E2E cho mọi nhánh nhỏ.

### Quy tắc test budget

Task Contract phải ghi:

- test bắt buộc và test chỉ cung cấp thông tin;
- thời gian dự kiến và giới hạn thời gian chạy;
- phần bị ảnh hưởng dùng để chọn test;
- điều kiện cần nâng từ fast lên boundary/release;
- bằng chứng có thể dùng lại theo commit/context hash.

Test mới phải trả lời một rủi ro cụ thể. Không thêm test chỉ vì muốn tăng số lượng hoặc lặp lại assertion đã có. Có thể cache dependency/build/artifact và chạy song song các test độc lập, nhưng không chạy song song hai test dùng chung trạng thái không cô lập.

Tóm tắt kết quả test ở handoff; không dán toàn bộ log dài cho worker tiếp theo. Khi test không chạy được, ghi rõ lý do và mức bằng chứng thay thế, không gọi là pass.

## Chính sách test chập chờn

Test chập chờn là test cùng code nhưng lúc pass lúc fail. Xử lý theo thứ tự:

1. Retry tối đa một lần ở cùng điều kiện để phân loại, không retry vô hạn.
2. Ghi seed, môi trường, dependency, artifact và log ngắn.
3. Tách `product-failure`, `environment-failure` và `flaky`.
4. Không âm thầm biến flaky thành xanh. Nếu quarantine, phải có owner, ticket, lý do và ngày hết hạn.
5. Không dùng test đang quarantine làm bằng chứng duy nhất cho task rủi ro cao.
6. Tạo follow-up sửa flaky; hết hạn mà chưa sửa thì quay lại release gate hoặc báo blocker.

## Giới hạn vòng lặp và chi phí

Ngoài giới hạn retry model và sửa code/test trong policy chung, mỗi task cần có:

- giới hạn số lượt gọi tool/model;
- giới hạn thời gian thực;
- giới hạn token/chi phí nếu runtime cung cấp;
- điều kiện dừng khi cùng lỗi lặp lại hoặc không có diff/evidence mới.

Chỉ backoff/retry tự động với lỗi tạm thời và thao tác idempotent. Khi chạm budget, đóng băng checkpoint, gửi bằng chứng cho Lead rồi chuyển `BLOCKED`, `WAITING_USER` hoặc một resolver duy nhất. Không sửa tiếp chỉ để làm cho số test pass tăng lên.

## Hợp nhất và kiểm tra ngữ nghĩa

Git merge không conflict dòng vẫn có thể hỏng về logic. Integration owner phải kiểm tra trạng thái sau khi ghép:

- tên field/parameter và kiểu dữ liệu;
- API/schema/migration;
- state transition và error mapping;
- permission, security và side effect;
- build/typecheck và test theo risk tier.

Nếu cổng hợp nhất fail, chỉ mở một resolver worker có log, checkpoint và acceptance đầy đủ. Không gửi cùng một lỗi cho nhiều writer cũ.

## Theo dõi để biết quy trình có tốt hơn

Ở mỗi task có ý nghĩa, ghi tối thiểu:

- tổng thời gian đến khi được chấp nhận;
- thời gian chờ và thời gian worker hoạt động;
- thời gian test;
- số worker, handoff và retry;
- số lần sửa lại/revert;
- test flaky hoặc lỗi môi trường;
- first-pass acceptance;
- token/chi phí ước tính nếu có;
- lỗi lọt ra sau khi đóng task.

Nếu runtime có tracing, lưu trace ID cùng model/version, context hash, tool/handoff, thời lượng và kết quả. Không đưa secret, token, dữ liệu riêng hoặc log nhạy cảm vào trace. Trace dùng để tìm nút thắt, không thay thế acceptance test.

## Cổng người dùng

Lead chỉ hỏi người dùng khi scope/behavior còn mơ hồ, cần quyền ngoài, chạm budget, cân nhắc rollback/phá hủy hoặc hết model dự phòng. Báo cáo cuối chỉ nêu kết quả, kiểm tra, blocker và quyết định cần người dùng; không đẩy toàn bộ trace hay log nội bộ.
