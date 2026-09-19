# Cổng chất lượng và xem trước

Dùng tài liệu này khi Lead định nghĩa “xong”, kiểm tra kết quả worker, hoặc quyết định thay đổi UI/UX/luồng có cần người dùng xem trước không. Đọc [First-Pass Gate](first-pass-verification.md) trước khi chuyển một task sang `DONE`.

## Cổng chất lượng: “xong” phải thấy được

Mỗi Task Contract chọn checklist đúng trong `.orca-team/QUALITY_GATES.md` và ghi evidence cụ thể. Chỉ chọn phần liên quan; task tài liệu hẹp không cần checklist migration.

Lần làm đầu không tự là `DONE`: worker báo `READY_FOR_VERIFICATION`, Task chuyển `VERIFYING`, sau đó Lead mới có thể đóng task. Lead tối thiểu phải kiểm tra:

1. Kết quả mục tiêu đã xảy ra, không chỉ là file đã đổi.
2. Test hoặc manual check phù hợp đã chạy/ghi rõ.
3. Public contract và dependency bên ngoài đã được xử lý nếu có thay đổi.
4. Không phá rule, approval boundary hoặc ownership của worker khác.
5. Claim `DONE` có evidence Lead xem được.

Lời worker nói, build pass một mình hoặc một screenshot một mình không đủ cho mọi task. Kết hợp evidence phù hợp với thay đổi. Với auth/permission, payment, database/migration/state, API public/contract hoặc dependency giữa nhiều nhóm/hệ thống, Task Contract phải chọn QA độc lập hoặc smoke evidence tách riêng.

Nếu có từ hai worker triển khai, Task Contract phải chỉ định integration owner. Owner này kiểm tra kết quả sau fan-out bằng build/test hoặc smoke check toàn cục phù hợp; không kết luận từ Git diff hay merge không conflict. Check hỏng được giao cho một resolver worker duy nhất với log/checkpoint đầy đủ, không mở nhiều writer sửa cùng lỗi.

## Test vừa đủ, không test cho đủ số

Task Contract phải ghi risk tier, test route, phần bị ảnh hưởng và test budget. Dùng ladder sau:

| Tầng | Khi dùng | Ví dụ |
|---|---|---|
| `fast` | sau mỗi thay đổi hoặc task rủi ro thấp | format, lint, typecheck, unit deterministic liên quan |
| `boundary` | đổi API, schema, migration, state, permission hoặc tích hợp | contract/integration/smoke tập trung |
| `release` | thay đổi rộng, module dùng chung hoặc trước release | suite rộng, E2E/production-like có chọn lọc |

Không chạy release suite sau mọi sửa nhỏ. Test mới phải bao phủ rủi ro chưa có bằng chứng; không thêm test trùng assertion. Tách test `required` khỏi `informational`, cache artifact khi an toàn và chỉ song song hóa test độc lập.

Test flaky chỉ được retry một lần để phân loại. Ghi riêng `product-failure`, `environment-failure` và `flaky`; không âm thầm coi retry pass là xanh. Nếu quarantine, phải có owner, ticket và ngày hết hạn. Khi hết test budget hoặc lặp cùng lỗi, dừng và chuyển resolver/`BLOCKED`/`WAITING_USER`.

Lead nên ghi thời gian chờ, thời gian test, số retry/handoff, rework và first-pass acceptance vào state. Đây là bằng chứng để quyết định fan-out có cải thiện thời gian và chất lượng hay không.

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
