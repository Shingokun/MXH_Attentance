import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/user_role.dart';

/// Hồ sơ `users/{uid}` trên Firestore.
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.photoUrl,
    required this.role,
    required this.isActive,
    this.neighborhoodId,
    this.neighborhoodName,
  });

  final String uid;
  final String email;
  final String fullName;
  final String? photoUrl;
  final UserRole role;
  final bool isActive;
  final String? neighborhoodId;
  final String? neighborhoodName;

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final role = UserRole.tryParse(data['role'] as String?);
    if (role == null) {
      throw FormatException('Invalid role for user ${doc.id}');
    }
    return AppUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      fullName: data['full_name'] as String? ?? '',
      photoUrl: data['photo_url'] as String?,
      role: role,
      isActive: data['is_active'] as bool? ?? true,
      neighborhoodId: data['neighborhood_id'] as String?,
      neighborhoodName: data['neighborhood_name'] as String?,
    );
  }

  /// Local Admin chưa được Super Admin gán khu phố.
  bool get isLocalAdminUnprovisioned =>
      role == UserRole.localAdmin && (neighborhoodId == null || neighborhoodId!.isEmpty);
}
