import 'package:cloud_firestore/cloud_firestore.dart';

/// Document `neighborhoods/{neighborhoodId}`.
class Neighborhood {
  const Neighborhood({
    required this.id,
    required this.name,
    this.wardName,
    this.cityName,
    this.adminUid,
    this.adminName,
  });

  final String id;
  final String name;
  final String? wardName;
  final String? cityName;
  final String? adminUid;
  final String? adminName;

  String get displayLabel {
    if (wardName != null && wardName!.isNotEmpty) {
      return '$name · $wardName';
    }
    return name;
  }

  factory Neighborhood.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Neighborhood(
      id: doc.id,
      name: data['name'] as String? ?? doc.id,
      wardName: data['ward_name'] as String?,
      cityName: data['city_name'] as String?,
      adminUid: data['admin_uid'] as String?,
      adminName: data['admin_name'] as String?,
    );
  }
}
