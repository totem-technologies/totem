import 'package:flutter/material.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/theme/index.dart';

class ThemedTextField extends StatelessWidget {
  const ThemedTextField({
    Key? key,
    this.labelText,
    this.labelStyle,
    this.controller,
    this.enabledBorderColor,
    this.focusedBorderColor,
    this.cursorColor,
    this.keyboardType,
    this.focusNode,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = false,
    this.obscureText = false,
  }) : super(key: key);
  final String? labelText;
  final TextEditingController? controller;
  final TextStyle? labelStyle;
  final Color? enabledBorderColor;
  final Color? focusedBorderColor;
  final Color? cursorColor;
  final bool autocorrect;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final textStyles = themeData.textStyles;
    final themeColors = themeData.themeColors;

    return TextField(
      decoration: ThemedInputDecoration(
        labelText: labelText,
        labelStyle: labelStyle,
        textStyles: textStyles,
        themeColors: themeColors,
      ),
      controller: controller,
      autocorrect: autocorrect,
      obscureText: obscureText,
      keyboardType: keyboardType,
      cursorColor: cursorColor ?? themeColors.primaryText,
      textCapitalization: textCapitalization,
      focusNode: focusNode,
      textInputAction: textInputAction,
    );
  }
}
