/// Vai trò tài khoản (khớp Custom Claims + Firestore `users.role`).
enum UserRole {
  superAdmin('SUPER_ADMIN'),
  localAdmin('LOCAL_ADMIN'),
  user('USER');

  const UserRole(this.firestoreValue);

  final String firestoreValue;

  static UserRole? tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final role in UserRole.values) {
      if (role.firestoreValue == value) return role;
    }
    return null;
  }

  String get homePath => switch (this) {
        UserRole.superAdmin => '/home/super',
        UserRole.localAdmin => '/home/local',
        UserRole.user => '/home/user',
      };
}
