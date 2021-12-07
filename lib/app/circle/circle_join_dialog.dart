import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CircleJoinDialog extends StatelessWidget {
  const CircleJoinDialog({Key? key, required this.session}) : super(key: key);
  final Session session;

  static Future<bool?> showDialog(BuildContext context,
      {required Session session}) async {
    return showModalBottomSheet<bool>(
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).themeColors.blurBackground,
      builder: (_) => CircleJoinDialog(
        session: session,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    final textStyles = Theme.of(context).textStyles;
    final t = AppLocalizations.of(context)!;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 30,
          ),
          child: BottomTrayContainer(
            fullScreen: true,
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Container()),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      icon: Icon(
                        Icons.close,
                        color: themeColors.primaryText,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  session.circle.name,
                  style: textStyles.dialogTitle,
                  textAlign: TextAlign.center,
                ),
                Expanded(child: Container()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ThemedRaisedButton(
                      label: t.joinSession,
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      width: Theme.of(context).standardButtonWidth,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
