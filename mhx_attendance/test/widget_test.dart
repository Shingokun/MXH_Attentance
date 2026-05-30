import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mhx_attendance/app.dart';
import 'package:mhx_attendance/features/auth/presentation/providers/auth_providers.dart';

void main() {
  testWidgets('Auth welcome shows login and register', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateChangesProvider.overrideWith(
            (ref) => Stream.value(null),
          ),
          authGateStatusProvider.overrideWith(
            (ref) => AuthGateStatus.unauthenticated,
          ),
        ],
        child: const MhxApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('MHX Attendance'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.text('Đăng ký'), findsOneWidget);
  });
}
