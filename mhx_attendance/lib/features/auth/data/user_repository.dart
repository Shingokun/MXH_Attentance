import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/app_user.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Stream<AppUser?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return AppUser.fromFirestore(snap);
    });
  }

  Future<AppUser?> getUser(String uid) async {
    final snap = await _users.doc(uid).get();
    if (!snap.exists) return null;
    return AppUser.fromFirestore(snap);
  }

  /// Tạo `users/{uid}` nếu Cloud Function chưa chạy (deploy trễ / user cũ).
  /// Khớp schema [onAuthUserCreate].
  Future<bool> ensureInitialProfile(User firebaseUser) async {
    final doc = _users.doc(firebaseUser.uid);
    final existing = await doc.get();
    if (existing.exists) return true;

    await doc.set({
      'uid': firebaseUser.uid,
      'email': firebaseUser.email ?? '',
      'full_name': firebaseUser.displayName ?? '',
      'photo_url': firebaseUser.photoURL,
      'role': 'USER',
      'neighborhood_id': null,
      'neighborhood_name': null,
      'device_token': null,
      'is_active': true,
      'temp_attendance_permission': false,
      'temp_permission_expires_at': null,
      'created_at': FieldValue.serverTimestamp(),
      'created_by': null,
    });

    return true;
  }
}
