# Giai đoạn 0 — Hoàn tất

## Checklist

| Hạng mục | Trạng thái |
|----------|------------|
| Flutter app + Riverpod + go_router | OK |
| `vn.mhx.attendance` + Gradle Firebase | OK |
| `flutterfire configure` (Android + Windows) | OK |
| `firebase_options.dart` + `google-services.json` (local) | OK |
| Emulator config (`firebase.json`, rules, functions) | OK |
| CI `.github/workflows/flutter_ci.yml` | OK |
| Chạy thử Windows / Android | OK (trên máy dev) |

**Giai đoạn 1:** Auth hoàn tất — xem [README.md](README.md).

**Giai đoạn 2:** Quản lý chiến dịch hoàn tất (`CAM-01`–`CAM-06`). **Tiếp theo:** Giai đoạn 3 — Khu phố & Tài khoản.

## Giai đoạn 2 — Chuẩn bị & kiểm thử nhanh

### Điều kiện

- Đăng nhập bằng tài khoản **SUPER_ADMIN** (script `functions/scripts/set-user-role.mjs` hoặc Firestore `users/{uid}.role`).
- Deploy rules (đã có quyền `campaigns` / `campaign_neighborhoods` cho Super Admin).

### Chạy app

```powershell
cd mhx_attendance
flutter run -d windows
```

Super Admin → **Quản lý chiến dịch** → danh sách (Firestore `campaigns`, sắp theo `year` giảm dần).

### Tạo dữ liệu mẫu (Emulator hoặc production)

Document ID = `{code}-{year}` (vd. `MHX-2026`, `TET-2026` — mã viết tắt 2–8 ký tự):

| Field | Ví dụ |
|-------|--------|
| `name` | Mùa Hè Xanh 2026 |
| `year` | `2026` |
| `start_date` | Timestamp |
| `end_date` | Timestamp |
| `is_active` | `true` |
| `created_by` | uid Super Admin |
| `created_at` | server timestamp |

### Deploy index (nếu query báo thiếu index)

```powershell
firebase deploy --only firestore:indexes
```

### Thứ tự implement đề xuất

1. `CAM-02` — Form tạo chiến dịch (gọi `CampaignRepository.createCampaign`)
2. `CAM-05` — Toggle `is_active`
3. `CAM-03` — Gán Bí thư / `campaign_neighborhoods` (cần collection `neighborhoods` từ Giai đoạn 3 hoặc seed sẵn)
4. `CAM-04` — Sửa chiến dịch (chặn nếu đã có `activities`)
5. `CAM-06` — `selectedCampaignIdProvider` + redirect sau login

### Seed `neighborhoods` mẫu (CAM-03) — không cần Console thủ công

Script: `functions/scripts/seed-neighborhoods.mjs` (tạo KP01–KP05).

**Firestore cloud** (app đang trỏ production `mhx-attendance-dev`):

```powershell
cd mhx_attendance/functions
firebase login
npm run seed:neighborhoods
```

**Emulator** (terminal 1: `firebase emulators:start`; terminal 2):

```powershell
cd mhx_attendance/functions
npm run seed:neighborhoods:emulator
```

