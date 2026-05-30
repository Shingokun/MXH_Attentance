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
      'Quản lý chiến dịch, khu phố và điểm danh Mùa Hè Xanh.';

  static const String manageCampaigns = 'Quản lý chiến dịch';

  static const String navHome = 'Trang chủ';
  static const String navCampaigns = 'Chiến dịch';
  static const String navNeighborhoods = 'Khu phố';
  static const String navAdmins = 'Tài khoản';
  static const String navReports = 'Báo cáo';
  static const String superAdminComingSoon =
      'Tính năng sẽ có ở giai đoạn tiếp theo. Xem docs/WIREFRAMES.md.';
  static const String superAdminNoCampaignSelected =
      'Chưa chọn chiến dịch làm việc';
  static const String superAdminDashboardStatsTitle = 'Tổng quan (sắp có)';
  static const String superAdminStatMembers = 'Thành viên';
  static const String superAdminStatActivities = 'Hoạt động';
  static const String superAdminQuickNavTitle = 'Đi tới';

  static const String campaignListTitle = 'Chiến dịch';
  static const String campaignCreate = 'Tạo mới';
  static const String campaignCreateTitle = 'Tạo chiến dịch';
  static const String campaignListEmpty =
      'Chưa có chiến dịch nào. Bấm «Tạo mới» để thêm chiến dịch đầu tiên.';
  static const String campaignPhase2Next =
      'Màn hình này sẽ hoàn thiện trong các task CAM-02 đến CAM-05.';
  static const String campaignStatusInactive = 'Đã tắt';
  static const String campaignStatusUpcoming = 'Sắp tới';
  static const String campaignStatusEnded = 'Kết thúc';
  static const String campaignStatusRunning = 'Đang diễn ra';
  static const String campaignStatusActive = 'Đang bật';

  static const String campaignNameLabel = 'Tên chiến dịch';
  static const String campaignCodeLabel = 'Mã viết tắt';
  static const String campaignCodeHint = 'VD: MHX, TET, HE (2–8 ký tự)';
  static const String campaignCodeRequired = 'Vui lòng nhập mã viết tắt';
  static const String campaignCodeInvalid =
      'Mã không hợp lệ — dùng 2–8 ký tự A–Z hoặc số (vd. MHX, TET)';
  static const String campaignYearLabel = 'Năm';
  static const String campaignStartDateLabel = 'Ngày bắt đầu';
  static const String campaignEndDateLabel = 'Ngày kết thúc';
  static const String campaignPickDate = 'Chọn ngày';
  static const String campaignSave = 'Lưu';
  static const String cancel = 'Huỷ';
  static const String campaignNameRequired = 'Vui lòng nhập tên chiến dịch';
  static const String campaignYearInvalid = 'Năm không hợp lệ (2000–2100)';
  static const String campaignYearLocked = 'Không đổi năm sau khi tạo';
  static const String campaignDatesRequired = 'Vui lòng chọn ngày bắt đầu và kết thúc';
  static String campaignCreated(String id) => 'Đã tạo chiến dịch $id';
  static const String campaignDelete = 'Xóa chiến dịch';
  static const String campaignDeleteTitle = 'Xóa chiến dịch?';
  static String campaignDeleteBody(String name) =>
      'Xóa «$name» và toàn bộ phân công khu phố? Hành động không hoàn tác.';
  static const String campaignDeleted = 'Đã xóa chiến dịch';
  static const String campaignDeleteBlockedActivities =
      'Không thể xóa — chiến dịch đã có hoạt động.';
  static const String campaignDeleteBlockedMembers =
      'Không thể xóa — chiến dịch đã có thành viên.';
  static const String campaignDeleteBlockedHint =
      'Chỉ xóa được chiến dịch chưa có hoạt động và thành viên.';
  static const String campaignUpdated = 'Đã cập nhật chiến dịch';
  static const String campaignNotFound = 'Không tìm thấy chiến dịch';
  static const String campaignEdit = 'Chỉnh sửa';
  static const String campaignEditBlocked =
      'Chiến dịch đã có hoạt động — không thể sửa tên hoặc thời gian.';
  static const String campaignActiveLabel = 'Kích hoạt chiến dịch';
  static const String campaignActiveHint = 'Chiến dịch đang được bật';
  static const String campaignInactiveHint = 'Chiến dịch đã tắt';
  static const String campaignActivated = 'Đã kích hoạt chiến dịch';
  static const String campaignDeactivated = 'Đã kết thúc chiến dịch';
  static const String campaignNeighborhoodsTitle = 'Khu phố tham gia';
  static const String campaignAssignAdmin = 'Thêm Bí thư';
  static const String campaignAssign = 'Gán';
  static const String campaignAssigned = 'Đã gán Bí thư cho khu phố';
  static const String campaignNoAssignments =
      'Chưa có khu phố nào. Thêm Bí thư phụ trách từng khu phố.';
  static const String campaignNoNeighborhoods =
      'Chưa có khu phố. Tạo khu phố trong Firestore hoặc Giai đoạn 3.';
  static const String campaignNoLocalAdmins =
      'Chưa có Local Admin. Cấp quyền LOCAL_ADMIN trước (Giai đoạn 3).';
  static const String campaignNeighborhoodLabel = 'Khu phố';
  static const String campaignLocalAdminLabel = 'Bí thư (Local Admin)';
  static const String campaignRemove = 'Gỡ';
  static const String campaignRemoveAssignmentTitle = 'Gỡ Bí thư khỏi chiến dịch?';
  static String campaignRemoveAssignmentBody(String neighborhoodId) =>
      'Gỡ phân công khu phố $neighborhoodId khỏi chiến dịch này?';
  static const String campaignAssignmentRemoved = 'Đã gỡ phân công';
  static const String campaignSelectTitle = 'Chọn chiến dịch';
  static const String campaignSelectEmpty =
      'Không có chiến dịch đang bật. Bạn vẫn có thể quản lý chiến dịch từ trang chủ.';
  static const String firestoreIndexRequired =
      'Firestore cần tạo index. Chạy: firebase deploy --only firestore:indexes '
      'hoặc mở link trong log lỗi trên Firebase Console.';
  static const String continueWithoutCampaign = 'Về trang chủ';
  static const String selectedCampaignLabel = 'Chiến dịch đang chọn';
  static const String changeCampaign = 'Đổi chiến dịch';
}
