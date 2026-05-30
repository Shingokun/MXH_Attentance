import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_exception_mapper.dart';
import '../providers/auth_providers.dart';

/// Hiển thị SnackBar khi [authControllerProvider] lỗi.
class AuthErrorListener extends ConsumerWidget {
  const AuthErrorListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authControllerProvider, (prev, next) {
      if (next.hasError && next.error != null) {
        final message = mapFirebaseAuthError(next.error!);
        if (message.contains('huỷ') || message.contains('cancel')) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });
    return child;
  }
}
