import 'package:flutter_test/flutter_test.dart';

import 'package:carelog/main.dart';

void main() {
  testWidgets('CareLog boots and shows the brand placeholder',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CareLogApp());

    expect(find.text('CareLog'), findsOneWidget);
    expect(find.text('Your health, organised'), findsOneWidget);
  });
}
