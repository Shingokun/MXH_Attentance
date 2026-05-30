# Bảo mật — repo public

## Không commit

| File | Lý do |
|------|--------|
| `lib/firebase_options.dart` | Chứa Firebase client config — tạo local bằng FlutterFire |
| `android/app/google-services.json` | Config Android Firebase |

Sau clone:

```powershell
cd mhx_attendance
flutterfire configure --project=mhx-attendance-dev
```

(chọn **android**, **windows**)

## API key đã từng lộ trên Git?

Nếu `firebase_options.dart` từng được push:

1. [Google Cloud Console](https://console.cloud.google.com/) → **APIs & Services** → **Credentials**
2. **Giới hạn** từng API key (Android: package `vn.mhx.attendance` + SHA-1; Web: referrer/app)
3. Cân nhắc **tạo key mới / xoá key cũ** rồi chạy lại `flutterfire configure`

Key vẫn có thể nằm trong **lịch sử Git** cũ — giới hạn/rotate trên Google Cloud là bắt buộc.

## Quyền thật sự

- **Firestore Security Rules** + **Authentication** bảo vệ dữ liệu, không phải việc giấu client API key.
