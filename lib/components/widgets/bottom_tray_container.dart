import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          padding: EdgeInsets.only(top: 24.h, bottom: 18.h),
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
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.w),
                  topRight: Radius.circular(30.w))),
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