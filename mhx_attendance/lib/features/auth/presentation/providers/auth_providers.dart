import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/firebase_providers.dart';
import '../../data/auth_repository.dart';
import '../../data/user_repository.dart';
import '../../domain/app_user.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(firebaseAuth: ref.watch(firebaseAuthProvider)),
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(firestore: ref.watch(firestoreProvider)),
);

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final authUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateChangesProvider).valueOrNull?.uid;
});

final appUserProvider = StreamProvider<AppUser?>((ref) {
  final uid = ref.watch(authUidProvider);
  if (uid == null) {
    return Stream.value(null);
  }
  return ref.watch(userRepositoryProvider).watchUser(uid);
});

enum AuthGateStatus {
  loading,
  unauthenticated,
  provisioning,
  locked,
  unauthorized,
  ready,
}

final authGateStatusProvider = Provider<AuthGateStatus>((ref) {
  final auth = ref.watch(authStateChangesProvider);
  if (auth.isLoading) return AuthGateStatus.loading;

  final firebaseUser = auth.valueOrNull;
  if (firebaseUser == null) return AuthGateStatus.unauthenticated;

  final profile = ref.watch(appUserProvider);

  if (profile.isLoading || profile.isRefreshing) {
    return AuthGateStatus.provisioning;
  }

  final appUser = profile.valueOrNull;
  if (appUser == null) return AuthGateStatus.provisioning;

  if (appUser.uid != firebaseUser.uid) {
    return AuthGateStatus.provisioning;
  }

  if (!appUser.isActive) return AuthGateStatus.locked;

  if (appUser.isLocalAdminUnprovisioned) {
    return AuthGateStatus.unauthorized;
  }

  return AuthGateStatus.ready;
});

final profileBootstrapProvider = Provider<void>((ref) {
  ref.listen(authUidProvider, (previous, next) {
    if (next == null || next == previous) return;
    final user = ref.read(authStateChangesProvider).valueOrNull;
    if (user != null && user.uid == next) {
      unawaited(ref.read(authControllerProvider.notifier).ensureProfile(user));
    }
  });
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  void _clearSessionCache() {
    ref.invalidate(appUserProvider);
  }

  Future<void> _afterAuth(User? user) async {
    if (user != null) {
      await ensureProfile(user);
    }
  }

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _clearSessionCache();
      final cred = await ref.read(authRepositoryProvider).signInWithEmailPassword(
            email: email,
            password: password,
          );
      await _afterAuth(cred.user);
    });
  }

  Future<void> registerWithEmailPassword({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _clearSessionCache();
      final cred =
          await ref.read(authRepositoryProvider).registerWithEmailPassword(
                email: email,
                password: password,
                fullName: fullName,
              );
      await _afterAuth(cred.user ?? ref.read(authRepositoryProvider).currentUser);
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _clearSessionCache();
      final cred = await ref.read(authRepositoryProvider).signInWithGoogle();
      await _afterAuth(cred.user);
    });
  }

  Future<void> ensureProfile(User firebaseUser) async {
    try {
      await ref.read(userRepositoryProvider).ensureInitialProfile(firebaseUser);
      await ref.read(authRepositoryProvider).refreshIdToken();
    } catch (e, st) {
      assert(() {
        // ignore: avoid_print
        print('ensureProfile failed: $e\n$st');
        return true;
      }());
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signOut();
      _clearSessionCache();
    });
  }
}
