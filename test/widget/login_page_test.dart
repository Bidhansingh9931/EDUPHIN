import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eduphin/login_logout/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('LoginPage UI Elements Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(
      home: LoginPage(),
    ));

    // Verify that Welcome Back text is shown
    expect(find.text('Welcome Back!'), findsOneWidget);
    
    // Verify text fields are present
    expect(find.byType(TextField), findsNWidgets(2));
    
    // Verify Login button is present
    expect(find.text('LOGIN'), findsOneWidget);
    
    // Verify Remember me checkbox
    expect(find.text('Remember me'), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);
  });

  testWidgets('LoginPage validation error should be empty initially', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: LoginPage(),
    ));

    // Error text should not be visible initially if it's dependent on _error.isNotEmpty
    // In our code: if (_error.isNotEmpty) ...
    // So we just check if any common error message is NOT there.
    expect(find.textContaining('Login failed'), findsNothing);
  });

  testWidgets('Toggling password visibility', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: LoginPage(),
    ));

    final passwordField = find.byType(TextField).last;
    TextField widget = tester.widget<TextField>(passwordField);
    expect(widget.obscureText, isTrue);

    // Find suffix icon button and tap it
    // In UiHelper.customTextField, suffixIcon is likely an IconButton
    final visibilityIcon = find.byIcon(Icons.visibility_off_outlined);
    expect(visibilityIcon, findsOneWidget);
    
    await tester.tap(visibilityIcon);
    await tester.pump();

    widget = tester.widget<TextField>(passwordField);
    expect(widget.obscureText, isFalse);
  });
}
