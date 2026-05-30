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

**Tiếp theo:** Giai đoạn 1 — Auth (`AUTH-01` …) trong [README.md](README.md).

## Lệnh thường dùng

```powershell
cd mhx_attendance
flutter pub get
flutter analyze
flutter test

# Chạy app
flutter run -d windows
flutter run -d <android-device-id>

# Emulator Firebase (tuỳ chọn)
cd functions && npm install && npm run build && cd ..
firebase emulators:start
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
# Android emulator: thêm --dart-define=FIREBASE_EMULATOR_HOST=10.0.2.2
```

## SHA-1 (Google Sign-In Android — Giai đoạn 1)

```powershell
cd android
.\gradlew signingReport
```

Thêm SHA-1 debug vào Firebase Console → Project settings → app Android.

## File không commit (repo **public**)

- `lib/firebase_options.dart` — tạo local: `flutterfire configure --project=mhx-attendance-dev`
- `android/app/google-services.json`
- `functions/node_modules/`, `functions/lib/`

Mẫu: `lib/firebase_options.dart.example`. Chi tiết: [SECURITY.md](SECURITY.md).

**Nếu key đã từng push lên GitHub:** giới hạn hoặc rotate API key trên Google Cloud (xem SECURITY.md).
