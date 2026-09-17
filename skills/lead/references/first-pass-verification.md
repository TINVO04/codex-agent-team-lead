# First-Pass Gate: lần làm đầu phải được kiểm tra

Nguyên tắc: lần triển khai đầu tiên **có thể đúng**, nhưng không tự động là kết quả cuối. Nó chỉ trở thành `DONE` khi có kiểm tra phù hợp với rủi ro và evidence nhìn thấy được.

Mục đích là tránh tự tin quá sớm, không phải bắt mọi task chạy lại nhiều vòng hoặc tạo QA dư thừa.

## Trạng thái task

```text
ACTIVE
  → READY_FOR_VERIFICATION
  → VERIFYING
  → DONE
     hoặc ACTIVE (cần sửa thêm)
     hoặc BLOCKED (không thể kiểm tra tiếp)
```

- `READY_FOR_VERIFICATION`: worker đã xong phần mình làm và đã nộp evidence; chưa được gọi là hoàn tất với người dùng.
- `VERIFYING`: Lead/QA đang so evidence với acceptance, rule và checklist.
- `DONE`: Big Lead đã nhận evidence đủ mức cần thiết.

Worker không gửi `DONE` ngay sau lần làm đầu. Worker gửi event `READY_FOR_VERIFICATION` với kết quả, evidence, phần chưa kiểm tra và rủi ro còn lại. Nếu làm lại sau review, cũng đi qua cổng này trước `DONE`.

## Evidence cần có

Task Contract phải ghi trước:

- đường kiểm tra: `worker evidence review`, `independent QA`, `smoke riêng` hoặc `user review`;
- evidence tối thiểu: test, manual step, screenshot, contract check, log đã lọc, review…;
- phần không kiểm tra được và lý do;
- điều kiện quay về `ACTIVE`, `BLOCKED` hoặc `WAITING_USER`.

Không được dùng những câu như “chắc chắn đúng”, “không còn lỗi” hoặc “sẵn sàng production” nếu evidence không chứng minh được phạm vi đó.

## Chọn mức kiểm tra vừa đủ

| Mức task | Cách kiểm tra phù hợp |
|---|---|
| Hẹp, rủi ro thấp | Worker evidence + Big Lead đối chiếu acceptance/rule |
| Trung bình | Test hoặc manual smoke tập trung, cộng review evidence |
| Rủi ro cao | QA độc lập hoặc smoke evidence tách riêng trước DONE |

Task rủi ro cao gồm: auth/permission, payment, database/migration/state, API public/contract, tích hợp BE–FE, dữ liệu nhạy cảm hoặc thay đổi có thể ảnh hưởng nhiều người dùng.

Một worker được phép tự chạy kiểm tra trong vùng mình sở hữu khi Task Contract cho phép. `Independent QA` không bắt buộc cho mọi sửa nhỏ; khi cần, QA không sửa cùng lúc vào vùng writer của worker.

## Vai trò

- Worker: triển khai, tự kiểm tra theo contract, nói rõ giới hạn và gửi `READY_FOR_VERIFICATION`.
- QA / Final Review: kiểm tra độc lập khi risk cần hoặc khi contract đã chọn route đó.
- Root/Domain Lead: chọn mức kiểm tra trước khi giao, đọc evidence, giữ trạng thái task đúng và chỉ Root Lead báo `Đã xong` cho người dùng.

## Mẫu event worker

```text
READY_FOR_VERIFICATION
- Đã thay đổi: <kết quả ngắn>
- Đã kiểm tra: <lệnh/manual step và kết quả>
- Chưa kiểm tra: <phạm vi + lý do, hoặc không có>
- Rủi ro/follow-up: <nếu có>
```

Nếu evidence thiếu, Lead trả task về `ACTIVE` với câu hỏi hoặc việc sửa rõ ràng. Nếu không thể chạy check vì thiếu quyền/môi trường, task không được nói là xong; chuyển `BLOCKED` hoặc `WAITING_USER` và giải thích ngắn với người dùng.
