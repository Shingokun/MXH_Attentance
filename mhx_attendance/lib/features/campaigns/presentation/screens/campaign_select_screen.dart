import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_layout.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../dashboard_super/presentation/super_admin_routes.dart';
import '../../domain/campaign.dart';
import '../providers/campaign_providers.dart';

/// Chọn chiến dịch khi có nhiều chiến dịch đang bật (`CAM-06`).
class CampaignSelectScreen extends ConsumerWidget {
  const CampaignSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(activeCampaignsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.campaignSelectTitle)),
      body: activeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: AppLayout.messagePadding,
            child: Text(
              e.toString().contains('index')
                  ? AppStrings.firestoreIndexRequired
                  : '$e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (campaigns) {
          if (campaigns.isEmpty) {
            return Center(
              child: Padding(
                padding: AppLayout.messagePadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.campaignSelectEmpty,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => context.go(SuperAdminRoutes.home),
                      child: const Text(AppStrings.continueWithoutCampaign),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: AppLayout.contentPadding,
            itemCount: campaigns.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final campaign = campaigns[index];
              return _CampaignSelectTile(
                campaign: campaign,
                onTap: () => _select(context, ref, campaign),
              );
            },
          );
        },
      ),
    );
  }

  void _select(BuildContext context, WidgetRef ref, Campaign campaign) {
    ref.read(selectedCampaignIdProvider.notifier).state = campaign.id;
    context.go(SuperAdminRoutes.home);
  }
}

class _CampaignSelectTile extends StatelessWidget {
  const _CampaignSelectTile({required this.campaign, required this.onTap});

  final Campaign campaign;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(campaign.year.toString().substring(2)),
      ),
      title: Text(campaign.name),
      subtitle: Text(
        '${campaign.id} · ${_formatDate(campaign.startDate)}'
        ' – ${_formatDate(campaign.endDate)}',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  static String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }
}
