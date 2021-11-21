// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:totem/components/widgets/headers.dart';
import 'package:totem/main.dart';

class WidgetTestHarness extends StatelessWidget {
  const WidgetTestHarness({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
      ],
      debugShowCheckedModeBanner: false,
      title: 'Flutter Test',
      home: Scaffold(body: child),
      theme: appTheme(context),
    );
  }
}

void main() {
  testWidgets('Test header widget shows text', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(
        child: WidgetTestHarness(child: TotemHeader(text: 'Welcome'))));
    // Verify text
    expect(find.text('Welcome'), findsOneWidget);
  });
}
