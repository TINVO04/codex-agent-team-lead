# Workload thích ứng, hợp nhất và khôi phục

Tài liệu này dùng khi một yêu cầu có thể chạy bằng một worker hoặc cần mở rộng thành nhiều worker. Mục tiêu là giữ chất lượng ổn định và chỉ trả thêm thời gian khi việc chia nhỏ tạo ra lợi ích thật.

## Nguyên tắc chọn cách chạy

Lead không mặc định mở nhiều worker. Hãy chọn đường chạy ngắn nhất vẫn đủ bằng chứng và tính cả thời gian chờ, đọc context, handoff, test và hợp nhất:

| Tình huống | Cách chạy mặc định | Cổng chất lượng |
|---|---|---|
| Sửa cực nhỏ (≤ 3 dòng, 1 file) | Quick-Fix Bypass (Lead hoặc 1 Worker) | Fast-check cú pháp/lint trực tiếp trong 1 nhịp |
| Dự án mới / MVP ($lead proto) | Prototype Mode (1 worker trọn gói) | Run/launch check không crash + cú pháp sạch, không ép test suite |
| Việc nhỏ, rõ, một vùng | Một worker làm trọn gói (Solo Mode) | Worker tự kiểm tra + đối chiếu acceptance |
| Việc vừa, có một luồng chính | Một worker chính; chỉ thêm reviewer khi rủi ro cần | Reviewer hoặc smoke check có mục tiêu |
| Việc lớn, nhiều nhánh độc lập | Fan-out theo wave, ownership không chồng lấn ($lead team) | Một integration worker hợp nhất + kiểm tra toàn cục |
| Phạm vi chưa rõ | Một worker khảo sát chỉ-đọc | Brief/checkpoint trước khi triển khai |

Không mở thêm worker chỉ để đủ số lượng. Nếu các phần phải chờ cùng một ngữ cảnh, cùng file hoặc cùng quyết định thì giữ một owner chính thay vì chia giả.

## Cổng fan-out

Trước khi chia một task thành nhiều worker, ghi vào Task Contract:

1. Mỗi nhánh có đầu vào, đầu ra và acceptance riêng.
2. Các nhánh không cùng sửa một ownership zone.
3. Có thể chạy song song mà không cần đọc kết quả chưa hoàn thành của nhánh khác.
4. Có một owner hợp nhất được chỉ định ngay từ đầu.
5. Thời gian mở, chờ và hợp nhất dự kiến không lớn hơn lợi ích của việc chạy song song.

Nếu thiếu một điều kiện, dùng một worker chính hoặc chạy theo thứ tự. Phối hợp với dự án/nhóm bên ngoài chỉ bật khi dependency thật sự xuất hiện; không gắn cứng theo tên hay loại dự án.

Sau mỗi task, ghi thời gian giao → được chấp nhận, thời gian worker, thời gian test, số handoff/retry và số lần sửa lại. Fan-out chỉ được giữ làm mặc định cho một loại task nếu nó cải thiện first-pass acceptance hoặc giảm thời gian tổng mà không làm chi phí/review tăng quá mức.

## Semantic Integration Gate

Merge không có conflict dòng không chứng minh hệ thống đúng. Sau khi nhiều worker hoàn thành:

- Integration worker phải đọc các thay đổi và chạy build/test hoặc smoke check toàn cục phù hợp với task (áp dụng Selective Testing đối với monorepo: chỉ test/build các package bị ảnh hưởng và upstream dependencies liên quan).
- Kiểm tra cả contract, tên tham số, schema, cấu hình, trạng thái và đường gọi giữa các vùng; không chỉ xem Git diff.
- Nếu dùng nhiều worktree, mọi thao tác merge/Git vẫn cần quyền Git của người dùng theo policy. Nếu chưa có quyền, integration worker kiểm tra trên trạng thái được phép và báo phần chưa thể hợp nhất.
- Nếu build/test toàn cục hỏng, chỉ mở **một** resolver worker cho cùng integration task. Resolver nhận build log, checkpoint, các file đã đổi và acceptance; không ném lỗi ngược đồng thời cho các writer cũ.
- Không được báo `DONE` nếu integration gate chưa đạt hoặc chưa ghi rõ blocker.

## Bounded Repair và Retry Loop

