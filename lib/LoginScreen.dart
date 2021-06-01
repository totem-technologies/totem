import 'package:flutter/material.dart';
import 'dart:ui';

import 'FrostedPanelWidget.dart';

enum LoginScreenPages { welcome, phoneInput, success }

class LoginPage with ChangeNotifier {
  var page = LoginScreenPages.welcome;

  void change(LoginScreenPages page) {
    this.page = page;
    notifyListeners();
  }
}

class LoginButtonWidget extends StatelessWidget {
  LoginButtonWidget({required this.onPressed});
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * .5,
        child: RawMaterialButton(
          fillColor: Colors.amber[200],
          splashColor: Colors.amberAccent,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const <Widget>[
                Text(
                  "Login",
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
          onPressed: onPressed,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
        ));
  }
}

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class LoginWelcomePage extends StatelessWidget {
  const LoginWelcomePage({Key? key}) : super(key: key);

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
      LoginButtonWidget(onPressed: () => {}),
    ])));
  }
}

class LoginPhoneInputPage extends StatelessWidget {
  const LoginPhoneInputPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
            child: Column(children: [
      Padding(
          padding: EdgeInsets.only(top: 50, bottom: 40),
          child: Text(
            'Enter number',
            style: TextStyle(
              fontSize: 40,
              color: Colors.white,
            ),
          )),
      LoginButtonWidget(onPressed: () => {}),
    ])));
  }
}

class _LoginScreenState extends State<LoginScreen> {
  var _full = false;
  var _page = LoginScreenPages.welcome;
  @override
  Widget build(BuildContext context) {
    var content = LoginWelcomePage();
    var panel = FrostedPanelWidget(child: content, full: this._full);
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
        Positioned.fill(
            child: TextButton(
                onPressed: () {
                  setState(() {
                    this._full = !this._full;
                  });
                },
                child: Text('toggle'))),
      ],
    ));
  }
}
