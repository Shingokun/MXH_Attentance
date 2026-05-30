import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../providers/auth_providers.dart';

class UnauthorizedScreen extends ConsumerWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gate = ref.watch(authGateStatusProvider);
    final isProvisioning = gate == AuthGateStatus.provisioning;
    final bootstrap = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Icon(
                isProvisioning ? Icons.hourglass_top : Icons.no_accounts,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                isProvisioning
                    ? AppStrings.provisioningTitle
                    : AppStrings.unauthorizedTitle,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isProvisioning
                    ? AppStrings.provisioningBody
                    : AppStrings.unauthorizedBody,
                textAlign: TextAlign.center,
              ),
              if (isProvisioning) ...[
                const SizedBox(height: 24),
                if (!bootstrap.isLoading) const CircularProgressIndicator(),
                if (bootstrap.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(),
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: bootstrap.isLoading
                      ? null
                      : () async {
                          final user =
                              ref.read(authRepositoryProvider).currentUser;
                          if (user != null) {
                            await ref
                                .read(authControllerProvider.notifier)
                                .ensureProfile(user);
                          }
                        },
                  child: const Text(AppStrings.retryCreateProfile),
                ),
              ],
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => ref
                    .read(authControllerProvider.notifier)
                    .signOut(),
                child: const Text(AppStrings.signOut),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
