import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:totem/services/utils/index.dart';
import 'package:totem/theme/index.dart';

import 'bottom_tray_container.dart';
import 'dialog_container.dart';

Future<T?> showDialogOrBottomSheet<T>(
    {required Widget child, required BuildContext context, double? maxWidth}) {
  return DeviceType.isPhone()
      ? showModalBottomSheet<T>(
          enableDrag: false,
          isScrollControlled: true,
          isDismissible: false,
          context: context,
          backgroundColor: Colors.transparent,
          barrierColor: Theme.of(context).themeColors.blurBackground,
          builder: (_) {
            return Material(
              color: Colors.transparent,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                child: SafeArea(
                  top: true,
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 50,
                    ),
                    child: BottomTrayContainer(
                      fullScreen: true,
                      padding: EdgeInsets.zero,
                      child: child,
                    ),
                  ),
                ),
              ),
            );
          })
      : showDialog<T>(
          context: context,
          barrierColor: Theme.of(context).themeColors.blurBackground,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Material(
              color: Colors.transparent,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                child: Center(
                  child: SingleChildScrollView(
                    child: DialogContainer(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth:
                                maxWidth ?? Theme.of(context).maxRenderWidth),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
}
