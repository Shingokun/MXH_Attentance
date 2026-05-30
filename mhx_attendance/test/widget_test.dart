import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mhx_attendance/app.dart';

void main() {
  testWidgets('Home placeholder is shown', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MhxApp()));
    await tester.pumpAndSettle();

    expect(find.text('MHX Attendance'), findsOneWidget);
    expect(find.textContaining('Giai đoạn 1'), findsOneWidget);
  });
}
