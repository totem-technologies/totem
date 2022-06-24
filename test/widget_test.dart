import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totem/app.dart';

import 'package:totem/components/widgets/headers.dart';

class WidgetTestHarness extends StatelessWidget {
  const WidgetTestHarness({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(body: child),
      theme: appTheme(context),
    );
  }
}

void main() {
  testWidgets('Test header widget shows text', (WidgetTester tester) async {
    await tester.pumpWidget(
        const WidgetTestHarness(child: TotemHeader(text: 'Welcome')));
    // Verify text
    expect(find.text('Welcome'), findsOneWidget);
  });
}
