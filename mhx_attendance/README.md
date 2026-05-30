# 🌿 MHX-Attendance — Ứng dụng Điểm danh Mùa Hè Xanh
Được phát triển bởi Nguyễn Hoàng Long

> Hệ thống quản lý và điểm danh thiếu nhi & đoàn viên cho các Chiến dịch Mùa Hè Xanh.
> Hỗ trợ đa chiến dịch, đa năm — vận hành trên mô hình Serverless, đồng bộ thời gian thực, đa nền tảng.

---

## 📋 Mục lục

- [Tổng quan công nghệ](#-tổng-quan-công-nghệ)
- [Mô hình Chiến dịch](#-mô-hình-chiến-dịch)
- [Phân quyền người dùng](#-phân-quyền-người-dùng)
- [Cấu trúc mã định danh & QR](#-cấu-trúc-mã-định-danh--luồng-qr)
- [Công thức tính điểm](#-công-thức-tính-điểm-tự-động)
- [Database schema](#-thiết-kế-cơ-sở-dữ-liệu-cloud-firestore)
- [Danh sách task phát triển](#-danh-sách-task-phát-triển)

---

## 🏗️ Tổng quan công nghệ

| Thành phần | Công nghệ | Ghi chú |
|---|---|---|
| Frontend đa nền tảng | Flutter 3.x (Dart) | Android · iOS · Windows · Web (tuỳ chọn) |
| Xác thực | Firebase Auth + Google Sign-In | Custom Claims cho role |
| Cơ sở dữ liệu | Cloud Firestore | NoSQL Realtime · Offline-first |
| Logic nghiệp vụ | Cloud Functions (Node.js) | Tính điểm · tạo member_id · chống gian lận |
| Thông báo đẩy | Firebase Cloud Messaging | Nhắc sự kiện cho đoàn viên |
| Quét QR | `mobile_scanner` | Camera tốc độ cao |
| Xuất PDF | `pdf` + `printing` | Thẻ QR · báo cáo A4 |
| Xuất Excel | `syncfusion_flutter_xlsio` | Báo cáo dữ liệu điểm danh |
| State management | Riverpod | Flutter state management |
| Routing | go_router | Navigation đa nền tảng |
| CI/CD | GitHub Actions | Build · test · deploy tự động |
| Phân phối nội bộ | Firebase App Distribution | Test trước khi lên store |

**Thiết kế UI:** Material Design 3 · Màu chủ đạo `#1565C0` (Blue 800)

---

## 🗓️ Mô hình Chiến dịch

Ứng dụng hỗ trợ nhiều chiến dịch qua các năm (ví dụ: *Mùa Hè Xanh 2025*, *Mùa Hè Xanh 2026*). Mỗi chiến dịch là một ngữ cảnh độc lập — toàn bộ hoạt động, điểm danh và thành viên đều thuộc về một chiến dịch cụ thể.

### Luồng tạo chiến dịch (Super Admin)

```
Super Admin tạo chiến dịch mới
        ↓
Nhập tên chiến dịch (VD: "Mùa Hè Xanh 2026")
        ↓
Nhập năm + thời gian bắt đầu & kết thúc
        ↓
Thêm Bí Thư phụ trách (Local Admin) cho từng khu phố
        ↓
Hoàn tất → Chiến dịch được kích hoạt
        ↓
Local Admin được thêm vào sẽ tự động tham gia chiến dịch
```

> Mọi tính năng cốt lõi — hoạt động, điểm danh, thành viên, báo cáo — đều nằm trong phạm vi một chiến dịch đang chọn.

---

## 👥 Phân quyền người dùng

Hệ thống quản lý chặt chẽ theo 3 cấp độ tài khoản, phân quyền qua **Firebase Custom Claims** + **Firestore Security Rules**.

### 🔴 Super Admin — Ban chỉ huy cấp Phường / Thành phố

**Quản lý chiến dịch:**
- Tạo và quản lý các chiến dịch theo từng năm
- Thêm Bí Thư (Local Admin) phụ trách từng khu phố vào chiến dịch
- Khoá / mở khoá tài khoản Local Admin

**Quản lý thành viên:**
- Xem, lọc, và tìm kiếm danh sách thiếu nhi & đoàn viên toàn địa bàn
- **Chỉ xem** — không chỉnh sửa thông tin thành viên
- Chỉnh sửa thông tin cá nhân của bản thân

**Hoạt động & Điểm danh:**
- Tạo hoạt động cấp cao (tự động hiển thị ở **tất cả** các khu phố)
- Xem thống kê tổng toàn địa bàn, lọc Top N thiếu nhi nhiều điểm nhất
- Xuất báo cáo PDF / Excel theo khu phố, thời gian, loại thành viên
- In thẻ QR cho bất kỳ khu phố nào

---

### 🟢 Local Admin — Bí Thư / Phụ trách từng Khu phố

**Quản lý thành viên:**
- Thêm / sửa thành viên (thiếu nhi & đoàn viên) thuộc khu phố mình
- **Không được xoá cứng** — chỉ ẩn thành viên (`is_active = false`)
- Liên kết đoàn viên với tài khoản Google
- Chỉnh sửa thông tin cá nhân của bản thân

**Hoạt động & Điểm danh:**
- Tạo hoạt động cấp khu phố trong phạm vi chiến dịch đang hoạt động
- Điểm danh tại hiện trường bằng **quét QR** hoặc **tick tay thủ công**
- Xuất PDF & in thẻ QR cho thành viên khu phố của mình
- Cấp **quyền điểm danh tạm thời** cho 1 đoàn viên khi bản thân vắng mặt

---

### 🔵 User — Đoàn viên thanh niên

- Đăng nhập app bằng Google, nhận Push Notification khi có hoạt động mới
- Xem chi tiết hoạt động và bấm **"Tham gia"** để đăng ký trước
- Hiển thị **mã QR cá nhân** ngay trên app để phụ trách quét điểm danh
- Xem điểm tích luỹ, lịch sử điểm danh và xếp hạng trong khu phố
- Chỉnh sửa thông tin cá nhân của bản thân

> **Thiếu nhi** không có tài khoản app — được cấp **thẻ cứng in QR** do Local Admin phát.
> Trường hợp không có QR (quên thẻ / chưa in): tick tay thủ công.

---

## 🪪 Cấu trúc mã định danh & Luồng QR

Mã số được hệ thống **tự động tạo một lần duy nhất** khi Local Admin thêm thành viên mới trong một chiến dịch:

```
[Loại]-[Năm]-[Mã Khu Phố]-[Số Thứ Tự]

TN-2026-KP03-0042   →  Thiếu Nhi · Năm 2026 · Khu phố 3 · STT 42
DV-2026-KP03-0005   →  Đoàn Viên · Năm 2026 · Khu phố 3 · STT 05
```

| Thành phần | Mô tả |
|---|---|
| `TN` / `DV` | Thiếu Nhi / Đoàn Viên |
| `2026` | Năm chiến dịch |
| `KP03` | Mã khu phố (KP01 → KP99) |
| `0042` | Số thứ tự tự tăng trong khu phố |

**QR code = encode của `member_id`** — không thay đổi suốt vòng đời thành viên trong chiến dịch đó.

### Luồng thẻ QR

```
Local Admin thêm TN/ĐV trong chiến dịch
        ↓
Cloud Function tạo member_id cố định
        ↓
QR = encode(member_id) → lưu Firestore
        ↓
Local Admin xuất PDF → in thẻ 9×5.5cm (8–10 thẻ/A4)
        ↓
Phát thẻ cho thiếu nhi  |  ĐV hiện QR trên app
        ↓
Điểm danh: Quét QR  ─── hoặc ───  Tick tay (quên thẻ)
        ↓
Cloud Function tính điểm → cập nhật Firestore realtime
```

---

## 📊 Công thức tính điểm tự động

Điểm được tính tự động qua **Firebase Cloud Function** mỗi khi có bản ghi điểm danh hợp lệ:

```
Điểm tích luỹ = Hệ số cấp độ × Số ngày diễn ra
```

| Cấp độ hoạt động | Hệ số | Ví dụ (3 ngày) |
|---|---|---|
| Cấp Khu phố | 10 điểm / ngày | 30 điểm |
| Cấp Phường | 20 điểm / ngày | 60 điểm |
| Cấp Thành phố | 30 điểm / ngày | 90 điểm |

> `totalPoints` trong collection `members` được Cloud Function cập nhật ngay sau mỗi lần điểm danh, tránh sum lại từ đầu mỗi lần query.

---

## 🗄️ Thiết kế cơ sở dữ liệu Cloud Firestore

### 1. Collection: `campaigns`
> Các chiến dịch theo năm, do Super Admin tạo và quản lý.

```jsonc
{
  "campaign_id": "MHX-2026",              // PK — VD: MHX-2025, MHX-2026
  "name": "Mùa Hè Xanh 2026",
  "year": 2026,
  "start_date": "Timestamp",
  "end_date": "Timestamp",
  "is_active": true,                       // Chiến dịch đang diễn ra
  "created_by": "USER_SUPER_001",          // uid Super Admin tạo
  "created_at": "Timestamp"
}
```

---

### 2. Collection: `users`
> Tài khoản Admin và Đoàn viên đăng nhập Google.

```jsonc
{
  "uid": "USER_ABC123XYZ",              // Firebase Auth UID — PK
  "email": "hoanglong@gmail.com",
  "full_name": "Nguyễn Hoàng Long",
  "photo_url": "https://...",           // Avatar Google
  "role": "LOCAL_ADMIN",               // "SUPER_ADMIN" | "LOCAL_ADMIN" | "USER"
  "neighborhood_id": "KP03",           // FK → neighborhoods; null nếu SUPER_ADMIN
  "neighborhood_name": "Khu phố 3",   // Denorm để hiển thị nhanh
  "device_token": "fcm_token_xyz",     // FCM push notification token
  "is_active": true,                   // Super Admin khoá/mở
  "temp_attendance_permission": false, // Quyền điểm danh tạm thời (Local Admin cấp)
  "temp_permission_expires_at": null,  // Timestamp hết hạn quyền tạm thời
  "created_at": "Timestamp",
  "created_by": "USER_SUPER_001"       // uid của Super Admin tạo
}
```

---

### 3. Collection: `neighborhoods`
> Thông tin các khu phố trên địa bàn.

```jsonc
{
  "neighborhood_id": "KP03",           // PK — VD: KP01, KP02...
  "name": "Khu phố 3",
  "ward_name": "Phường Bình Quới",    // Denorm
  "city_name": "TP. Hồ Chí Minh",     // Denorm
  "admin_uid": "USER_ABC123XYZ",       // FK → users (Local Admin phụ trách)
  "admin_name": "Nguyễn Hoàng Long",  // Denorm
  "member_count": 42,                  // Đếm realtime
  "created_at": "Timestamp"
}
```

---

### 4. Collection: `campaign_neighborhoods`
> Liên kết giữa chiến dịch và khu phố — xác định Local Admin tham gia chiến dịch nào.

```jsonc
{
  "id": "MHX-2026_KP03",              // PK — {campaign_id}_{neighborhood_id}
  "campaign_id": "MHX-2026",          // FK → campaigns
  "neighborhood_id": "KP03",          // FK → neighborhoods
  "admin_uid": "USER_ABC123XYZ",       // FK → users (Bí Thư khu phố trong chiến dịch này)
  "admin_name": "Nguyễn Hoàng Long",  // Denorm
  "joined_at": "Timestamp"
}
```

---

### 5. Collection: `members`
> Hồ sơ thiếu nhi và đoàn viên trong từng chiến dịch.

```jsonc
{
  "member_id": "TN-2026-KP03-0042",   // PK — cố định, không đổi
  "campaign_id": "MHX-2026",          // FK → campaigns
  "full_name": "Nguyễn Văn An",
  "type": "THIEU_NHI",                // "THIEU_NHI" | "DOAN_VIEN"
  "birth_date": "Timestamp",
  "neighborhood_id": "KP03",          // FK → neighborhoods
  "neighborhood_name": "Khu phố 3",  // Denorm
  "total_points": 150,                // Cập nhật bởi Cloud Function
  "account_uid": null,                // FK → users.uid; null nếu là thiếu nhi
  "is_active": true,
  "created_at": "Timestamp",
  "created_by": "USER_ABC123XYZ"      // uid Local Admin tạo
}
```

> **Lưu ý:** `account_uid` dùng để liên kết đoàn viên có tài khoản app với hồ sơ thành viên. Thiếu nhi không có tài khoản nên `account_uid = null`.

---

### 6. Collection: `activities`
> Danh sách hoạt động trong từng chiến dịch.

```jsonc
{
  "activity_id": "ACT-2026-001",      // PK — Auto-gen Firestore
  "campaign_id": "MHX-2026",          // FK → campaigns
  "title": "Ra quân dọn dẹp vệ sinh kênh rạch",
  "description": "Chiến dịch làm sạch môi trường tuyến kênh nội bộ Phường Bình Quới...",
  "level": "PHUONG",                  // "KHU_PHO" | "PHUONG" | "THANH_PHO"
  "start_date": "Timestamp",
  "end_date": "Timestamp",
  "duration_days": 1,                 // end_date − start_date + 1 (tính bởi Cloud Function)
  "point_per_day": 20,                // Tự động theo level
  "total_points": 20,                 // = point_per_day × duration_days
  "scope": "GLOBAL",                  // "GLOBAL" (toàn địa bàn) | "LOCAL" (riêng khu phố)
  "neighborhood_id": "KP03",          // FK → neighborhoods; null nếu scope = GLOBAL
  "attendee_count": 28,               // Đếm realtime
  "is_open": true,                    // Đang mở điểm danh
  "created_by": "USER_ABC123XYZ",
  "created_at": "Timestamp"
}
```

---

### 7. Collection: `activity_registrations`
> Đoàn viên đăng ký tham gia trước hoạt động (tính năng "Tham gia").

```jsonc
{
  "registration_id": "REG-2026-00123", // PK — Auto-gen
  "campaign_id": "MHX-2026",           // FK → campaigns
  "activity_id": "ACT-2026-001",       // FK → activities
  "activity_title": "Ra quân dọn dẹp vệ sinh kênh rạch", // Denorm
  "member_id": "DV-2026-KP03-0005",    // FK → members
  "member_name": "Phạm Minh Cường",    // Denorm
  "neighborhood_id": "KP03",           // Denorm
  "registered_at": "Timestamp"
}
```

> **Mục đích:** Giúp Ban chỉ huy biết trước số lượng người tham gia để chuẩn bị hậu cần. Không liên quan đến điểm danh thực tế.

---

### 8. Collection: `attendances`
> Bản ghi điểm danh thực tế tại hiện trường.

```jsonc
{
  "attendance_id": "ATT-999888777",    // PK — Auto-gen
  "campaign_id": "MHX-2026",           // FK → campaigns
  "activity_id": "ACT-2026-001",       // FK → activities
  "activity_title": "Ra quân dọn dẹp vệ sinh kênh rạch", // Denorm
  "activity_level": "PHUONG",          // Denorm
  "member_id": "TN-2026-KP03-0042",    // FK → members
  "member_name": "Nguyễn Văn An",      // Denorm
  "neighborhood_id": "KP03",           // Denorm — dùng để filter theo khu phố
  "check_in_time": "Timestamp",
  "check_in_method": "QR_CODE",        // "QR_CODE" | "MANUAL"
  "points_earned": 20,                 // Snapshot điểm tại thời điểm điểm danh
  "recorded_by": "USER_ABC123XYZ"      // uid người thực hiện điểm danh
}
```

**Composite indexes cần tạo:**
- `campaign_id` + `neighborhood_id` + `check_in_time` (báo cáo theo chiến dịch & khu phố)
- `activity_id` + `member_id` (kiểm tra trùng lặp)
- `member_id` + `check_in_time` (lịch sử cá nhân)

---

### Tóm tắt quan hệ dữ liệu

```
campaigns ──────────────────────── campaign_neighborhoods
    │                                        │
    │ (campaign_id)                          │ (neighborhood_id → id)
    │                                   neighborhoods
    │                                        │
    ├── members                              │ (neighborhood_id → id)
    │       │                             users
    │       ├── attendances
    │       └── activity_registrations
    │
    └── activities
            │
            └── activity_registrations
```

---

## 📱 Trang chi tiết thành viên

Màn hình chi tiết thành viên gồm 3 phần:

**Thông tin cơ bản**
Họ tên, loại (Thiếu nhi / Đoàn viên), ngày sinh, khu phố, mã thành viên, trạng thái hoạt động.

**Tổng điểm tích luỹ**
Hiển thị nổi bật tổng điểm trong chiến dịch hiện tại.

**Tab mở rộng (tuỳ chọn):**
- *Lịch sử hoạt động* — danh sách các hoạt động đã điểm danh (tên, ngày, điểm cộng, phương thức QR/tay)
- *Biểu đồ điểm* — biểu đồ điểm tích luỹ theo thời gian trong chiến dịch

---

## 👤 Trang thông tin cá nhân

Tất cả tài khoản (User, Local Admin, Super Admin) đều có trang thông tin cá nhân riêng với khả năng **tự chỉnh sửa**:

- Họ tên hiển thị
- Ảnh đại diện (lấy từ Google hoặc tải lên)
- Thông tin liên hệ bổ sung (tuỳ chọn)

> Thông tin role và khu phố do hệ thống quản lý, người dùng **không tự thay đổi** được.

---

## 📐 Phân tách màn hình quản lý thành viên

Danh sách thiếu nhi và danh sách đoàn viên được thiết kế thành **2 trang riêng biệt** (không dùng tab chung) để rõ ràng về nghiệp vụ và UX:

- **Trang Thiếu Nhi** — tìm kiếm, lọc, thêm/sửa, in thẻ QR hàng loạt
- **Trang Đoàn Viên** — tìm kiếm, lọc, thêm/sửa, liên kết tài khoản Google, in thẻ QR

---

## ✅ Danh sách Task phát triển

### 🔧 Giai đoạn 0 — Cài đặt dự án (hoàn tất)
- [x] `SETUP-01` Khởi tạo Flutter project (`flutter create mhx_attendance`)
- [x] `SETUP-02` Firebase project `mhx-attendance-dev` (Auth Google, Firestore, FCM)
- [x] `SETUP-03` `flutterfire configure` — Android + Windows + (IOS + WEB)  (`google-services.json` local)
- [x] `SETUP-04` Packages: Firebase, Riverpod, go_router, QR/PDF/Excel
- [x] `SETUP-05` Firebase Emulator + `firestore.rules` / `functions/`
- [x] `SETUP-06` GitHub Actions CI (`flutter analyze`, `flutter test`)
- [x] `SETUP-07` Cấu trúc `lib/core/`, `lib/features/`, `lib/shared/`

> Chi tiết: [SETUP.md](SETUP.md)

---

### 🔐 Giai đoạn 1 — Xác thực & Phân quyền
- [ ] `AUTH-01` Tích hợp Google Sign-In với Firebase Auth
- [ ] `AUTH-02` Cloud Function: tự động gán role mặc định `USER` khi tài khoản mới tạo
- [ ] `AUTH-03` Màn hình đăng nhập (splash + Google button)
- [ ] `AUTH-04` Logic redirect sau đăng nhập theo role (Super Admin / Local Admin / User)
- [ ] `AUTH-05` Viết Firestore Security Rules cho tất cả collections
- [ ] `AUTH-06` Xử lý tài khoản bị khoá (`is_active = false`)
- [ ] `AUTH-07` Màn hình thông báo "Tài khoản chưa được cấp quyền"

---

### 🗓️ Giai đoạn 2 — Quản lý Chiến dịch (Super Admin)
- [ ] `CAM-01` Màn hình danh sách chiến dịch (tất cả năm, lọc theo trạng thái)
- [ ] `CAM-02` Form tạo chiến dịch mới (tên, năm, thời gian bắt đầu/kết thúc)
- [ ] `CAM-03` Thêm Bí Thư (Local Admin) phụ trách từng khu phố vào chiến dịch
- [ ] `CAM-04` Chỉnh sửa thông tin chiến dịch (chưa có hoạt động)
- [ ] `CAM-05` Kích hoạt / kết thúc chiến dịch (`is_active`)
- [ ] `CAM-06` Màn hình chọn chiến dịch khi đăng nhập (nếu có nhiều chiến dịch đang hoạt động)

---

### 🏘️ Giai đoạn 3 — Quản lý Khu phố & Tài khoản (Super Admin)
- [ ] `SA-01` Màn hình dashboard Super Admin (thống kê tổng theo chiến dịch đang chọn)
- [ ] `SA-02` Tạo / chỉnh sửa thông tin khu phố
- [ ] `SA-03` Danh sách Local Admin (tìm kiếm, lọc trạng thái)
- [ ] `SA-04` Cấp tài khoản Local Admin (nhập email Google → set Custom Claim)
- [ ] `SA-05` Khoá / mở khoá tài khoản Local Admin
- [ ] `SA-06` Cloud Function: set Custom Claims khi cấp/thu hồi quyền

---

### 👥 Giai đoạn 4 — Quản lý Thành viên (Local Admin)

**Trang Thiếu Nhi:**
- [ ] `TN-01` Danh sách thiếu nhi khu phố (tìm kiếm, lọc trạng thái)
- [ ] `TN-02` Form thêm thiếu nhi mới
- [ ] `TN-03` Form chỉnh sửa thông tin thiếu nhi
- [ ] `TN-04` Ẩn thiếu nhi (`is_active = false`) — không xoá cứng
- [ ] `TN-05` Trang chi tiết thiếu nhi (thông tin, tổng điểm, tab lịch sử + biểu đồ)

**Trang Đoàn Viên:**
- [ ] `DV-01` Danh sách đoàn viên khu phố (tìm kiếm, lọc trạng thái)
- [ ] `DV-02` Form thêm đoàn viên mới
- [ ] `DV-03` Form chỉnh sửa thông tin đoàn viên
- [ ] `DV-04` Ẩn đoàn viên (`is_active = false`) — không xoá cứng
- [ ] `DV-05` Liên kết đoàn viên với tài khoản Google (`account_uid`)
- [ ] `DV-06` Trang chi tiết đoàn viên (thông tin, tổng điểm, tab lịch sử + biểu đồ)

**Chung:**
- [ ] `MEM-01` Cloud Function: tự động tạo `member_id` cố định theo format `TN/DV-YYYY-KPxx-NNNN`
- [ ] `MEM-02` Super Admin: xem danh sách thiếu nhi & đoàn viên toàn địa bàn (chỉ xem, không sửa)

---

### 🪪 Giai đoạn 5 — Thẻ QR
- [ ] `QR-01` Generate QR code từ `member_id` (dùng `qr_flutter`)
- [ ] `QR-02` Thiết kế mẫu thẻ QR in (9×5.5cm, có tên, mã, khu phố, logo)
- [ ] `QR-03` Màn hình xem trước thẻ đơn lẻ
- [ ] `QR-04` Chọn nhiều thành viên để in hàng loạt
- [ ] `QR-05` Xuất PDF danh sách thẻ QR (8–10 thẻ/A4)
- [ ] `QR-06` Phân quyền: Local Admin chỉ in khu phố mình; Super Admin in tất cả
- [ ] `QR-07` In lại thẻ đơn lẻ (khi thành viên làm mất)

---

### 📅 Giai đoạn 6 — Hoạt động
- [ ] `ACT-01` Danh sách hoạt động trong chiến dịch (lọc theo ngày, cấp độ, trạng thái)
- [ ] `ACT-02` Form tạo hoạt động (Local Admin — cấp khu phố)
- [ ] `ACT-03` Form tạo hoạt động (Super Admin — cấp phường/thành phố, scope GLOBAL)
- [ ] `ACT-04` Cloud Function: tự tính `duration_days` và `total_points` khi tạo hoạt động
- [ ] `ACT-05` Chỉnh sửa hoạt động (chỉ khi chưa có bản ghi điểm danh)
- [ ] `ACT-06` Xoá / đóng hoạt động
- [ ] `ACT-07` Hiển thị hoạt động GLOBAL ở tất cả khu phố trong chiến dịch
- [ ] `ACT-08` Push Notification khi có hoạt động mới (FCM)
- [ ] `ACT-09` Đoàn viên đăng ký tham gia trước (`activity_registrations`)

---

### ☑️ Giai đoạn 7 — Điểm danh
- [ ] `ATT-01` Màn hình điểm danh — tab Quét QR
- [ ] `ATT-02` Tích hợp `mobile_scanner` quét QR, tra cứu `member_id` trong Firestore
- [ ] `ATT-03` Hiển thị xác nhận sau khi quét (tên, điểm cộng, animation)
- [ ] `ATT-04` Xử lý quét trùng (đã điểm danh rồi → cảnh báo, không cộng điểm lần 2)
- [ ] `ATT-05` Màn hình điểm danh — tab Tick tay (danh sách checkbox, tìm kiếm nhanh)
- [ ] `ATT-06` Nút "Lưu điểm danh" cho tick tay
- [ ] `ATT-07` Cloud Function: tính điểm theo công thức và cập nhật `members.total_points`
- [ ] `ATT-08` Hiển thị badge QR / Tay trong danh sách đã điểm
- [ ] `ATT-09` Cơ chế offline-first (Firestore local cache khi mất mạng, sync khi có mạng lại)
- [ ] `ATT-10` Local Admin cấp quyền điểm danh tạm thời cho 1 đoàn viên
- [ ] `ATT-11` Kiểm tra và thu hồi quyền tạm thời sau khi hết hạn

---

### 📊 Giai đoạn 8 — Thống kê & Báo cáo (Super Admin)
- [ ] `RPT-01` Biểu đồ cột điểm danh theo khu phố (theo tuần / tháng, trong chiến dịch)
- [ ] `RPT-02` Bộ lọc báo cáo (chiến dịch, khu phố, thời gian, loại thành viên)
- [ ] `RPT-03` Bảng xếp hạng Top N thiếu nhi nhiều điểm nhất
- [ ] `RPT-04` Xuất báo cáo PDF (danh sách điểm danh, xếp hạng)
- [ ] `RPT-05` Xuất báo cáo Excel (dữ liệu thô, dùng `syncfusion_flutter_xlsio`)
- [ ] `RPT-06` Thống kê tỉ lệ điểm danh mỗi hoạt động

---

### 📱 Giai đoạn 9 — Màn hình Đoàn viên (User)
- [ ] `USR-01` Dashboard đoàn viên (tổng điểm, xếp hạng khu phố, hoạt động sắp tới)
- [ ] `USR-02` Hiển thị QR cá nhân trên app (fullscreen khi cần quét)
- [ ] `USR-03` Lịch sử điểm danh cá nhân + biểu đồ điểm
- [ ] `USR-04` Danh sách hoạt động đang mở / sắp diễn ra trong chiến dịch
- [ ] `USR-05` Đăng ký tham gia hoạt động trước
- [ ] `USR-06` Nhận Push Notification hoạt động mới

---

### 👤 Giai đoạn 10 — Trang thông tin cá nhân (tất cả role)
- [ ] `PRF-01` Màn hình thông tin cá nhân (xem & chỉnh sửa: họ tên, ảnh đại diện)
- [ ] `PRF-02` Đồng bộ thay đổi lên Firestore (`users` collection)
- [ ] `PRF-03` Hiển thị role và khu phố (chỉ đọc, không chỉnh sửa)

---

### 🧪 Giai đoạn 11 — Kiểm thử & Hoàn thiện
- [ ] `TEST-01` Viết unit test cho Cloud Functions (tính điểm, tạo member_id)
- [ ] `TEST-02` Viết widget test cho màn hình điểm danh
- [ ] `TEST-03` Integration test luồng quét QR → cộng điểm
- [ ] `TEST-04` Kiểm thử Firestore Security Rules (Firebase Emulator)
- [ ] `TEST-05` Kiểm thử offline-first (mất mạng giữa chừng khi điểm danh)
- [ ] `TEST-06` Kiểm thử hiệu năng với 300+ thành viên
- [ ] `TEST-07` Kiểm thử UI trên Android, iOS, Windows
- [ ] `TEST-08` Phân phối bản beta qua Firebase App Distribution
- [ ] `TEST-09` Thu thập feedback từ Local Admin thử nghiệm thực tế

---

### 🚀 Giai đoạn 12 — Triển khai
- [ ] `DEP-01` Cấu hình Firestore Indexes production
- [ ] `DEP-02` Thiết lập Firebase Backup (Firestore export tự động)
- [ ] `DEP-03` Build và upload Android APK / AAB lên Google Play (internal track)
- [ ] `DEP-04` Build và upload iOS IPA lên TestFlight
- [ ] `DEP-05` Build Windows installer (MSIX)
- [ ] `DEP-06` Viết hướng dẫn sử dụng ngắn gọn cho Local Admin
- [ ] `DEP-07` Onboarding Super Admin lần đầu (tạo chiến dịch, khu phố, cấp tài khoản)

---

## 📁 Cấu trúc thư mục dự án (đề xuất)

```
mhx_attendance/
├── lib/
│   ├── core/
│   │   ├── constants/          # Colors, strings, enums
│   │   ├── router/             # go_router config
│   │   └── services/           # Firebase services
│   ├── features/
│   │   ├── auth/               # Đăng nhập, phân quyền
│   │   ├── campaigns/          # Quản lý chiến dịch (Super Admin)
│   │   ├── members/
│   │   │   ├── thieu_nhi/      # Trang quản lý Thiếu Nhi
│   │   │   └── doan_vien/      # Trang quản lý Đoàn Viên
│   │   ├── member_detail/      # Trang chi tiết thành viên (lịch sử, biểu đồ)
│   │   ├── profile/            # Trang thông tin cá nhân (tất cả role)
│   │   ├── activities/         # Hoạt động
│   │   ├── attendance/         # Điểm danh (QR + tick tay)
│   │   ├── qr_card/            # In thẻ QR
│   │   ├── reports/            # Báo cáo (Super Admin)
│   │   ├── dashboard_super/    # Dashboard Super Admin
│   │   ├── dashboard_local/    # Dashboard Local Admin
│   │   └── dashboard_user/     # Dashboard Đoàn viên
│   └── shared/
│       ├── widgets/            # Shared UI components
│       └── utils/              # Helpers, formatters
├── functions/                  # Firebase Cloud Functions (Node.js)
│   ├── src/
│   │   ├── auth/               # onUserCreate, set custom claims
│   │   ├── attendance/         # onAttendanceCreate → tính điểm
│   │   ├── campaigns/          # createCampaign, addNeighborhood
│   │   └── members/            # generateMemberId
│   └── package.json
├── firestore.rules
├── firestore.indexes.json
└── README.md
```

---

## 🗓️ Ước tính thời gian

| Giai đoạn | Nội dung | Ước tính |
|---|---|---|
| 0–1 | Cài đặt + Auth | 1 tuần |
| 2–3 | Chiến dịch + Khu phố + Tài khoản | 1.5 tuần |
| 4–5 | Thành viên + Thẻ QR | 1.5 tuần |
| 6–7 | Hoạt động + Điểm danh | 2 tuần |
| 8–10 | Báo cáo + Màn hình đoàn viên + Hồ sơ cá nhân | 1.5 tuần |
| 11–12 | Kiểm thử + Triển khai | 1 tuần |
| **Tổng** | | **~9.5 tuần** |

---
