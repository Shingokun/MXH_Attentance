import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_layout.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/campaign.dart';
import '../../domain/campaign_list_filter.dart';
import '../campaign_routes.dart';
import '../providers/campaign_providers.dart';

class CampaignListScreen extends ConsumerWidget {
  const CampaignListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(campaignsStreamProvider);
    final filter = ref.watch(campaignListFilterProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.campaignListTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(CampaignRoutes.create),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.campaignCreate),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.gutter,
                vertical: 8,
              ),
              children: CampaignListFilter.values.map((f) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f.label),
                    selected: filter == f,
                    onSelected: (_) =>
                        ref.read(campaignListFilterProvider.notifier).state = f,
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: campaignsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (campaigns) {
                if (campaigns.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        AppStrings.campaignListEmpty,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: AppLayout.listPadding,
                  itemCount: campaigns.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final campaign = campaigns[index];
                    return _CampaignTile(
                      campaign: campaign,
                      onTap: () {
                        ref.read(selectedCampaignIdProvider.notifier).state =
                            campaign.id;
                        context.push(CampaignRoutes.detail(campaign.id));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CampaignTile extends StatelessWidget {
  const _CampaignTile({
    required this.campaign,
    required this.onTap,
  });

  final Campaign campaign;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = _statusLabel(campaign);
    final statusColor = _statusColor(campaign);

    return ListTile(
      onTap: onTap,
      title: Text(campaign.name),
      subtitle: Text(
        '${campaign.id} · ${_formatDate(campaign.startDate)}'
        ' – ${_formatDate(campaign.endDate)}',
      ),
      trailing: Chip(
        label: Text(status, style: const TextStyle(fontSize: 12)),
        backgroundColor: statusColor.withValues(alpha: 0.15),
        side: BorderSide.none,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  String _statusLabel(Campaign c) {
    if (!c.isActive) return AppStrings.campaignStatusInactive;
    if (c.isUpcoming) return AppStrings.campaignStatusUpcoming;
    if (c.isEnded) return AppStrings.campaignStatusEnded;
    if (c.isRunning) return AppStrings.campaignStatusRunning;
    return AppStrings.campaignStatusActive;
  }

  Color _statusColor(Campaign c) {
    if (!c.isActive) return Colors.grey;
    if (c.isUpcoming) return Colors.orange;
    if (c.isEnded) return Colors.blueGrey;
    if (c.isRunning) return Colors.green;
    return Colors.blue;
  }

  static String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }
}
