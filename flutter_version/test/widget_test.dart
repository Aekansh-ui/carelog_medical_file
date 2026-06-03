import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:carelog/app.dart';

void main() {
  testWidgets('CareLog boots and shows bottom nav', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CareLogApp()));
    await tester.pumpAndSettle();

    expect(find.text('Family'), findsOneWidget);
  });
}
