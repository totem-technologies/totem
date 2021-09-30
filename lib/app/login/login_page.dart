import 'package:flutter/material.dart';
import 'package:totem/components/widgets/buttons.dart';
import 'package:totem/components/widgets/headers.dart';

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(children: [
      const TotemHeader(
        text: 'Welcome to Totem',
      ),
      const Padding(
        padding: EdgeInsets.only(bottom: 40),
        child: SizedBox(
          width: 290,
          child: Text(
            'We are a Community, made to let you share and participate with others, by communicating your thoughts on a topic of your interest.',
            textAlign: TextAlign.center,
            style: TextStyle(height: 1.5),
          ),
        ),
      ),
      TotemContinueButton(
        buttonText: 'Login',
        onButtonPressed: (stop) {
          stop();
          Navigator.pushNamed(context, '/login/phone');
        },
      ),
    ]));
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Center(
        child: Column(
          children: const [_LoginPanel()],
        ),
      ),
    ));
  }
}
