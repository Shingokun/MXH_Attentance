import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../campaigns/presentation/campaign_routes.dart';
import '../../../../core/constants/app_layout.dart';
import '../super_admin_routes.dart';

/// `SCR-SA-00` — Trang chủ Ban chỉ huy (dashboard).
class SuperAdminDashboardScreen extends ConsumerWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.homeSuperAdmin)),
      body: ListView(
        padding: AppLayout.contentPadding,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl!)
                        : null,
                    child: user?.photoUrl == null
                        ? const Icon(Icons.person, size: 32)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? '',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        const Chip(
                          label: Text('SUPER_ADMIN'),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.superAdminDashboardStatsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Expanded(
                child: _StatPlaceholder(
                  label: AppStrings.superAdminStatMembers,
                  value: '—',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatPlaceholder(
                  label: AppStrings.superAdminStatActivities,
                  value: '—',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.superAdminQuickNavTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _NavTile(
            icon: Icons.campaign_outlined,
            label: AppStrings.navCampaigns,
            onTap: () => context.go(CampaignRoutes.list),
          ),
          _NavTile(
            icon: Icons.location_city_outlined,
            label: AppStrings.navNeighborhoods,
            onTap: () => context.go(SuperAdminRoutes.neighborhoods),
          ),
          _NavTile(
            icon: Icons.admin_panel_settings_outlined,
            label: AppStrings.navAdmins,
            onTap: () => context.go(SuperAdminRoutes.admins),
          ),
          _NavTile(
            icon: Icons.bar_chart_outlined,
            label: AppStrings.navReports,
            onTap: () => context.go(SuperAdminRoutes.reports),
          ),
        ],
      ),
    );
  }
}

class _StatPlaceholder extends StatelessWidget {
  const _StatPlaceholder({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
