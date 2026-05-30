import '../../campaigns/presentation/campaign_routes.dart';

/// Routes trong shell Super Admin (`SCR-SA-*`, `SCR-CAM-*`).
abstract final class SuperAdminRoutes {
  static const home = '/home/super';
  static const neighborhoods = '/neighborhoods';
  static const admins = '/admins';
  static const reports = '/reports';

  static bool isShellPath(String location) {
    if (location == home) return true;
    if (location.startsWith(neighborhoods)) return true;
    if (location.startsWith(admins)) return true;
    if (location.startsWith(reports)) return true;
    if (CampaignRoutes.isCampaignPath(location) &&
        location != CampaignRoutes.select) {
      return true;
    }
    return false;
  }

  static bool isSuperAdminArea(String location) =>
      isShellPath(location) || location == CampaignRoutes.select;

  /// Chỉ số nhánh `StatefulShellRoute` — khớp thứ tự khai báo router.
  static int branchIndexForLocation(String location) {
    if (location.startsWith(home)) return 0;
    if (location.startsWith(CampaignRoutes.list)) return 1;
    if (location.startsWith(neighborhoods)) return 2;
    if (location.startsWith(admins)) return 3;
    if (location.startsWith(reports)) return 4;
    return 0;
  }
}
