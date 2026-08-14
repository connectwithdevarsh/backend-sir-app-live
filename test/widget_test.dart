import 'package:flutter_test/flutter_test.dart';
import 'package:sir/main.dart';

void main() {
  testWidgets('AipeLabApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AipeLabApp());

    // Verify that AIPE LAB title appears on splash screen.
    expect(find.text('AIPE LAB'), findsWidgets);
  });
}
