// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:totem/components/Header.dart';

class WidgetTestHarness extends StatelessWidget {
  const WidgetTestHarness({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(body: child),
    );
  }
}

void main() {
  testWidgets('Test header widget shows text', (WidgetTester tester) async {
    await tester
        .pumpWidget(WidgetTestHarness(child: TotemHeader(text: 'Welcome')));
    // Verify text
    expect(find.text('Welcome'), findsOneWidget);
  });
}
