import 'package:phintar/main.dart';
import 'package:phintar/models/preference_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App smoke test - starts on login page when not authenticated', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'isLogin': false});
    await PreferenceHandler.init();

    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // Verify that the title 'phintar' is present on the login screen
    expect(find.text('phintar'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}
