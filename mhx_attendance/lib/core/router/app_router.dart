import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/app_user.dart';
import '../../features/auth/presentation/auth_routes.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/account_locked_screen.dart';
import '../../features/auth/presentation/screens/auth_welcome_screen.dart';
import '../../features/auth/presentation/screens/email_login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/role_home_screens.dart';
import '../../features/auth/presentation/screens/unauthorized_screen.dart';

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
        path: AuthRoutes.homeSuper,
        name: 'homeSuper',
        builder: (context, state) => const SuperAdminHomeScreen(),
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
    AuthRoutes.homeSuper,
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
      if (authOnlyRoutes.contains(location)) return null;
      return home;
  }
}

bool _isWrongHome(String location, AppUser user) {
  final expected = user.role.homePath;
  if (location == AuthRoutes.homeSuper ||
      location == AuthRoutes.homeLocal ||
      location == AuthRoutes.homeUser) {
    return location != expected;
  }
  return false;
}
