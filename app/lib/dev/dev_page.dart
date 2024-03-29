import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:totem/dev/tests/index.dart';
import 'package:totem/theme/index.dart';
import 'package:totem/app_routes.dart';

import '../components/widgets/content_divider.dart';
import 'buttons.dart';
import 'circle_session_test.dart';
import 'layouts.dart';

final widgetList = <String, Function>{
  "Waiting Room Layout": WaitingRoomDevLayout.new,
  "Listen Live Layout": ListenLiveLayoutTest.new,
  "Circle Session": ActiveSessionLayoutTest.new,
  "Onboarding Dialog": OnboardingDialogTest.new,
  "Circle User Profile": CircleUserProfileTest.new,
  "Onboarding Profile Dialog": OnboardingProfilePageTest.new,
  "Countdown Timer": CountdownTimerTest.new,
  "Audio Level": AudioLevelTest.new,
  "Buttons": ButtonsScreen.new
};

class DevPage extends StatefulWidget {
  const DevPage({super.key});

  @override
  State<DevPage> createState() => _DevPageState();
}

class _DevPageState extends State<DevPage> {
  String? displayWidget;
  final stateKey = "dev/currentwidget";
  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    Widget widget = WidgetList(changeWidget);
    if (displayWidget != null && widgetList.containsKey(displayWidget)) {
      widget =
          WidgetContainer(child: widgetList[displayWidget!]!(), reset: reset);
    }
    return Scaffold(
        backgroundColor: themeColors.dialogBackground, body: widget);
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(stateKey)) {
      setState(() {
        displayWidget = prefs.getString(stateKey);
      });
    }
  }

  void changeWidget(String widget) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(stateKey, widget);
    setState(() {
      displayWidget = widget;
    });
  }

  void reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(stateKey);
    setState(() {
      displayWidget = null;
    });
  }
}

class WidgetContainer extends StatelessWidget {
  const WidgetContainer({super.key, required this.child, required this.reset});
  final Function reset;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          right: 0,
          top: 30,
          child: IconButton(
            icon: const Icon(
              LucideIcons.x,
              shadows: <Shadow>[Shadow(color: Colors.white, blurRadius: 3.0)],
            ),
            onPressed: () {
              reset();
            },
          ),
        ),
      ],
    );
  }
}

class WidgetList extends StatelessWidget {
  const WidgetList(this.changeWidget, {super.key});
  final Function(String) changeWidget;
  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    var children = widgetList.keys.map((key) {
      return ListTile(
        title: Text(key),
        onTap: () {
          changeWidget(key);
        },
      );
    }).toList();
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const SizedBox(height: 30),
          Text("Dev Page!", style: textStyles.displayLarge),
          const Center(
            child: ContentDivider(),
          ),
          const Padding(padding: EdgeInsets.only(top: 20)),
          Column(
            children: children,
          ),
          TextButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.pushReplacementNamed(AppRoutes.home);
                }
              },
              child: const Text('Home'))
        ]));
  }
}
