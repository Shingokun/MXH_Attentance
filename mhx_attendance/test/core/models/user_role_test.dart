import 'package:flutter_test/flutter_test.dart';
import 'package:mhx_attendance/core/models/user_role.dart';
import 'package:mhx_attendance/features/auth/presentation/auth_routes.dart';

void main() {
  group('UserRole', () {
    test('tryParse accepts known roles', () {
      expect(UserRole.tryParse('SUPER_ADMIN'), UserRole.superAdmin);
      expect(UserRole.tryParse('LOCAL_ADMIN'), UserRole.localAdmin);
      expect(UserRole.tryParse('USER'), UserRole.user);
      expect(UserRole.tryParse('INVALID'), isNull);
    });

    test('homePath maps to route', () {
      expect(UserRole.superAdmin.homePath, AuthRoutes.homeSuper);
      expect(UserRole.localAdmin.homePath, AuthRoutes.homeLocal);
      expect(UserRole.user.homePath, AuthRoutes.homeUser);
    });
  });
}
