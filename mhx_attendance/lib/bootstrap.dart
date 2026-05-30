import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in_dartio/google_sign_in_dartio.dart';

import 'app.dart';
import 'core/constants/google_sign_in_config.dart';
import 'core/services/firebase_bootstrap.dart';

/// Khởi động app; [initializeFirebase] tắt trong widget test.
Future<void> bootstrap({bool initializeFirebase = true}) async {
  WidgetsFlutterBinding.ensureInitialized();

  await _registerDesktopGoogleSignIn();

  if (initializeFirebase) {
    await FirebaseBootstrap.initialize();
  }

  runApp(const ProviderScope(child: MhxApp()));
}

/// `google_sign_in` không có implementation Windows/Linux — dùng pure-Dart.
Future<void> _registerDesktopGoogleSignIn() async {
  if (kIsWeb) return;
  final isDesktop = defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;
  if (!isDesktop) return;

  final desktopId = GoogleSignInConfig.desktopClientId;
  if (desktopId.isEmpty) {
    throw StateError(
      'Thiếu GOOGLE_DESKTOP_CLIENT_ID.\n'
      'Google Cloud Console → Credentials → Tạo OAuth client loại '
      '"Desktop app" (ứng dụng máy tính) cho project mhx-attendance-dev,\n'
      'rồi chạy:\n'
      '  flutter run -d windows '
      '--dart-define=GOOGLE_DESKTOP_CLIENT_ID=<client-id>.apps.googleusercontent.com',
    );
  }

  await GoogleSignInDart.register(clientId: desktopId);
}
