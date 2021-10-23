import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Localized.of(context).t;
    return  Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  t('welcome'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32, ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Center(
                  child: ContentDivider(),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Center(
            child:TotemContinueButton(
              buttonText: t('login'),
              onButtonPressed: (stop) {
                stop();
                Navigator.pushNamed(context, '/login/phone');
              },
            ),
          ),
        ),
      ],
    );
/*
    Center(
        child: Column(children: [
      TotemHeader(
        text: t('welcome'),
      ),
      Padding(
        padding: EdgeInsets.only(bottom: 40),
        child: SizedBox(
          width: 290,
          child: Text(
            t('welcomeDetail'),
            textAlign: TextAlign.center,
            style: TextStyle(height: 1.5),
          ),
        ),
      ),
      TotemContinueButton(
        buttonText: t('login'),
        onButtonPressed: (stop) {
          stop();
          Navigator.pushNamed(context, '/login/phone');
        },
      ),
    ])); */
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    return GradientBackground(
      gradient: themeColors.secondaryGradient,
      child:Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: Container()),
                SvgPicture.asset('assets/background_shape_2.svg', fit: BoxFit.fill,),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: Container()),
                SvgPicture.asset('assets/background_shape.svg', fit: BoxFit.fill,)
              ],
            ),
            const _LoginPanel(),
          ],
        )
      ),
    );
  }
}