Tách hai loại lỗi:

- Lỗi provider/model/runtime: dùng quy tắc retry cùng model tối đa ba lần rồi mới xoay trong pool đã được duyệt.
- Lỗi code, test, contract hoặc thiết kế: không tự coi là lỗi model và không tự đổi model chỉ vì test fail.

Với một owner đang sửa lỗi kiểm tra, mặc định tối đa ba lần sửa có bằng chứng. Mỗi lần phải ghi test fail, giả thuyết, thay đổi và kết quả mới. Sau lần thứ ba:

1. Đóng băng trạng thái tại checkpoint và ghi nguyên nhân, không tiếp tục vòng lặp vô hạn.
2. Nếu còn khả năng giải quyết an toàn, mở đúng một resolver worker mạnh hơn với handover đầy đủ; resolver có ngân sách riêng được ghi trong Task Contract.
3. Nếu resolver không đạt hoặc thiếu quyền/quyết định, chuyển `BLOCKED`/`WAITING_USER` và báo rõ phần đã giữ lại.

Không tự động `git revert`, xóa toàn bộ diff hoặc ghi đè phần đã làm đúng. Chỉ rollback đúng thay đổi do task sở hữu khi đã có checkpoint, ownership rõ và người dùng cho phép thao tác đó.

Test không ổn định là một trạng thái riêng, không phải pass. Retry tối đa một lần để phân loại `product-failure`, `environment-failure` hoặc `flaky`; quarantine phải có owner, ticket và hạn xử lý. Không mở resolver chỉ để làm tăng số test pass khi chưa có giả thuyết mới.

## Mở rộng giữa chừng và bàn giao ngữ cảnh

Không thêm writer mới vào cùng vùng trong lúc worker cũ còn đang sửa dở. Nếu task phình to:

1. Worker hiện tại dừng tại checkpoint an toàn, không dừng giữa một thay đổi chưa kiểm tra.
2. Worker ghi handover ngắn vào đường dẫn state của task, tối thiểu gồm: mục tiêu, quyết định đã chốt, file đã đổi, test đã chạy, phần còn lại, dependency, rủi ro và bước tiếp theo.
3. Lead cập nhật ownership và chia các nhánh mới chỉ khi chúng độc lập.
4. Worker mới đọc handover và trạng thái thật trước khi làm; không suy đoán từ tên terminal hoặc lịch sử chat.
5. Worker cũ được settle/release hoặc chuyển thành integration owner; không để hai worker cùng sửa một vùng.

Nếu không tạo được nhánh độc lập, không mở rộng. Giữ một worker chính làm tiếp thường nhanh và ít mất ngữ cảnh hơn.

## Model tiering theo rủi ro

Model phải được chọn theo phần việc thật, không chỉ theo nhãn “nhanh” hay “thường”:

- Worker viết code, sửa bug, thay đổi contract/state hoặc làm integration dùng model mạnh nhất đã `verified` trong pool được người dùng cho phép.
- Model nhanh dùng cho đọc, phân loại, tài liệu, kiểm tra cơ học hoặc nhánh có acceptance rất hẹp; không dùng mặc định cho thay đổi cần hiểu nhiều file.
- Reviewer/integration dùng model đủ mạnh để đọc toàn bộ kết quả, không mặc định dùng model rẻ hơn writer.
- Lead tuân theo route model người dùng đã chọn; tốc độ điều phối không cho phép Lead tự làm code hoặc tự dùng model ngoài policy.

## Đo lợi ích thật

Lead ghi tối thiểu: thời gian từ giao đến kết quả, số lần sửa lại, kết quả kiểm tra, số worker tạo ra giá trị và phần thời gian chờ/hợp nhất. Nếu fan-out lặp lại nhưng không tăng độ đúng hoặc làm p95 chậm hơn, route đó phải quay về một worker chính.

Task Contract cũng phải có test route (`fast`, `boundary`, `release`), test bắt buộc/informational và budget. Fast check chạy trước; boundary/release chỉ chạy khi risk tier hoặc phạm vi thay đổi yêu cầu. Tóm tắt log test, không chuyển toàn bộ log dài qua handoff. Nếu runtime hỗ trợ, ghi trace ID, context hash, model/tool/handoff và chi phí để tìm nút thắt thật.
