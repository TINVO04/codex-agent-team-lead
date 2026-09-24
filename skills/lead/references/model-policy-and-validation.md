# Cấu hình model (Chuẩn cộng đồng & Nhà phát hành 2026)

Cập nhật gần nhất: 2026-09-24
Revision: MP-005
Tự đổi sang dự phòng: có
Same-model max attempts: 3

Hệ thống quản lý model theo 3 tầng năng lực (3 Tiers). Người dùng có thể chỉ định model cho từng task bằng tag [model: ...] hoặc lệnh '$lead models use <model>'. Áp dụng Optimistic Launch: worker khởi chạy trực tiếp với model được yêu cầu và tự động xác thực vào MODEL_STATUS.md khi thành công.

| Tầng năng lực (Tier) | Phạm vi sử dụng | Model chính | Effort | Context Chuẩn | Max Output | Pool xoay vòng khi lỗi |
|---|---|---|---|---|---|---|
| Tier 1: Heavy / Frontier | Big Lead, Domain Lead, Kiến trúc, Code khó, Bug sâu, Integration | claude-opus-5-5 / gpt-6-sol | max / xhigh | 1,000,000 (1M) / 1,050,000 | 128,000 | claude-opus-5-5 → gpt-6-sol → claude-fable-5-1 → gpt-6-astra |
| Tier 2: Standard | Code tính năng thường, viết unit test, research vừa | claude-fable-5-1 / gpt-6-sol | max / medium | 1,000,000 (1M) / 1,050,000 | 128,000 | claude-fable-5-1 → gpt-6-sol → deepseek-v4.1-flash → gpt-6-luna |
| Tier 3: Eco / Fast | Đọc file, format code, sửa tài liệu, tra cứu nhanh, Level 0/1 | gpt-6-luna | low | 1,050,000 (1.05M) | 64,000 | gpt-6-luna → glm-5.3-flash → deepseek-v4.1-flash |

### Thông số Context Chuẩn theo chuẩn Anthropic & Cộng đồng:
- **`claude-opus-5-5`**: 1,000,000 tokens (1M). Max output: 128,000 tokens. Reasoning Effort: `low`, `medium`, `high`, `xhigh`, `max` (mặc định: `max`).
- **`claude-fable-5-1`**: 1,000,000 tokens (1M). Max output: 128,000 tokens. Reasoning Effort: `low`, `medium`, `high`, `xhigh`, `max` (mặc định: `max`).
- **Tỷ lệ Effective Context trong Codex**: 95% (950,000 tokens), tự động kích hoạt auto-compaction khi chạm ngưỡng để bảo lưu buffer output 50,000 tokens.
- **Prompt Caching**: Chuẩn Ephemeral Caching (5 phút), tự động tái sử dụng cache giúp giảm 80-90% token input lặp lại.
