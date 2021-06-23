import 'package:flutter/material.dart';

import 'components/FrostedPanelWidget.dart';
import 'components/Button.dart';

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
            child: Column(children: [
      Padding(
          padding: EdgeInsets.only(top: 50, bottom: 40),
          child: Text(
            'Welcome to Totem',
            style: TextStyle(
              fontSize: 40,
              color: Colors.white,
            ),
          )),
      TotemButton(
          text: 'Login',
          icon: Icons.arrow_forward,
          onPressed: (stop) {
            stop();
            Navigator.pushNamed(context, '/login/phone');
          }),
    ])));
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _full = false;
  @override
  Widget build(BuildContext context) {
    var content = _LoginPanel();
    var panel = FrostedPanelWidget(full: _full, child: content);
    return Scaffold(
        body: Stack(
      children: [
        Positioned.fill(
          child: Image(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        Container(child: panel),
      ],
    ));
  }
}
