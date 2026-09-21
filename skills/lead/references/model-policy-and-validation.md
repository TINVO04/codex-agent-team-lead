# Cấu hình Model linh hoạt và Khởi chạy lạc quan (3 Tiers & Optimistic Launch)

`MODEL_POLICY.md` là nơi cấu hình model cho dự án. `MODEL_STATUS.md` là nơi Big Lead ghi nhận kết quả hoạt động thực tế. Hệ thống được thiết kế theo chuẩn 2026: **tối đa độ linh hoạt, khởi chạy tức thì và tự động xác thực**.

---

## 1. Nguyên tắc cốt lõi

1. **Inline Override có quyền ưu tiên cao nhất:** Khi người dùng chỉ định model trực tiếp cho một task (ví dụ: `$lead [model: claude-3.7-sonnet] ...` hoặc bằng câu lệnh rõ ràng), Big Lead áp dụng thẳng model đó cho Task Contract của task mà không cần sửa `MODEL_POLICY.md` toàn cục.
2. **Optimistic Launch (Khởi chạy lạc quan):** Không bắt buộc phải mở worker riêng để kiểm tra trước (probe validation). Khi có model mới hoặc thay đổi cấu hình, Lead cấp thẳng model đó cho Task Worker chạy ngay.
3. **Auto-Verification (Tự động xác thực):** Nếu worker khởi chạy và làm việc thành công, model được tự động ghi nhận là `verified` trong `MODEL_STATUS.md`.
4. **Graceful Fallback:** Nếu worker không thể khởi chạy (lỗi runtime, model not found, hết quota): Lead giữ checkpoint, retry tối đa 3 lần với cùng model; nếu sau 3 lần vẫn lỗi thì tự động chuyển sang model dự phòng tiếp theo trong pool và ghi nhận trạng thái lỗi tạm thời.
5. **Cấu hình 3 Tầng năng lực (3 Tiers):** Thay vì chia nhỏ quá nhiều route, hệ thống quy về 3 tầng trực quan.

---

## 2. Hệ thống 3 Tầng năng lực (3 Tiers)

```markdown
# Cấu hình model dự án

Revision: MP-002
Tự đổi sang dự phòng: có
Same-model max attempts: 3

| Tầng năng lực (Tier) | Phạm vi sử dụng | Model chính | Effort | Pool xoay vòng khi lỗi |
|---|---|---|---|---|
| **Tier 1: Heavy / Frontier** | Big Lead, Domain Lead, Kiến trúc, Code khó, Bug sâu, Integration | `gpt-5.6-terra` | `xhigh` | `gpt-5.6-terra` → `qwen3.8-max-0902` → `deepseek-v4.1-flash` |
| **Tier 2: Standard** | Code tính năng thông thường, viết unit test, research vừa | `deepseek-v4.1-flash` | `medium` | `deepseek-v4.1-flash` → `qwen3.8-max-0902` → `glm-5.3-flash` |
| **Tier 3: Eco / Fast** | Đọc file, format code, sửa tài liệu, tra cứu nhanh | `glm-5.3-flash` | `low` | `glm-5.3-flash` → `deepseek-v4.1-flash` |
```

*(Lưu ý: Hệ thống vẫn hoàn toàn tương thích ngược với các file `MODEL_POLICY.md` 6-route kiểu cũ nếu dự án chưa cập nhật).*

---

## 3. Cách đổi Model khi người dùng yêu cầu

### A. Đổi tạm thời cho một task cụ thể (Inline Override)
Không cần chỉnh file, không ảnh hưởng các task khác:
```text
$lead [model: claude-3.7-sonnet] Viết module phân tích log này
```
hoặc:
```text
$lead Dùng model o3-mini cho việc sửa test này: ...
```

### B. Đổi nhanh model chính cho toàn team (Quick Switch)
```text
$lead models use claude-3.7-sonnet
```
Lead sẽ cập nhật `MODEL_POLICY.md` (đặt model chính của Tier 1 thành `claude-3.7-sonnet`) và thông báo hoàn tất ngay lập tức.

### C. Đặt lại danh sách dự phòng (Fallback Chain)
```text
$lead models fallback claude-3.7-sonnet, deepseek-v4.1-flash, qwen3.8-max-0902
```

### D. Chuyển toàn bộ sang Local / Offline Profile
```text
$lead models use local
```
Tự động chuyển các Tier sang profile local đã cấu hình trong `~/.codex/config.toml` (như Ollama, vLLM, LMStudio).

---

## 4. Xử lý lỗi trong khi chạy (3-Strike Rule & Rotation)

1. Lần 1 và Lần 2 gặp lỗi provider: Giữ nguyên checkpoint, retry lại chính model đó với cùng effort.
2. Lần 3 gặp lỗi: Đánh dấu model đó là `temporary_error` trong `MODEL_STATUS.md`.
3. Tự động xoay: Mở worker mới kế thừa checkpoint bằng model tiếp theo trong danh sách pool của Tier tương ứng.
4. Toàn bộ pool cạn kiệt: Chuyển task sang `WAITING_USER` và thông báo cho người dùng một câu hỏi lựa chọn rõ ràng (chờ hồi phục quota, đổi model mới hoặc chuyển sang provider khác).

---

## 5. Bảng trạng thái `MODEL_STATUS.md`

`MODEL_STATUS.md` được Lead tự động cập nhật trong quá trình vận hành:

```markdown
# Trạng thái model quan sát được

Kiểm tra gần nhất: <ISO 8601 giờ địa phương>

| Model | Effort | Trạng thái | Ghi chú / Lần cuối thấy hoạt động |
|---|---|---|---|
| gpt-5.6-terra | xhigh | verified | Hoạt động bình thường qua worker dispatch |
| qwen3.8-max-0902 | high | verified | Dự phòng sẵn sàng |
| deepseek-v4.1-flash | medium | verified | Hoạt động bình thường |
| glm-5.3-flash | low | verified | Hoạt động bình thường |
```

Trạng thái:
* `verified`: Model đang hoạt động tốt.
* `temporary_error`: Lỗi tạm thời (rate-limit/timeout), tự động thử lại sau.
* `unavailable`: Runtime từ chối hoặc không tìm thấy model.
* `disabled`: Người dùng chủ động tắt.
