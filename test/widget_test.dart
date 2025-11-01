import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:K_Skill/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyKSkillApp());
    await tester.pump();

    expect(find.text('K - Skill'), findsOneWidget);
    expect(find.text('Master English with confidence'), findsOneWidget);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Splash navigates to welcome when not logged in', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'isLoggedIn': false});

    await tester.pumpWidget(const MyKSkillApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.text('Welcome to K-Skill!'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('Splash navigates to dashboard when logged in', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'isLoggedIn': true});

    await tester.pumpWidget(const MyKSkillApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));
    expect(find.text('Welcome to K-Skill!'), findsNothing);
  });

  testWidgets('Welcome page has login and signup buttons', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'isLoggedIn': false});

    await tester.pumpWidget(const MyKSkillApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Sign Up'), findsOneWidget);
  });
}
