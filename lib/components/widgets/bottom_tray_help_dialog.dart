import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:totem/components/widgets/bottom_tray_container.dart';
import 'package:totem/theme/index.dart';

class BottomTrayHelpDialog extends StatelessWidget {
  static void showTrayHelp(BuildContext context,
      {required String title, required String detail}) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).themeColors.blurBackground,
      builder: (_) => BottomTrayHelpDialog(
        title: title,
        detail: detail,
      ),
    );
  }

  const BottomTrayHelpDialog(
      {Key? key, required this.title, required this.detail})
      : super(key: key);
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    final themeColors = Theme.of(context).themeColors;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
      child: BottomTrayContainer(
        padding:
            const EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
        child: SafeArea(
          top: false,
          bottom: true,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: textStyles.headline4!
                          .merge(const TextStyle(fontWeight: FontWeight.w600)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      detail,
                      style: textStyles.headline4!
                          .merge(const TextStyle(fontWeight: FontWeight.w400)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 5,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 5, bottom: 5),
                    child: Icon(
                      Icons.close,
                      size: 24,
                      color: themeColors.primaryText,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
