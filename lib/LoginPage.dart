import 'package:flutter/material.dart';
import 'dart:ui';

import 'FrostedPanelWidget.dart';
import 'RegisterPage.dart';

class _LoginButtonWidget extends StatelessWidget {
  _LoginButtonWidget({required this.onPressed});
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * .5,
        child: RawMaterialButton(
          fillColor: Colors.amber[200],
          splashColor: Colors.amberAccent,
          onPressed: onPressed,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const <Widget>[
                Text(
                  'Login',
                  maxLines: 1,
                  style: TextStyle(color: Colors.black),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ));
  }
}

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
      _LoginButtonWidget(
          onPressed: () => {Navigator.pushNamed(context, '/login/phone')}),
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
