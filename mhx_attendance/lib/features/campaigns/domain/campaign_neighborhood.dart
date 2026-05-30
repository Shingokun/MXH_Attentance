import 'package:cloud_firestore/cloud_firestore.dart';

/// Document `campaign_neighborhoods/{id}` — PK = `{campaignId}_{neighborhoodId}`.
class CampaignNeighborhood {
  const CampaignNeighborhood({
    required this.id,
    required this.campaignId,
    required this.neighborhoodId,
    required this.adminUid,
    required this.adminName,
    this.joinedAt,
  });

  final String id;
  final String campaignId;
  final String neighborhoodId;
  final String adminUid;
  final String adminName;
  final DateTime? joinedAt;

  static String composeId({
    required String campaignId,
    required String neighborhoodId,
  }) =>
      '${campaignId}_$neighborhoodId';

  factory CampaignNeighborhood.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return CampaignNeighborhood(
      id: doc.id,
      campaignId: data['campaign_id'] as String? ?? '',
      neighborhoodId: data['neighborhood_id'] as String? ?? '',
      adminUid: data['admin_uid'] as String? ?? '',
      adminName: data['admin_name'] as String? ?? '',
      joinedAt: _readDateOrNull(data['joined_at']),
    );
  }

  static DateTime? _readDateOrNull(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
