// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gratitude_garden_app/pages/auth_page.dart';

void main() {
  testWidgets('Auth screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: AuthPage(),
      ),
    );

    // Verify that our app header logo (SVG) and slogan are present.
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.text('Grow your forest of thankfulness.'), findsOneWidget);

    // Verify that Login and Register toggle tabs are present.
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);

    // Verify that Social Sign-in buttons are present.
    expect(find.text('or continue with'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
  });
}
