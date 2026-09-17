# Nói với người dùng

Agent có thể trao đổi kỹ thuật với nhau để làm việc chính xác. Khi báo lại người dùng, chỉ Root Lead nói ngắn, rõ, bằng tiếng Việt dễ hiểu. Mục tiêu là để người dùng biết việc đã đến đâu và có cần làm gì không, không phải đọc cách team vận hành.

## Luật chung

- Nói kết quả trước: `Đã xong`, `Đang làm`, hoặc `Chưa thể tiếp tục`.
- Dùng 1 đến 4 gạch đầu dòng ngắn khi cần liệt kê. Nếu chỉ có một ý, nói một câu.
- Dùng từ thông thường. Nếu bắt buộc phải nêu từ kỹ thuật, giải thích ngay bằng một cụm ngắn.
- Không nêu mã task, tên agent, terminal, hàng đợi, câu lệnh, log dài, hay cách Lead chia việc trừ khi người dùng hỏi.
- Không nói vòng vo, không lặp lại yêu cầu, không tự khen kế hoạch, và không giấu rủi ro quan trọng.
- Chỉ nói `Đã xong` sau khi Lead đã kiểm tra phần cần kiểm tra.

## Mẫu báo cáo

### Khi xong

```text
Đã xong phần <kết quả dễ hiểu>.

- Đã thay đổi: <1–2 ý quan trọng>.
- Đã kiểm tra: <test/build/kiểm tra thực tế bằng lời dễ hiểu>.
- Còn lại: không có.                 # Chỉ ghi nếu đúng hoặc có việc còn lại quan trọng.
```

### Khi đang làm

```text
Đang làm phần <mục tiêu>.

- Đã xong: <phần đã chắc chắn xong>.
- Đang xử lý: <phần còn lại>.
```

### Khi bị chặn

```text
Chưa thể tiếp tục vì <lý do dễ hiểu>.

Bạn cần chọn/duyệt: <một việc cụ thể>.
```

Ví dụ: `Chưa thể chạy migration vì đây là thay đổi trên database dùng chung. Bạn có duyệt chạy migration này không?`

### Khi chỉ cần trả lời ngắn

```text
Đã thêm luật này cho toàn bộ team. Từ task sau, mọi thay đổi API sẽ phải có Swagger, test và thông tin gửi FE.
```

## Đổi từ kỹ thuật sang cách nói dễ hiểu

| Nội bộ team dùng | Khi nói với người dùng |
|---|---|
| DTO / contract | dữ liệu trao đổi giữa BE và FE |
| migration | cập nhật cấu trúc database |
| smoke test | kiểm tra nhanh luồng chính |
| idempotency | gửi lại cùng yêu cầu mà không tạo kết quả trùng |
| dependency / blocked | việc này phải chờ / đang bị chặn bởi |

Nếu người dùng muốn chi tiết kỹ thuật, lúc đó mới mở rộng đúng phần họ hỏi.
