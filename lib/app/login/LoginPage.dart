import 'package:flutter/material.dart';
import 'package:totem/components/widgets/Button.dart';
import '../../components/widgets/Header.dart';

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
            child: Column(children: [
      TotemHeader(
        text: 'Welcome to Totem',
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: Container(
          width: 290,
          child: Text(
              'We are a Community, made to let you share and participate with others, by communicating your thoughts on a topic of your interest.',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5)),
        ),
      ),
      TotemButton(
          buttonText: 'Login',
          onButtonPressed: (stop) {
            stop();
            Navigator.pushNamed(context, '/login/phone');
          }, showArrow: true,),
    ])));
  }
}

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Center(
          child: Column(
            children: [_LoginPanel()],
          ),
        ),
      ),
    ));
  }
}
