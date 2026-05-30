import 'package:flutter/material.dart';

import '../../../../core/constants/app_layout.dart';
import '../../../../core/constants/app_strings.dart';

/// Màn placeholder cho các mục shell chưa implement (GĐ3+).
class SuperAdminPlaceholderScreen extends StatelessWidget {
  const SuperAdminPlaceholderScreen({
    super.key,
    required this.title,
    this.screenId,
  });

  final String title;
  final String? screenId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: AppLayout.messagePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction_outlined,
                size: 56,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (screenId != null) ...[
                const SizedBox(height: 8),
                Text(
                  screenId!,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
              const SizedBox(height: 16),
              Text(
                AppStrings.superAdminComingSoon,
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
