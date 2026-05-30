import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/user_role.dart';
import '../providers/auth_providers.dart';

class LocalAdminHomeScreen extends ConsumerWidget {
  const LocalAdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appUserProvider).valueOrNull;
    return _RoleHomeScaffold(
      title: AppStrings.homeLocalAdmin,
      role: UserRole.localAdmin,
      color: Colors.green.shade700,
      subtitle: user?.neighborhoodName,
    );
  }
}

class UserHomeScreen extends ConsumerWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _RoleHomeScaffold(
      title: AppStrings.homeUser,
      role: UserRole.user,
      color: Colors.blue.shade700,
    );
  }
}

class _RoleHomeScaffold extends ConsumerWidget {
  const _RoleHomeScaffold({
    required this.title,
    required this.role,
    required this.color,
    this.subtitle,
  });

  final String title;
  final UserRole role;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: AppStrings.signOut,
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: color.withValues(alpha: 0.15),
                backgroundImage:
                    user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                child: user?.photoUrl == null
                    ? Icon(Icons.person, size: 40, color: color)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                user?.fullName ?? '',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(subtitle!, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 8),
              Chip(
                label: Text(role.firestoreValue),
                backgroundColor: color.withValues(alpha: 0.12),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.roleHomePlaceholder,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