Xem dữ liệu: [Firebase Console → Firestore](https://console.firebase.google.com/project/mhx-attendance-dev/firestore) hoặc Emulator UI `http://localhost:4000`.

Dropdown **Bí thư** cần thêm user `LOCAL_ADMIN`:

```powershell
node scripts/set-user-role.mjs <UID_LOCAL_ADMIN> LOCAL_ADMIN
```

## Flutter không nhận lệnh `flutter` (PATH)

Flutter cài tại `C:\Users\hoang\flutter` nhưng chưa có trong PATH → dùng **một trong hai**:

**Cách A — Mỗi lần mở terminal (tạm):**

```powershell
$env:Path = "C:\Users\hoang\flutter\bin;" + $env:Path
flutter devices
```

**Cách B — Thêm PATH vĩnh viễn (khuyến nghị):**

1. Windows → tìm **Environment Variables** → **Path** (User) → **New**
2. Thêm: `C:\Users\hoang\flutter\bin`
3. Đóng hết terminal/Cursor → mở lại → `flutter --version`

**Cách C — Gọi đường dẫn đầy đủ (không cần PATH):**

```powershell
C:\Users\hoang\flutter\bin\flutter.bat devices
C:\Users\hoang\flutter\bin\flutter.bat run -d emulator-5554
```

## Lệnh thường dùng

```powershell
cd mhx_attendance
flutter pub get
flutter analyze
flutter test

# Chạy app
flutter run -d windows
flutter run -d emulator-5554
```

# Emulator Firebase (tuỳ chọn)
cd functions && npm install && npm run build && cd ..
firebase emulators:start
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
# Android emulator: thêm --dart-define=FIREBASE_EMULATOR_HOST=10.0.2.2
```

## Deploy Functions + Rules (Giai đoạn 1)

> **Quan trọng:** `package.json` nằm trong `functions\`, không phải thư mục gốc Flutter.  
> `firebase.json` nằm trong `mhx_attendance\`, không phải `MXH_Attentance\` (repo cha).

### Gói Firebase: Spark vs Blaze

| Thành phần | Gói Spark (miễn phí) | Gói Blaze (trả theo dùng) |
|------------|----------------------|---------------------------|
| Deploy **Firestore Rules** | Có | Có |
| Deploy **Cloud Functions** lên production | **Không** | **Có** (bắt buộc) |
| **Emulator** Functions + Auth + Firestore (máy dev) | Có | Có |

Lỗi `must be on the Blaze plan` = project đang Spark, cần nâng cấp để deploy Functions:
https://console.firebase.google.com/project/mhx-attendance-dev/usage/details

Blaze vẫn có **hạn mức miễn phí** (invocations/tháng, GB-seconds…); dev thường không tốn phí nếu traffic thấp. Nên bật **billing alert** trên Google Cloud.

### A) Chỉ deploy Rules (Spark được — làm ngay)

Trong `mhx_attendance`:

```powershell
firebase deploy --only firestore:rules
```

Rules của bạn đã compile thành công; bước này không cần Blaze.

### B) Deploy Functions (cần Blaze)

```powershell
cd functions
npm install
npm run build
cd ..
firebase deploy --only functions:onAuthUserCreate
```

Hoặc Rules + Functions sau khi nâng Blaze:

```powershell
firebase deploy --only functions:onAuthUserCreate,firestore:rules
```

### C) Dev không Blaze — dùng Emulator

```powershell
cd functions
npm install
npm run build
cd ..
firebase emulators:start
```

Terminal khác:

```powershell
cd mhx_attendance
flutter run -d windows --dart-define=USE_FIREBASE_EMULATORS=true
```

Emulator chạy `onAuthUserCreate` local (tạo `users/{uid}` + claim `USER`). Auth/Firestore trên emulator **không** dùng chung dữ liệu production.

**Không** chạy `npm run build` ở `mhx_attendance` (thiếu `package.json`)  
**Không** chạy `firebase deploy` ở `MXH_Attentance` (thiếu `firebase.json`).

## Google Sign-In trên Windows

Package `google_sign_in` **không** hỗ trợ Windows. App dùng `google_sign_in_dartio` (mở trình duyệt, redirect `http://127.0.0.1:<cổng>`).

### Lỗi `Error 400: invalid_request` (Access blocked)

Thường do dùng **sai Client ID** (ví dụ Android client) cho Windows. Cần client riêng loại **Desktop app**.

### Cấu hình (làm một lần)

1. Mở [Google Cloud Credentials](https://console.cloud.google.com/apis/credentials?project=mhx-attendance-dev)
2. **Create Credentials** → **OAuth client ID**
3. Application type: **Desktop app** (Ứng dụng máy tính) — không chọn Android/Web cho bước này
4. Đặt tên (vd. `MHX Attendance Windows`) → **Create** → copy **Client ID**
5. [OAuth consent screen](https://console.cloud.google.com/apis/credentials/consent?project=mhx-attendance-dev): nếu app ở chế độ **Testing**, thêm email `hoanglong0338@gmail.com` vào **Test users**

### Chạy app với Desktop Client ID

```powershell
cd mhx_attendance
C:\Users\hoang\flutter\bin\flutter.bat run -d windows
```

Desktop Client ID mặc định đã cấu hình trong `lib/core/constants/google_sign_in_config.dart`. Ghi đè nếu cần:

```powershell
flutter run -d windows --dart-define=GOOGLE_DESKTOP_CLIENT_ID=other-id.apps.googleusercontent.com
```

(Tuỳ chọn Android — **Web client** từ Firebase, khác Desktop ID:)

```powershell
flutter run -d android --dart-define=FIREBASE_WEB_CLIENT_ID=<web-client-id>.apps.googleusercontent.com
```

Lấy **Web client ID**: Firebase Console → Authentication → Sign-in method → Google → Web SDK configuration.

Sau khi đổi client ID: `flutter clean` rồi `flutter run` lại (không chỉ hot reload).

## Android: `ApiException: 10` (sign_in_failed)

Mã **10** = `DEVELOPER_ERROR` — cấu hình Google/Firebase chưa khớp app Android.

### Checklist (làm đủ 4 bước)

1. **File `android/app/google-services.json`** phải tồn tại (tạo bằng `flutterfire configure`, không commit lên Git).

2. **SHA-1 debug** (máy bạn — chạy `.\gradlew signingReport` trong `android`):

   ```
   A5:E3:7C:B7:BB:B1:89:66:10:2F:25:3B:32:0E:84:3D:05:A7:FC:F4
   ```

   Thêm vào [Firebase Project settings](https://console.firebase.google.com/project/mhx-attendance-dev/settings/general) → app **Android** (`vn.mhx.attendance`) → **Add fingerprint** → dán SHA-1 → **Save**.

   (Nên thêm cả **SHA-256** nếu Console yêu cầu — cùng lệnh `signingReport`.)

3. **Bật đăng nhập:** Firebase → Authentication → Sign-in method:
   - **Google** → Enable
   - **Email/Password** → Enable (cho đăng ký / đăng nhập email)

4. **`serverClientId` (Web client ID)** — khác Android client và Desktop client:

   Firebase → Authentication → Google → **Web SDK configuration** → copy **Web client ID**.

   Chạy app:

   ```powershell
   flutter run -d emulator-5554 --dart-define=FIREBASE_WEB_CLIENT_ID=<WEB_CLIENT_ID>.apps.googleusercontent.com
   ```

   Web client ID trong `google-services.json` (`client_type: 3`):

   `971546956248-pv168eqbo7h0aral0tp65m7q7l36ttcr.apps.googleusercontent.com`

   (Đã là mặc định trong `google_sign_in_config.dart` — không dùng Android client `coobqht4...` hay Desktop `m9ggeuqo8...`.)

Sau khi sửa: tải lại `google-services.json` nếu Firebase gợi ý → `flutter clean` → `flutter run -d emulator-5554`.

## SHA-1 (Google Sign-In Android)

```powershell
cd mhx_attendance\android
.\gradlew signingReport
```

Tìm dòng `Variant: debug` → `SHA1: ...` → thêm vào Firebase Console → Project settings → app Android.

## Cấp Super Admin (hoặc đổi role) cho một tài khoản

App đọc **role từ Firestore** (`users/{uid}.role`) để mở màn hình. **Firestore Rules** đọc **Custom Claims** (`request.auth.token.role`) — cần **cả hai**.

### Bước 1 — Lấy UID

Firebase Console → [Authentication](https://console.firebase.google.com/project/mhx-attendance-dev/authentication/users) → chọn user → copy **User UID**.

(Hoặc Firestore → `users` → document ID = UID.)

### Bước 2 — Script (khuyến nghị)

```powershell
cd mhx_attendance\functions
firebase login
node scripts/set-user-role.mjs <UID> SUPER_ADMIN
```

Ví dụ:

```powershell
node scripts/set-user-role.mjs abc123xyz SUPER_ADMIN
```

### Bước 2 thay thế — Sửa tay trên Console

**Firestore** → `users` → `{UID}` → sửa:

| Trường | Giá trị |
|--------|---------|
| `role` | `SUPER_ADMIN` |
| `is_active` | `true` |
| `neighborhood_id` | `null` |

**Custom Claims** (Console không sửa trực tiếp): dùng script ở trên, hoặc Cloud Functions shell với Admin SDK.

### Bước 3 — Đăng xuất / đăng nhập lại

Token cũ chưa có claim mới → trong app bấm **Đăng xuất**, đăng nhập lại → vào màn **Ban chỉ huy (Super Admin)**.

---

**Local Admin:** `node scripts/set-user-role.mjs <UID> LOCAL_ADMIN` và gán `neighborhood_id` (vd. `KP03`) trên Firestore.

**Giai đoạn 3:** `SA-06` sẽ có chức năng cấp quyền trong app (Super Admin UI).

## File không commit (repo **public**)

- `lib/firebase_options.dart` — tạo local (Windows, xem lệnh bên dưới)
- `android/app/google-services.json`
- `functions/node_modules/`, `functions/lib/`

Mẫu: `lib/firebase_options.dart.example`. Chi tiết: [SECURITY.md](SECURITY.md).

```powershell
cd mhx_attendance
C:\Users\hoang\flutter\bin\dart.bat pub global run flutterfire_cli:flutterfire configure --project=mhx-attendance-dev
```

Chọn **android**, **windows**. Trước đó: `firebase login` (cần Firebase CLI trong PATH hoặc `%AppData%\npm`).

**Nếu key đã từng push lên GitHub:** giới hạn hoặc rotate API key trên Google Cloud (xem SECURITY.md).
