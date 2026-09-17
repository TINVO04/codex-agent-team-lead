# Cổng chất lượng và xem trước

Dùng tài liệu này khi Lead định nghĩa “xong”, kiểm tra kết quả worker, hoặc quyết định thay đổi UI/UX/luồng có cần người dùng xem trước không. Đọc [First-Pass Gate](first-pass-verification.md) trước khi chuyển một task sang `DONE`.

## Cổng chất lượng: “xong” phải thấy được

Mỗi Task Contract chọn checklist đúng trong `.orca-team/QUALITY_GATES.md` và ghi evidence cụ thể. Chỉ chọn phần liên quan; task tài liệu hẹp không cần checklist migration.

Lần làm đầu không tự là `DONE`: worker báo `READY_FOR_VERIFICATION`, Task chuyển `VERIFYING`, sau đó Lead mới có thể đóng task. Lead tối thiểu phải kiểm tra:

1. Kết quả mục tiêu đã xảy ra, không chỉ là file đã đổi.
2. Test hoặc manual check phù hợp đã chạy/ghi rõ.
3. Public contract và nghĩa vụ BE–FE đã được xử lý nếu có thay đổi.
4. Không phá rule, approval boundary hoặc ownership của worker khác.
5. Claim `DONE` có evidence Lead xem được.

Lời worker nói, build pass một mình hoặc một screenshot một mình không đủ cho mọi task. Kết hợp evidence phù hợp với thay đổi. Với auth/permission, payment, database/migration/state, API public/contract và tích hợp BE-FE, Task Contract phải chọn QA độc lập hoặc smoke evidence tách riêng.

## Cổng xem trước: chốt trước việc chủ quan lớn

Lead phân loại:

- `not needed`: bảo trì cục bộ hoặc thay đổi nhỏ, đã có spec rõ.
- `internal`: lựa chọn kỹ thuật/thiết kế nhỏ, team ghi lại nhưng không cần gu người dùng.
- `user review required`: quyết định ảnh hưởng đáng kể đến cách người dùng nhìn, đi lại, hiểu hoặc dùng sản phẩm.

Mặc định phải hỏi người dùng xem trước cho: trang mới/dashboard lớn, redesign đáng kể/hướng visual mới, thay đổi navigation/hierarchy, luồng mới/đổi nhiều như đăng ký, moderation, thanh toán, onboarding, hoặc lựa chọn nội dung/hành vi nhìn thấy có hai hướng hợp lý.

Chỉ bỏ qua khi người dùng nói làm trực tiếp, đã đưa final design/spec, hoặc thay đổi thật sự nhỏ. Ghi lý do bỏ qua trong Task Contract.

## Nội dung người dùng nhận

Ngắn, dễ hiểu và chỉ để chốt. Không gửi thiết kế dài hay chi tiết nội bộ.

```text
Mục tiêu: <vấn đề người dùng được cải thiện>
Đề xuất: <bố cục/luồng trong vài dòng>
Trên mobile và các trạng thái: <khác biệt quan trọng>
Điểm cần chốt: <một lựa chọn trực tiếp hoặc “đồng ý hướng này”>
```

Nếu hữu ích, kèm wireframe chữ, screenshot hiện có hoặc mockup nhỏ. Không làm bản triển khai đầy đủ chỉ để hỏi người dùng thích hướng nào.

Sau khi người dùng trả lời, ghi `PV-###` trong `TEAM_STATE.md` và Task Contract. Worker mới được thay đổi phần nhạy cảm với hướng đã chốt. Người dùng đổi ý thì cập nhật record và chia lại task tại checkpoint an toàn.

## Trình tự kiểm tra

1. Worker báo `READY_FOR_VERIFICATION`, file thực tế, evidence và phần chưa kiểm tra.
2. Lead chuyển task sang `VERIFYING`, so với preview, research brief, acceptance và checklist đã chọn.
3. Lead xem evidence hoặc giao QA/smoke tách riêng đúng route kiểm tra.
4. Chỉ sau đó Big Lead mới đánh dấu `DONE` và báo người dùng.

Check không chạy được thì không che giấu: nói rõ phần nào chưa kiểm tra, vì sao, evidence rủi ro thấp hơn là gì, và task cần `BLOCKED`, `WAITING_USER` hay follow-up rõ ràng.
