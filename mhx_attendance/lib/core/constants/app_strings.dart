/// Chuỗi hiển thị dùng chung.
abstract final class AppStrings {
  static const String appName = 'MHX Attendance';
  static const String welcomeTagline =
      'Điểm danh Mùa Hè Xanh — chào mừng bạn quay trở lại.';
  static const String loginTagline = welcomeTagline;

  static const String loginButton = 'Đăng nhập';
  static const String registerButton = 'Đăng ký';
  static const String loginTitle = 'Đăng nhập';
  static const String loginSubtitle =
      'Nhập email và mật khẩu, hoặc dùng tài khoản Google.';
  static const String registerTitle = 'Đăng ký tài khoản';
  static const String registerSubtitle =
      'Tạo tài khoản mới bằng email hoặc Google.';
  static const String signInWithGoogle = 'Đăng nhập với Google';
  static const String registerWithGoogle = 'Đăng ký với Google';
  static const String signingIn = 'Đang đăng nhập...';
  static const String registering = 'Đang đăng ký...';
  static const String signOut = 'Đăng xuất';
  static const String orDivider = 'hoặc';
  static const String noAccountRegister = 'Chưa có tài khoản? Đăng ký';
  static const String hasAccountLogin = 'Đã có tài khoản? Đăng nhập';

  static const String fullNameLabel = 'Họ và tên';
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Mật khẩu';
  static const String confirmPasswordLabel = 'Xác nhận mật khẩu';
  static const String passwordHint = 'Tối thiểu 6 ký tự';
  static const String fullNameRequired = 'Vui lòng nhập họ tên';
  static const String emailRequired = 'Vui lòng nhập email';
  static const String emailInvalid = 'Email không hợp lệ';
  static const String passwordRequired = 'Vui lòng nhập mật khẩu';
  static const String passwordTooShort = 'Mật khẩu tối thiểu 6 ký tự';
  static const String passwordMismatch = 'Mật khẩu xác nhận không khớp';

  static const String loadingSession = 'Đang tải phiên đăng nhập...';

  static const String accountLockedTitle = 'Tài khoản đã bị khoá';
  static const String accountLockedBody =
      'Tài khoản của bạn đã bị vô hiệu hoá. Vui lòng liên hệ Ban chỉ huy '
      'để được hỗ trợ.';

  static const String unauthorizedTitle = 'Tài khoản chưa được cấp quyền';
  static const String unauthorizedBody =
      'Bạn chưa được Super Admin phân công khu phố hoặc vai trò quản trị. '
      'Vui lòng liên hệ Ban chỉ huy.';

  static const String provisioningTitle = 'Đang thiết lập tài khoản';
  static const String provisioningBody =
      'Hệ thống đang tạo hồ sơ của bạn. Vui lòng đợi trong giây lát...\n\n'
      'Nếu chờ quá lâu: bấm «Thử lại» hoặc deploy Cloud Function '
      '`onAuthUserCreate` + `firestore:rules`.';
  static const String retryCreateProfile = 'Thử lại';

  static const String homeSuperAdmin = 'Ban chỉ huy (Super Admin)';
  static const String homeLocalAdmin = 'Bí thư khu phố (Local Admin)';
  static const String homeUser = 'Đoàn viên';
  static const String roleHomePlaceholder =
      'Giai đoạn 1 — xác thực hoàn tất. Các tính năng nghiệp vụ sẽ có ở giai đoạn sau.';
}
