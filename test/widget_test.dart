// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cureconnect_app/main.dart';

void main() {
  testWidgets('App Renders Correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CureConnectApp()); // Use CureConnectApp here

    // Verify that the home screen is displayed.
    expect(find.byType(AuthWrapper), findsOneWidget); // We are using the AuthWrapper to check if the app is starting correctly.
  });
}