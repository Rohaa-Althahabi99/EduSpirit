import 'package:flutter_test/flutter_test.dart';
import 'package:eduspirit/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const EduSpiritApp());
    // Just verifies the widget tree builds — a full smoke test.
    // Deeper tests (login flow, navigation) can be added later.
  });
}