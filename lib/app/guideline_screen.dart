import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GuidelineScreen extends StatelessWidget {
  const GuidelineScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Localized.of(context).t;
    final textStyles = Theme.of(context).textTheme;
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 35, right: 35, top: 40, bottom: 150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      t('guidelinesHeader'),
                      style: textStyles.headline1,
                      textAlign: TextAlign.center,
                    ),
                    const Center(child: ContentDivider()),
                    const SizedBox(height: 24),
                    Text('Last Time Updated: May 12,2021',
                           style: textStyles.bodyText1!.merge(const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 15,),
                    Text( t('guidelines'),
                      style: textStyles.bodyText1,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _bottomControls(context),
              ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _bottomControls(BuildContext context) {
    final t = Localized.of(context).t;
    final textStyles = Theme.of(context).textTheme;
    final themeColors = Theme.of(context).themeColors;
    return BottomTrayContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(onPressed: () => _signOut(context),
              child: Row(
                children: [
                  Icon(Icons.arrow_back, color: themeColors.primaryText,),
                  const SizedBox(width: 5,),
                  Text(t('back'), style: textStyles.button,),
                ],
              )
          ),
          ThemedRaisedButton(
            label: t('acceptGuidelines'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await context.read(authServiceProvider).signOut();
    Navigator.of(context).pop();
  }
}
