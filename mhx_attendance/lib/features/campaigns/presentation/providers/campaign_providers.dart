import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/firebase_providers.dart';
import '../../../auth/domain/app_user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/campaign_repository.dart';
import '../../data/neighborhood_repository.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/campaign.dart';
import '../../domain/campaign_list_filter.dart';
import '../../domain/campaign_neighborhood.dart';
import '../../domain/neighborhood.dart';

final campaignRepositoryProvider = Provider<CampaignRepository>(
  (ref) => CampaignRepository(firestore: ref.watch(firestoreProvider)),
);

final neighborhoodRepositoryProvider = Provider<NeighborhoodRepository>(
  (ref) => NeighborhoodRepository(firestore: ref.watch(firestoreProvider)),
);

final campaignListFilterProvider = StateProvider<CampaignListFilter>(
  (ref) => CampaignListFilter.all,
);

final campaignsStreamProvider = StreamProvider<List<Campaign>>((ref) {
  final filter = ref.watch(campaignListFilterProvider);
  return ref.watch(campaignRepositoryProvider).watchCampaigns(filter: filter);
});

final activeCampaignsProvider = StreamProvider<List<Campaign>>((ref) {
  return ref.watch(campaignRepositoryProvider).watchActiveCampaigns();
});

final selectedCampaignIdProvider = StateProvider<String?>((ref) => null);

final selectedCampaignProvider = Provider<Campaign?>((ref) {
  final id = ref.watch(selectedCampaignIdProvider);
  if (id == null) return null;
  final campaign = ref.watch(campaignProvider(id)).valueOrNull;
  if (campaign != null) return campaign;
  final campaigns = ref.watch(campaignsStreamProvider).valueOrNull;
  if (campaigns == null) return null;
  for (final c in campaigns) {
    if (c.id == id) return c;
  }
  return null;
});

final campaignProvider =
    StreamProvider.family<Campaign?, String>((ref, campaignId) {
  return ref.watch(campaignRepositoryProvider).watchCampaign(campaignId);
});

final campaignNeighborhoodsProvider =
    StreamProvider.family<List<CampaignNeighborhood>, String>((ref, campaignId) {
  return ref
      .watch(campaignRepositoryProvider)
      .watchNeighborhoodsForCampaign(campaignId);
});

final campaignHasActivitiesProvider =
    FutureProvider.family<bool, String>((ref, campaignId) {
  return ref.watch(campaignRepositoryProvider).hasActivities(campaignId);
});

final campaignHasMembersProvider =
    FutureProvider.family<bool, String>((ref, campaignId) {
  return ref.watch(campaignRepositoryProvider).hasMembers(campaignId);
});

final campaignCanDeleteProvider =
    FutureProvider.family<bool, String>((ref, campaignId) async {
  final repo = ref.watch(campaignRepositoryProvider);
  final hasActivities = await repo.hasActivities(campaignId);
  if (hasActivities) return false;
  final hasMembers = await repo.hasMembers(campaignId);
  return !hasMembers;
});

final localAdminsProvider = StreamProvider<List<AppUser>>((ref) {
  return ref.watch(userRepositoryProvider).watchLocalAdmins();
});

final neighborhoodsProvider = StreamProvider<List<Neighborhood>>((ref) {
  return ref.watch(neighborhoodRepositoryProvider).watchNeighborhoods();
});

/// Tự chọn chiến dịch nếu chỉ có một chiến dịch đang bật (`CAM-06`).
final campaignSessionBootstrapProvider = Provider<void>((ref) {
  ref.listen(activeCampaignsProvider, (previous, next) {
    final active = next.valueOrNull;
    if (active == null || active.length != 1) return;
    final selected = ref.read(selectedCampaignIdProvider);
    if (selected != null) return;
    ref.read(selectedCampaignIdProvider.notifier).state = active.first.id;
  });
});

final campaignControllerProvider =
    AsyncNotifierProvider<CampaignController, void>(CampaignController.new);

