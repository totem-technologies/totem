import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';

class BottomTrayContainer extends StatelessWidget {
  const BottomTrayContainer({Key? key, required this.child}) : super(key: key);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    return Wrap(
      children:[
        Container(
          padding: const EdgeInsets.only(top: 24, bottom: 18),
          decoration: BoxDecoration(
            color: themeColors.trayBackground,
            boxShadow: [
              BoxShadow(
                  color: themeColors.shadow, offset: const Offset(0, -8), blurRadius: 24),
            ],
            border: Border.all(
                color: themeColors.trayBorder,
                width: 1.0
            ),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30)
            ),
          ),
          alignment: Alignment.center,
          child: SafeArea(
            top: false,
            bottom: true,
            child: child,
          ),
        ),
      ],
    );
  }

}