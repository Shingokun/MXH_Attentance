import 'package:firebase_auth/firebase_auth.dart';

import 'auth_repository.dart';

/// Chuyển lỗi Firebase Auth sang tiếng Việt.
String mapFirebaseAuthError(Object error) {
  if (error is AuthCancelledException) {
    return error.toString();
  }
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-email' => 'Email không hợp lệ.',
      'user-disabled' => 'Tài khoản đã bị vô hiệu hoá.',
      'user-not-found' => 'Không tìm thấy tài khoản với email này.',
      'wrong-password' => 'Mật khẩu không đúng.',
      'email-already-in-use' => 'Email đã được đăng ký.',
      'weak-password' => 'Mật khẩu quá yếu (tối thiểu 6 ký tự).',
      'invalid-credential' => 'Email hoặc mật khẩu không đúng.',
      'operation-not-allowed' =>
        'Đăng nhập email chưa bật trên Firebase Console.',
      'too-many-requests' => 'Quá nhiều lần thử. Vui lòng thử lại sau.',
      _ => error.message ?? 'Đã xảy ra lỗi xác thực (${error.code}).',
    };
  }
  return error.toString();
}
