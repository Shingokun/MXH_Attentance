import 'package:flutter/foundation.dart';

/// Cấu hình Google Sign-In.
abstract final class GoogleSignInConfig {
  /// **Web client** (Firebase Console → Authentication → Google → Web client ID).
  /// Dùng làm `serverClientId` trên Android để lấy `idToken` cho Firebase Auth.
  ///
  /// `--dart-define=FIREBASE_WEB_CLIENT_ID=...`
  /// `client_type: 3` trong `android/app/google-services.json` (Web client).
  static const String firebaseWebClientId = String.fromEnvironment(
    'FIREBASE_WEB_CLIENT_ID',
    defaultValue:
        '971546956248-pv168eqbo7h0aral0tp65m7q7l36ttcr.apps.googleusercontent.com',
  );

  /// **Desktop OAuth client** (Google Cloud → Credentials → Desktop app).
  /// Bắt buộc cho Windows/Linux (`google_sign_in_dartio`). Không dùng Android client ID.
  ///
  /// `--dart-define=GOOGLE_DESKTOP_CLIENT_ID=...`
  static const String desktopClientId = String.fromEnvironment(
    'GOOGLE_DESKTOP_CLIENT_ID',
    defaultValue:
        '971546956248-m9ggeuqo8f3h7ae0n107brdbffleg5cm.apps.googleusercontent.com',
  );

  /// Alias cũ — trỏ tới desktop client.
  static const String webClientId = desktopClientId;

  static String? get clientId {
    if (kIsWeb) return firebaseWebClientId;
    return switch (defaultTargetPlatform) {
      TargetPlatform.windows || TargetPlatform.linux => desktopClientId.isEmpty
          ? null
          : desktopClientId,
      _ => null,
    };
  }

  static bool get isDesktopClientConfigured => desktopClientId.isNotEmpty;
}
