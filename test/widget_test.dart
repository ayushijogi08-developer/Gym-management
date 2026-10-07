import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/main.dart';
import 'package:gym_management_app/providers/auth_provider.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    final authProvider = AuthProvider();
    await tester.pumpWidget(GymApp(authProvider: authProvider));
    expect(find.byType(GymApp), findsOneWidget);
  });
}