class CampaignController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  CampaignRepository get _repo => ref.read(campaignRepositoryProvider);

  Future<Campaign> createCampaign({
    required String code,
    required String name,
    required int year,
    required DateTime startDate,
    required DateTime endDate,
    bool isActive = true,
  }) async {
    state = const AsyncLoading();
    late Campaign created;
    state = await AsyncValue.guard(() async {
      final uid = ref.read(authUidProvider);
      if (uid == null) throw CampaignException('Chưa đăng nhập');

      final normalizedCode = Campaign.normalizeCode(code);
      if (normalizedCode == null) {
        throw CampaignException(AppStrings.campaignCodeInvalid);
      }

      final id = Campaign.composeId(code: normalizedCode, year: year);
      if (await _repo.campaignExists(id)) {
        throw CampaignException('Chiến dịch $id đã tồn tại');
      }
      if (!endDate.isAfter(startDate)) {
        throw CampaignException('Ngày kết thúc phải sau ngày bắt đầu');
      }

      created = Campaign(
        id: id,
        name: name.trim(),
        year: year,
        code: normalizedCode,
        startDate: startDate,
        endDate: endDate,
        isActive: isActive,
        createdBy: uid,
      );
      await _repo.createCampaign(campaign: created);
      ref.read(selectedCampaignIdProvider.notifier).state = id;
    });
    if (state.hasError) throw state.error!;
    return created;
  }

  Future<void> updateCampaign({
    required Campaign campaign,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (await _repo.hasActivities(campaign.id)) {
        throw CampaignException(
          'Không thể sửa chiến dịch đã có hoạt động',
        );
      }
      if (!endDate.isAfter(startDate)) {
        throw CampaignException('Ngày kết thúc phải sau ngày bắt đầu');
      }
      await _repo.updateCampaign(
        Campaign(
          id: campaign.id,
          name: name.trim(),
          year: campaign.year,
          code: campaign.code,
          startDate: startDate,
          endDate: endDate,
          isActive: campaign.isActive,
          createdBy: campaign.createdBy,
          createdAt: campaign.createdAt,
        ),
      );
    });
    if (state.hasError) throw state.error!;
  }

  Future<void> setCampaignActive({
    required String campaignId,
    required bool isActive,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.setCampaignActive(campaignId: campaignId, isActive: isActive);
      if (!isActive &&
          ref.read(selectedCampaignIdProvider) == campaignId) {
        ref.read(selectedCampaignIdProvider.notifier).state = null;
      }
    });
    if (state.hasError) throw state.error!;
  }

  Future<void> assignNeighborhoodAdmin({
    required String campaignId,
    required String neighborhoodId,
    required String adminUid,
    required String adminName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.assignNeighborhoodAdmin(
        campaignId: campaignId,
        neighborhoodId: neighborhoodId,
        adminUid: adminUid,
        adminName: adminName,
      );
    });
    if (state.hasError) throw state.error!;
  }

  Future<void> removeNeighborhoodAssignment({
    required String campaignId,
    required String neighborhoodId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.removeNeighborhoodAssignment(
        campaignId: campaignId,
        neighborhoodId: neighborhoodId,
      );
    });
    if (state.hasError) throw state.error!;
  }

  Future<void> deleteCampaign(String campaignId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (await _repo.hasActivities(campaignId)) {
        throw CampaignException(AppStrings.campaignDeleteBlockedActivities);
      }
      if (await _repo.hasMembers(campaignId)) {
        throw CampaignException(AppStrings.campaignDeleteBlockedMembers);
      }
      await _repo.deleteCampaign(campaignId);
      if (ref.read(selectedCampaignIdProvider) == campaignId) {
        ref.read(selectedCampaignIdProvider.notifier).state = null;
      }
    });
    if (state.hasError) throw state.error!;
  }
}

class CampaignException implements Exception {
  CampaignException(this.message);
  final String message;

  @override
  String toString() => message;
}
