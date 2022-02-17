import 'package:flutter/material.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/theme/index.dart';

class ThemedTextFormField extends StatelessWidget {
  const ThemedTextFormField({
    Key? key,
    this.hintText,
    this.hintStyle,
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
    this.validator,
    this.maxLines = 1,
    this.autovalidateMode,
    this.autofocus = false,
    this.onEditingComplete,
    this.suffixIcon,
    this.contentPadding,
    this.isDense = true,
    this.autofillHints,
    this.onChanged,
    this.maxLength,
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
  final String? Function(String?)? validator;
  final int maxLines;
  final AutovalidateMode? autovalidateMode;
  final bool autofocus;
  final void Function()? onEditingComplete;
  final Widget? suffixIcon;
  final String? hintText;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? contentPadding;
  final bool isDense;
  final Iterable<String>? autofillHints;
  final int? maxLength;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final textStyles = themeData.textStyles;
    final themeColors = themeData.themeColors;

    return TextFormField(
      decoration: ThemedInputDecoration(
        hintText: hintText,
        hintStyle: hintStyle,
        labelText: labelText,
        labelStyle: labelStyle,
        themeColors: themeColors,
        textStyles: textStyles,
        suffixIcon: suffixIcon,
        contentPadding: contentPadding,
        isDense: isDense,
      ),
      autofillHints: autofillHints,
      controller: controller,
      autocorrect: autocorrect,
      obscureText: obscureText,
      keyboardType: keyboardType,
      cursorColor: cursorColor ?? themeColors.primaryText,
      textCapitalization: textCapitalization,
      focusNode: focusNode,
      textInputAction: textInputAction,
      validator: validator,
      maxLines: maxLines > 0 ? maxLines : null,
      autovalidateMode: autovalidateMode,
      autofocus: autofocus,
      onEditingComplete: onEditingComplete,
      onChanged: onChanged,
      maxLength: maxLength,
      buildCounter: (maxLength ?? 0) > 0 ? InputCounter.counterWidget : null,
    );
  }
}
