import 'package:flutter_test/flutter_test.dart';

import 'package:she_flow/main.dart';

void main() {
  testWidgets('SheFlow app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SheFlowApp());
    // Verify splash screen loads
    expect(find.text('She'), findsOneWidget);
    expect(find.text('Flow'), findsOneWidget);
  });
}
