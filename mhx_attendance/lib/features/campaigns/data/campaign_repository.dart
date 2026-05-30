import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/campaign.dart';
import '../domain/campaign_list_filter.dart';
import '../domain/campaign_neighborhood.dart';

class CampaignRepository {
  CampaignRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _campaigns =>
      _firestore.collection('campaigns');

  CollectionReference<Map<String, dynamic>> get _campaignNeighborhoods =>
      _firestore.collection('campaign_neighborhoods');

  Stream<List<Campaign>> watchCampaigns({CampaignListFilter filter = CampaignListFilter.all}) {
    return _campaigns.orderBy('year', descending: true).snapshots().map((snap) {
      final list = snap.docs.map(Campaign.fromFirestore).toList();
      return _applyFilter(list, filter);
    });
  }

  Stream<Campaign?> watchCampaign(String campaignId) {
    return _campaigns.doc(campaignId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return Campaign.fromFirestore(snap);
    });
  }

  Stream<List<CampaignNeighborhood>> watchNeighborhoodsForCampaign(
    String campaignId,
  ) {
    return _campaignNeighborhoods
        .where('campaign_id', isEqualTo: campaignId)
        .snapshots()
        .map((snap) => snap.docs.map(CampaignNeighborhood.fromFirestore).toList());
  }

  Future<Campaign?> getCampaign(String campaignId) async {
    final snap = await _campaigns.doc(campaignId).get();
    if (!snap.exists) return null;
    return Campaign.fromFirestore(snap);
  }

  Future<bool> campaignExists(String campaignId) async {
    final snap = await _campaigns.doc(campaignId).get();
    return snap.exists;
  }

  /// Chiến dịch đang bật — lọc `is_active` trên client để tránh composite index
  /// (`is_active` + `year`). Với số lượng chiến dịch nhỏ là đủ; production có thể
  /// deploy index trong `firestore.indexes.json` và dùng query server-side.
  Stream<List<Campaign>> watchActiveCampaigns() {
    return _campaigns.orderBy('year', descending: true).snapshots().map((snap) {
      return snap.docs
          .map(Campaign.fromFirestore)
          .where((c) => c.isActive)
          .toList();
    });
  }

  Future<bool> hasActivities(String campaignId) async {
    final snap = await _firestore
        .collection('activities')
        .where('campaign_id', isEqualTo: campaignId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<bool> hasMembers(String campaignId) async {
    final snap = await _firestore
        .collection('members')
        .where('campaign_id', isEqualTo: campaignId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> deleteCampaign(String campaignId) async {
    final assignments = await _campaignNeighborhoods
        .where('campaign_id', isEqualTo: campaignId)
        .get();

    final batch = _firestore.batch();
    for (final doc in assignments.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_campaigns.doc(campaignId));
    await batch.commit();
  }

  Future<void> createCampaign({
    required Campaign campaign,
  }) async {
    await _campaigns.doc(campaign.id).set(campaign.toFirestore(
          createdBy: campaign.createdBy,
        ));
  }

  Future<void> updateCampaign(Campaign campaign) async {
    await _campaigns.doc(campaign.id).update({
      'name': campaign.name,
      'year': campaign.year,
      'start_date': Timestamp.fromDate(campaign.startDate),
      'end_date': Timestamp.fromDate(campaign.endDate),
      'is_active': campaign.isActive,
    });
  }

  Future<void> setCampaignActive({
    required String campaignId,
    required bool isActive,
  }) async {
    await _campaigns.doc(campaignId).update({'is_active': isActive});
  }

  Future<void> assignNeighborhoodAdmin({
    required String campaignId,
    required String neighborhoodId,
    required String adminUid,
    required String adminName,
  }) async {
    final id = CampaignNeighborhood.composeId(
      campaignId: campaignId,
      neighborhoodId: neighborhoodId,
    );
    await _campaignNeighborhoods.doc(id).set({
      'campaign_id': campaignId,
      'neighborhood_id': neighborhoodId,
      'admin_uid': adminUid,
      'admin_name': adminName,
      'joined_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeNeighborhoodAssignment({
    required String campaignId,
    required String neighborhoodId,
  }) async {
    final id = CampaignNeighborhood.composeId(
      campaignId: campaignId,
      neighborhoodId: neighborhoodId,
    );
    await _campaignNeighborhoods.doc(id).delete();
  }

  List<Campaign> _applyFilter(List<Campaign> list, CampaignListFilter filter) {
    return switch (filter) {
      CampaignListFilter.all => list,
      CampaignListFilter.active =>
        list.where((c) => c.isActive).toList(),
      CampaignListFilter.inactive =>
        list.where((c) => !c.isActive).toList(),
      CampaignListFilter.running =>
        list.where((c) => c.isRunning).toList(),
      CampaignListFilter.upcoming =>
        list.where((c) => c.isUpcoming).toList(),
      CampaignListFilter.ended => list.where((c) => c.isEnded).toList(),
    };
  }
}
