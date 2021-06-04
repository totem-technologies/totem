import 'package:flutter/material.dart';

class TotemTextFormField extends StatelessWidget {
  const TotemTextFormField(
      {Key? key,
      required this.controller,
      required this.validator,
      this.hintText = ''})
      : super(key: key);
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        decoration:
            InputDecoration(border: OutlineInputBorder(), hintText: hintText),
        controller: controller,
        // The validator receives the text that the user has entered.
        validator: validator);
  }
}
