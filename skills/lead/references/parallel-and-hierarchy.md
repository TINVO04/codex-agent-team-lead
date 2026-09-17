# Làm song song và phân cấp có giới hạn

Mục tiêu là song song có ích, không phải tạo cây agent lớn nhất.

## Điều phối liên tục

Ở mỗi checkpoint Lead:

1. Thêm mọi yêu cầu vào board và phân loại implementation, research, contract, test, review hoặc integration.
2. Xếp theo ưu tiên người dùng, dependency thật, rủi ro và thời điểm đến; gom việc nhỏ cùng context.
3. Chạy Parallel Gate và reserve ownership zone trước khi mở writer.
4. Giao task `READY` không conflict có ưu tiên cao nhất, trong capacity toàn cục.
5. Khi worker có event, kiểm tra evidence, cập nhật board, release/retain terminal và xếp task vừa được mở khóa. Không chờ “wave” giả tạo.

State board chỉ giữ quyết định làm thay đổi công việc: API/schema contract, ownership reservation, blocker, test evidence và escalation.

## Quy tắc phụ thuộc

| Tình huống | Quyết định Lead |
|---|---|
| Task cần behavior/state đã kiểm tra của task khác | Ghi dependency cứng và tuần tự. |
| Hai writer chạm cùng file/module, migration, DTO, public contract, config hoặc fixture | Reserve một ownership zone; tuần tự hoặc contract-first. |
| FE chờ interface BE ổn định, component chờ schema | Công bố contract có ví dụ; hai bên dùng mock/stub/fixture. |
| Chưa biết nguyên nhân lỗi | Giao worker điều tra chỉ-đọc trước, rồi tạo implementation task hẹp. |
| Nhiều lỗi nhỏ cùng surface | Gom theo context cho một worker. |

Contract API/schema/event/fixture phải nêu owner, version/tương thích, error/state mapping và acceptance test. Contract chỉ gỡ dependency giả, không cấp quyền thay đổi không tương thích.

## Phân cấp có giới hạn

Mặc định phẳng:

```text
Root Lead → worker
```

Chỉ dùng Domain Lead cho nhánh thật sự lớn:

```text
Root Lead
├─ Domain Lead Auth → worker Auth
└─ Domain Lead Billing → worker Billing
```

Tạo Domain Lead khi đồng thời có:

- ít nhất hai task độc lập hoặc sắp sẵn sàng trong nhánh;
- file/contract tách được khỏi nhánh khác;
- cần local decision owner rõ;
- capacity toàn cục còn hữu ích sau khi dành slot điều phối;
- không còn user approval, migration chung, Git hay thay đổi ngoài chưa giải quyết.

`max_hierarchy_depth` là giới hạn cứng. Root ở depth 0; mặc định 2 chỉ cho `Root Lead → Domain Lead → worker`. Không tạo cây chỉ vì yêu cầu có nhiều danh từ.

## Mở rộng, giữ và thu gọn

Chỉ scale khi số task `READY` không conflict nhiều hơn idle capacity phù hợp. Worker bận không tự là lý do mở thêm worker; dependency cứng/ownership overlap không thành song song chỉ vì mở thêm terminal.

Task hoàn tất đã verify có thể dùng lại terminal phù hợp nếu task liên quan sẵn sàng. Giải phóng terminal khi domain không có việc gần hoặc capacity cần cho nơi khác. Domain Lead không còn `READY`/`ACTIVE` thì thu gọn sau event cuối và trả queue về Root. Không xóa lịch sử task chỉ vì terminal được giải phóng.

## Event bắt buộc

| Event | Nội dung tối thiểu |
|---|---|
| `DONE` | task ID, kết quả, evidence, file/contract ảnh hưởng |
| `BLOCKED` | task ID, blocker rõ, dependency/quyền cần |
| `NEED_DECISION` | lựa chọn, owner, deadline/ảnh hưởng nếu biết |
| `CONTRACT_CHANGED` | contract ID, behavior cũ/mới, tương thích, task ảnh hưởng |
| `FAILED` | task ID, evidence lỗi, state còn lại, recovery đề xuất |

Root Lead xử lý event trước khi xác nhận delivery Orca hoặc xếp thêm work.
