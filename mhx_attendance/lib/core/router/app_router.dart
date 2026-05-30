import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/user_role.dart';
import '../../features/auth/domain/app_user.dart';
import '../../features/auth/presentation/auth_routes.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/account_locked_screen.dart';
import '../../features/auth/presentation/screens/auth_welcome_screen.dart';
import '../../features/auth/presentation/screens/email_login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/role_home_screens.dart';
import '../../features/auth/presentation/screens/unauthorized_screen.dart';
import '../../features/campaigns/presentation/campaign_routes.dart';
import '../../features/campaigns/presentation/providers/campaign_providers.dart';
import '../../features/campaigns/presentation/screens/campaign_create_screen.dart';
import '../../features/campaigns/presentation/screens/campaign_detail_screen.dart';
import '../../features/campaigns/presentation/screens/campaign_list_screen.dart';
import '../../features/campaigns/presentation/screens/campaign_select_screen.dart';
import '../../features/dashboard_super/presentation/screens/super_admin_dashboard_screen.dart';
import '../../features/dashboard_super/presentation/screens/super_admin_placeholder_screen.dart';
import '../../features/dashboard_super/presentation/super_admin_routes.dart';
import '../../features/dashboard_super/presentation/super_admin_shell.dart';
import '../../core/constants/app_strings.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(_routerRefreshProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AuthRoutes.login,
    refreshListenable: refresh,
    redirect: (context, state) => _redirect(ref, state),
    routes: [
      GoRoute(
        path: AuthRoutes.login,
        name: 'login',
        builder: (context, state) => const AuthWelcomeScreen(),
      ),
      GoRoute(
        path: AuthRoutes.loginEmail,
        name: 'loginEmail',
        builder: (context, state) => const EmailLoginScreen(),
      ),
      GoRoute(
        path: AuthRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AuthRoutes.locked,
        name: 'locked',
        builder: (context, state) => const AccountLockedScreen(),
      ),
      GoRoute(
        path: AuthRoutes.unauthorized,
        name: 'unauthorized',
        builder: (context, state) => const UnauthorizedScreen(),
      ),
      GoRoute(
        path: CampaignRoutes.select,
        name: 'campaignSelect',
        builder: (context, state) => const CampaignSelectScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            SuperAdminShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: SuperAdminRoutes.home,
                name: 'homeSuper',
                builder: (context, state) =>
                    const SuperAdminDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: CampaignRoutes.list,
                name: 'campaignList',
                builder: (context, state) => const CampaignListScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    name: 'campaignCreate',
                    builder: (context, state) =>
                        const CampaignCreateScreen(),
                  ),
                  GoRoute(
                    path: ':campaignId',
                    name: 'campaignDetail',
                    builder: (context, state) => CampaignDetailScreen(
                      campaignId: state.pathParameters['campaignId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: SuperAdminRoutes.neighborhoods,
                name: 'neighborhoods',
                builder: (context, state) => const SuperAdminPlaceholderScreen(
                  title: AppStrings.navNeighborhoods,
                  screenId: 'SCR-SA-02',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: SuperAdminRoutes.admins,
                name: 'admins',
                builder: (context, state) => const SuperAdminPlaceholderScreen(
                  title: AppStrings.navAdmins,
                  screenId: 'SCR-SA-03',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: SuperAdminRoutes.reports,
                name: 'reports',
                builder: (context, state) => const SuperAdminPlaceholderScreen(
                  title: AppStrings.navReports,
                  screenId: 'SCR-RPT-00',
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AuthRoutes.homeLocal,
        name: 'homeLocal',
        builder: (context, state) => const LocalAdminHomeScreen(),
      ),
      GoRoute(
        path: AuthRoutes.homeUser,
        name: 'homeUser',
        builder: (context, state) => const UserHomeScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text(state.error.toString())),
    ),
  );
});

final _routerRefreshProvider = Provider<_RouterRefresh>((ref) {
  final refresh = _RouterRefresh();
  ref.listen(authGateStatusProvider, (_, _) => refresh.notify());
  ref.listen(appUserProvider, (_, _) => refresh.notify());
  ref.listen(authStateChangesProvider, (_, _) => refresh.notify());
  ref.listen(authUidProvider, (_, _) => refresh.notify());
  ref.listen(activeCampaignsProvider, (_, _) => refresh.notify());
  ref.listen(selectedCampaignIdProvider, (_, _) => refresh.notify());
  ref.onDispose(refresh.dispose);
  return refresh;
});

class _RouterRefresh extends ChangeNotifier {
  void notify() => notifyListeners();
}

String? _redirect(Ref ref, GoRouterState state) {
  final gate = ref.read(authGateStatusProvider);
  final location = state.matchedLocation;

  const publicRoutes = AuthRoutes.publicRoutes;
  const authOnlyRoutes = {
    AuthRoutes.locked,
    AuthRoutes.unauthorized,
    AuthRoutes.homeLocal,
    AuthRoutes.homeUser,
  };

  switch (gate) {
    case AuthGateStatus.loading:
      if (ref.read(authStateChangesProvider).valueOrNull != null) {
        return AuthRoutes.unauthorized;
      }
      return null;

    case AuthGateStatus.unauthenticated:
      if (publicRoutes.contains(location)) return null;
      return AuthRoutes.login;

    case AuthGateStatus.provisioning:
    case AuthGateStatus.unauthorized:
      if (location == AuthRoutes.unauthorized) return null;
      return AuthRoutes.unauthorized;

    case AuthGateStatus.locked:
      if (location == AuthRoutes.locked) return null;
      return AuthRoutes.locked;

    case AuthGateStatus.ready:
      final firebaseUid = ref.read(authStateChangesProvider).valueOrNull?.uid;
      final appUser = ref.read(appUserProvider).valueOrNull;
      if (appUser == null ||
          firebaseUid == null ||
          appUser.uid != firebaseUid) {
        return AuthRoutes.unauthorized;
      }

      final home = appUser.role.homePath;
      if (publicRoutes.contains(location) ||
          location == AuthRoutes.locked ||
          location == AuthRoutes.unauthorized) {
        return home;
      }
      if (_isWrongHome(location, appUser)) return home;

      if (SuperAdminRoutes.isSuperAdminArea(location)) {
        if (appUser.role != UserRole.superAdmin) return home;
        if (location == CampaignRoutes.select) return null;
        final redirect = _superAdminCampaignRedirect(ref, location);
        if (redirect != null) return redirect;
        return null;
      }

      if (authOnlyRoutes.contains(location)) return null;
      if (location == SuperAdminRoutes.home) return null;
      return home;
  }
}

bool _isWrongHome(String location, AppUser user) {
  return switch (user.role) {
    UserRole.superAdmin =>
      location == AuthRoutes.homeLocal || location == AuthRoutes.homeUser,
    UserRole.localAdmin =>
      location == AuthRoutes.homeSuper ||
          location == AuthRoutes.homeUser ||
          SuperAdminRoutes.isSuperAdminArea(location),
    UserRole.user =>
      location == AuthRoutes.homeSuper ||
          location == AuthRoutes.homeLocal ||
          SuperAdminRoutes.isSuperAdminArea(location),
  };
}

String? _superAdminCampaignRedirect(Ref ref, String location) {
  final activeAsync = ref.read(activeCampaignsProvider);
  if (activeAsync.isLoading) return null;

  final active = activeAsync.valueOrNull ?? [];
  final selected = ref.read(selectedCampaignIdProvider);

  if (active.length > 1 && selected == null) {
    if (location == CampaignRoutes.select) return null;
    if (location == SuperAdminRoutes.home) return CampaignRoutes.select;
  }

  if (location == CampaignRoutes.select && active.length <= 1) {
    return SuperAdminRoutes.home;
  }

  return null;
}
