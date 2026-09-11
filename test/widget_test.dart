import 'package:phintar/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App smoke test - starts on login page when not authenticated', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // Verify that the title 'Phintar' is present on the login screen
    expect(find.text('Phintar'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}
