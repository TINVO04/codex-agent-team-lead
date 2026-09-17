# Cổng tìm năng lực và skill

Dùng tài liệu này khi task cần kiến thức hoặc quy trình mà team chưa có: framework mới, review bảo mật, định dạng file, accessibility, cloud service hoặc công cụ test chuyên biệt.

Mục tiêu là để team học thứ cần thiết nhưng không để worker tải nội dung lạ, chạy script không rõ, hoặc làm lộ dữ liệu dự án.

## Quy tắc ngắn

Worker yêu cầu capability. Lead giao một worker `SKILL-SCOUT` có phạm vi rõ để tìm và kiểm tra. Lead quyết định dựa trên bằng chứng. Người dùng duyệt mọi skill mới/rủi ro hoặc có quyền ngoài phạm vi.

Code thông thường, đọc source local, test cơ bản và tài liệu vendor đã ghi rõ trong task không cần tìm skill. Không biến mọi task nhỏ thành việc tìm skill.

## Quyết định lúc nhận task

Ghi một trong các kết quả sau vào Task Contract:

1. `not needed`: làm được an toàn từ context dự án và kỹ năng kỹ thuật thông thường.
2. `existing skill`: skill Codex đã có hoặc mục trong registry phù hợp; đọc toàn bộ `SKILL.md` và tài nguyên mà nó trỏ tới.
3. `approved project reference`: dự án đã có guide/reference nội bộ được kiểm tra.
4. `candidate under review`: có ứng viên mới nhưng chưa được worker dùng.
5. `user approval needed`: cần tải/cài/bật/chạy skill hoặc cần quyền người dùng chưa cấp.

Lead chỉ xem registry/context rồi giao skill-scout worker nếu cần khám phá. Skill-scout tìm từ nguồn đáng tin bằng `find-skills`, `npx skills find <truy-vấn-cụ-thể>`, tài liệu chính thức và nguồn gốc. Lead không tự tìm trên web trong terminal của mình.

## Tin nhắn yêu cầu năng lực của worker

Worker gửi đúng dạng ngắn sau cho Lead:

```text
CAPABILITY_REQUEST
Task: <ID>
Need: <capability cụ thể>
Why: <vì sao context hiện có chưa đủ>
Use: <một task | có thể dùng lại>
Data boundary: <không có dữ liệu rời máy | nêu dữ liệu và nơi đến>
```

Worker tiếp tục phần việc độc lập, an toàn nếu có; chỉ dừng phần phụ thuộc quyết định. Worker không tự tìm web, tải/cài/cập nhật/chạy skill hoặc script lạ.

## Skill-scout phải kiểm tra gì

Trước khi đề xuất, skill-scout ghi bằng chứng cho một `SK-###` trong `SKILL_REGISTRY.md`. Lead đọc và quyết định dựa trên các điểm sau:

| Điểm kiểm tra | Yêu cầu |
|---|---|
| Phù hợp | Giải quyết đúng capability/task, không chỉ giống từ khóa. |
| Nguồn | Ưu tiên vendor chính thức hoặc tổ chức uy tín; cẩn thận với nguồn cá nhân không rõ. |
| Mức dùng | Xem lượt cài/hoạt động repo; phổ biến không tự chứng minh an toàn. |
| Nội dung | Đọc toàn bộ `SKILL.md` và mọi script, hook, reference mà task sẽ dùng. |
| Dữ liệu | Không gửi source, log, token, dữ liệu khách hàng hay credential ra ngoài. |
| Quyền | Nêu rõ hành động filesystem, Git, DB, cloud, deploy, login hay service mà skill có thể làm. |
| Phạm vi | Ưu tiên reference theo task/dự án, tránh cài global toàn máy. |

Loại ứng viên nếu không xác định được nguồn, không kiểm tra trọn nội dung, đòi secret, làm việc ngoài task, hoặc cần quyền chưa được cấp.

## Chế độ quyền

### `suggest-only` — mặc định

Lead/skill-scout có thể tìm công khai, kiểm tra và ghi đề xuất. Phải hỏi người dùng trước khi tải, cài, bật hoặc chạy bất kỳ skill mới nào.

### `trusted-instruction-only` — chỉ khi người dùng bật riêng cho dự án

Có thể chuẩn bị/dùng skill mới nếu đồng thời thỏa tất cả:

- nguồn uy tín, nội dung đọc/kiểm tra được toàn bộ;
- chỉ có hướng dẫn/reference, không script, hook, binary, package install hay chạy tool bên ngoài;
- không cần credential, login, upload, Git, DB, deploy hay đổi service;
- nằm trong phạm vi dự án và được ghi registry.

Chế độ này không cho phép cài skill global và không thay thế rule Git/DB/deploy. Chạm một ranh giới là quay về `user approval needed`.

## Dùng skill an toàn

1. Skill đã cài: đọc và dùng theo hướng dẫn.
2. Candidate instruction-only đã được duyệt: Lead ghi lý do duyệt, giao worker path và mục đích hẹp.
3. Có script/hook/quyền ngoài: giải thích rủi ro ngắn gọn và hỏi người dùng một lần trước khi lấy/dùng.
4. Không có candidate tốt: dùng tài liệu gốc và năng lực thông thường. Nếu lặp lại, tạo guide/skill nội bộ theo rule thay đổi file của dự án.

Không đưa secret, source riêng đầy đủ, token, dữ liệu khách hàng hay log chưa lọc vào truy vấn web, issue công khai hoặc dịch vụ bên thứ ba.

## Vòng đời registry

- `candidate`: đã tìm, chưa chấp nhận.
- `approved`: đã kiểm tra, được dùng trong phạm vi nêu rõ.
- `active`: đang được task sử dụng.
- `rejected`: không an toàn, không phù hợp, không có hoặc chưa được duyệt.
- `retired`: từng hữu ích nhưng không còn phù hợp.

Khi task xong, Lead đổi `active` thành `approved` nếu dùng lại được, hoặc `retired` nếu chỉ tạm thời. Skill không hiệu quả cũng phải ghi lý do để Lead sau không lặp lại việc tìm đó.

## Cách nói với người dùng

Nói ngắn, dễ hiểu. Ví dụ:

> Đang làm: phần này cần cách kiểm tra bảo mật chuyên biệt. Team đã tìm được lựa chọn từ nguồn chính thức, nhưng nó cần cài thêm công cụ. Bạn có đồng ý cho dùng không?

Skill đã cài và an toàn không cần hỏi lại; ghi việc dùng vào registry rồi tiếp tục.
