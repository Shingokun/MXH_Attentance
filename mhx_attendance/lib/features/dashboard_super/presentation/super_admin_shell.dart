import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../campaigns/presentation/campaign_routes.dart';
import '../../campaigns/presentation/providers/campaign_providers.dart';
/// Shell Super Admin: `NavigationRail` + vùng nội dung (`SCR-SA-*`).
class SuperAdminShell extends ConsumerWidget {
  const SuperAdminShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    (
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: AppStrings.navHome,
    ),
    (
      icon: Icons.campaign_outlined,
      selectedIcon: Icons.campaign,
      label: AppStrings.navCampaigns,
    ),
    (
      icon: Icons.location_city_outlined,
      selectedIcon: Icons.location_city,
      label: AppStrings.navNeighborhoods,
    ),
    (
      icon: Icons.admin_panel_settings_outlined,
      selectedIcon: Icons.admin_panel_settings,
      label: AppStrings.navAdmins,
    ),
    (
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
      label: AppStrings.navReports,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCampaignProvider);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: navigationShell.goBranch,
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Icon(
                Icons.eco_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: IconButton(
                    tooltip: AppStrings.signOut,
                    onPressed: () =>
                        ref.read(authControllerProvider.notifier).signOut(),
                    icon: const Icon(Icons.logout),
                  ),
                ),
              ),
            ),
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: Text(d.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.appName,
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              if (selected != null)
                                Text(
                                  '${AppStrings.selectedCampaignLabel}: '
                                  '${selected.name}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                )
                              else
                                Text(
                                  AppStrings.superAdminNoCampaignSelected,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ref
                                .read(selectedCampaignIdProvider.notifier)
                                .state = null;
                            context.go(CampaignRoutes.select);
                          },
                          child: const Text(AppStrings.changeCampaign),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: navigationShell),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
