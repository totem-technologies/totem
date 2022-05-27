import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:totem/theme/index.dart';

import '../components/widgets/content_divider.dart';
import 'layouts.dart';
import 'buttons.dart';

final widgetList = <String, Function>{
  "Circle Layout": CircleLayout.new,
  "Buttons": ButtonsScreen.new
};

class DevPage extends StatefulWidget {
  const DevPage({Key? key}) : super(key: key);

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
    if (displayWidget != null) {
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

  _init() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(stateKey)) {
      setState(() {
        displayWidget = prefs.getString(stateKey);
      });
    }
  }

  changeWidget(String widget) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(stateKey, widget);
    setState(() {
      displayWidget = widget;
    });
  }

  reset() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(stateKey);
    setState(() {
      displayWidget = null;
    });
  }
}

class WidgetContainer extends StatelessWidget {
  const WidgetContainer({Key? key, required this.child, required this.reset})
      : super(key: key);
  final Function reset;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          right: 0,
          top: 0,
          child: IconButton(
            icon: const Icon(Icons.close),
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
  const WidgetList(this.changeWidget, {Key? key}) : super(key: key);
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
          Text("Dev Page!", style: textStyles.headline1),
          const Center(
            child: ContentDivider(),
          ),
          const Padding(padding: EdgeInsets.only(top: 20)),
          Column(
            children: children,
          )
        ]));
  }
}
