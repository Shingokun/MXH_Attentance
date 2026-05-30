import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../campaign_routes.dart';
import '../../../auth/domain/app_user.dart';
import '../../domain/campaign.dart';
import '../../domain/campaign_neighborhood.dart';
import '../../domain/neighborhood.dart';
import '../providers/campaign_providers.dart';
import '../widgets/campaign_form_fields.dart';

class CampaignDetailScreen extends ConsumerStatefulWidget {
  const CampaignDetailScreen({super.key, required this.campaignId});

  final String campaignId;

  @override
  ConsumerState<CampaignDetailScreen> createState() =>
      _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends ConsumerState<CampaignDetailScreen> {
  bool _editing = false;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  TextEditingController? _yearController;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController?.dispose();
    super.dispose();
  }

  void _syncForm(Campaign campaign) {
    _nameController.text = campaign.name;
    _startDate = campaign.startDate;
    _endDate = campaign.endDate;
  }

  Future<void> _saveEdit(Campaign campaign) async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      _snack(AppStrings.campaignDatesRequired);
      return;
    }
    try {
      await ref.read(campaignControllerProvider.notifier).updateCampaign(
            campaign: campaign,
            name: _nameController.text,
            startDate: _startDate!,
            endDate: _endDate!,
          );
      if (!mounted) return;
      _yearController?.dispose();
      _yearController = null;
      setState(() => _editing = false);
      _snack(AppStrings.campaignUpdated);
    } catch (e) {
      if (!mounted) return;
      _snack(e.toString());
    }
  }

  Future<void> _toggleActive(Campaign campaign, bool value) async {
    try {
      await ref.read(campaignControllerProvider.notifier).setCampaignActive(
            campaignId: campaign.id,
            isActive: value,
          );
      if (!mounted) return;
      _snack(value ? AppStrings.campaignActivated : AppStrings.campaignDeactivated);
    } catch (e) {
      if (!mounted) return;
      _snack(e.toString());
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showAssignDialog(Campaign campaign) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _AssignAdminDialog(campaignId: campaign.id),
    );
  }

  Future<void> _confirmDelete(Campaign campaign) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.campaignDeleteTitle),
        content: Text(AppStrings.campaignDeleteBody(campaign.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AppStrings.campaignDelete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    try {
      await ref
          .read(campaignControllerProvider.notifier)
          .deleteCampaign(campaign.id);
      if (!mounted) return;
      _snack(AppStrings.campaignDeleted);
      context.go(CampaignRoutes.list);
    } catch (e) {
      if (!mounted) return;
      _snack(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final campaignAsync = ref.watch(campaignProvider(widget.campaignId));
    final hasActivitiesAsync =
        ref.watch(campaignHasActivitiesProvider(widget.campaignId));
    final canDeleteAsync =
        ref.watch(campaignCanDeleteProvider(widget.campaignId));
    final assignmentsAsync =
        ref.watch(campaignNeighborhoodsProvider(widget.campaignId));
    final isSaving = ref.watch(campaignControllerProvider).isLoading;

    return campaignAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('$e')),
      ),
      data: (campaign) {
        if (campaign == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text(AppStrings.campaignNotFound)),
          );
        }

        if (_nameController.text.isEmpty && !_editing) {
          _syncForm(campaign);
        }

        final hasActivities = hasActivitiesAsync.valueOrNull ?? false;
        final canDelete = canDeleteAsync.valueOrNull ?? false;
        final canEdit = !hasActivities && !isSaving;

        return Scaffold(
          appBar: AppBar(
            title: Text(campaign.name),
            actions: [
              if (!_editing && canDelete)
                IconButton(
                  tooltip: AppStrings.campaignDelete,
                  onPressed: isSaving ? null : () => _confirmDelete(campaign),
                  icon: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              if (!_editing && canEdit)
                IconButton(
                  tooltip: AppStrings.campaignEdit,
                  onPressed: () {
                    _syncForm(campaign);
                    _yearController?.dispose();
                    _yearController =
                        TextEditingController(text: campaign.year.toString());
                    setState(() => _editing = true);
                  },
                  icon: const Icon(Icons.edit),
                ),
              if (_editing)
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          _yearController?.dispose();
                          _yearController = null;
                          setState(() => _editing = false);
                        },
                  child: const Text(AppStrings.cancel),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (hasActivities)
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(AppStrings.campaignEditBlocked),
                  ),
                ),
              if (!canDelete && !hasActivities)
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(AppStrings.campaignDeleteBlockedHint),
                  ),
                ),
              if (_editing)
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CampaignFormFields(
                        nameController: _nameController,
                        yearController: _yearController!,
                        startDate: _startDate,
                        endDate: _endDate,
                        lockYear: true,
                        onPickStartDate: () async {
                          final picked = await pickCampaignDate(
                            context,
                            initial: _startDate,
                          );
                          if (picked != null) setState(() => _startDate = picked);
                        },
                        onPickEndDate: () async {
                          final picked = await pickCampaignDate(
                            context,
                            initial: _endDate ?? _startDate,
                            firstDate: _startDate,
                          );
                          if (picked != null) setState(() => _endDate = picked);
                        },
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: isSaving ? null : () => _saveEdit(campaign),
                        child: const Text(AppStrings.campaignSave),
                      ),
                    ],
                  ),
                )
              else
                _CampaignInfoCard(campaign: campaign),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text(AppStrings.campaignActiveLabel),
                subtitle: Text(
                  campaign.isActive
                      ? AppStrings.campaignActiveHint
                      : AppStrings.campaignInactiveHint,
                ),
                value: campaign.isActive,
                onChanged: isSaving
                    ? null
                    : (value) => _toggleActive(campaign, value),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    AppStrings.campaignNeighborhoodsTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    onPressed: isSaving ? null : () => _showAssignDialog(campaign),
                    icon: const Icon(Icons.person_add),
                    label: const Text(AppStrings.campaignAssignAdmin),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              assignmentsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('$e'),
                data: (items) {
                  if (items.isEmpty) {
                    return Text(AppStrings.campaignNoAssignments);
                  }
                  return Column(
                    children: items
                        .map(
                          (item) => _AssignmentTile(
                            item: item,
                            onRemove: isSaving
                                ? null
                                : () => _removeAssignment(campaign.id, item),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _removeAssignment(
    String campaignId,
    CampaignNeighborhood item,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.campaignRemoveAssignmentTitle),
        content: Text(
          AppStrings.campaignRemoveAssignmentBody(item.neighborhoodId),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AppStrings.campaignRemove),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    try {
      await ref.read(campaignControllerProvider.notifier).removeNeighborhoodAssignment(
            campaignId: campaignId,
            neighborhoodId: item.neighborhoodId,
          );
      if (!mounted) return;
      _snack(AppStrings.campaignAssignmentRemoved);
    } catch (e) {
      if (!mounted) return;
      _snack(e.toString());
    }
  }
}

class _CampaignInfoCard extends StatelessWidget {
  const _CampaignInfoCard({required this.campaign});

  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(campaign.id, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(campaign.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('${AppStrings.campaignYearLabel}: ${campaign.year}'),
            Text(
              '${AppStrings.campaignStartDateLabel}: ${_formatDate(campaign.startDate)}',
            ),
            Text(
              '${AppStrings.campaignEndDateLabel}: ${_formatDate(campaign.endDate)}',
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }
}

class _AssignmentTile extends StatelessWidget {
  const _AssignmentTile({required this.item, this.onRemove});

  final CampaignNeighborhood item;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(item.neighborhoodId),
        subtitle: Text(item.adminName),
        trailing: onRemove == null
            ? null
            : IconButton(
                tooltip: AppStrings.campaignRemove,
                onPressed: onRemove,
                icon: const Icon(Icons.close),
              ),
      ),
    );
  }
}

class _AssignAdminDialog extends ConsumerStatefulWidget {
  const _AssignAdminDialog({required this.campaignId});

  final String campaignId;

  @override
  ConsumerState<_AssignAdminDialog> createState() => _AssignAdminDialogState();
}

class _AssignAdminDialogState extends ConsumerState<_AssignAdminDialog> {
  Neighborhood? _neighborhood;
  AppUser? _admin;

  @override
  Widget build(BuildContext context) {
    final neighborhoodsAsync = ref.watch(neighborhoodsProvider);
    final adminsAsync = ref.watch(localAdminsProvider);
    final isSaving = ref.watch(campaignControllerProvider).isLoading;

    final dialogWidth =
        (MediaQuery.sizeOf(context).width * 0.9).clamp(280.0, 420.0);

    return AlertDialog(
      title: const Text(AppStrings.campaignAssignAdmin),
      content: SizedBox(
        width: dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            neighborhoodsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('$e'),
              data: (list) {
                if (list.isEmpty) {
                  return const Text(AppStrings.campaignNoNeighborhoods);
                }
                return DropdownButtonFormField<Neighborhood>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: AppStrings.campaignNeighborhoodLabel,
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _neighborhood,
                  items: list
                      .map(
                        (n) => DropdownMenuItem(
                          value: n,
                          child: Text(
                            n.displayLabel,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: isSaving ? null : (v) => setState(() => _neighborhood = v),
                );
              },
            ),
            const SizedBox(height: 16),
            adminsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('$e'),
              data: (list) {
                if (list.isEmpty) {
                  return const Text(AppStrings.campaignNoLocalAdmins);
                }
                return DropdownButtonFormField<AppUser>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: AppStrings.campaignLocalAdminLabel,
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _admin,
                  items: list
                      .map(
                        (u) => DropdownMenuItem(
                          value: u,
                          child: Text(
                            u.fullName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  selectedItemBuilder: (context) => list
                      .map(
                        (u) => Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            u.fullName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: isSaving ? null : (v) => setState(() => _admin = v),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving ? null : () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: isSaving || _neighborhood == null || _admin == null
              ? null
              : () async {
                  try {
                    await ref
                        .read(campaignControllerProvider.notifier)
                        .assignNeighborhoodAdmin(
                          campaignId: widget.campaignId,
                          neighborhoodId: _neighborhood!.id,
                          adminUid: _admin!.uid,
                          adminName: _admin!.fullName,
                        );
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(AppStrings.campaignAssigned)),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
          child: isSaving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(AppStrings.campaignAssign),
        ),
      ],
    );
  }
}
