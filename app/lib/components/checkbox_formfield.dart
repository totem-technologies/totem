import 'package:flutter/material.dart';
import 'package:totem/theme/app_theme_styles.dart';

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField({
    Key? key,
    required BuildContext context,
    Widget? child,
    required bool value,
    FormFieldSetter<bool>? onSaved,
    FormFieldValidator<bool>? validator,
    CrossAxisAlignment alignment = CrossAxisAlignment.center,
    required Function(bool?) onChanged,
    bool initialValue = false,
  }) : super(
          key: key,
          validator: validator,
          initialValue: initialValue,
          builder: (FormFieldState<bool> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: () {
                    state.didChange(!value);
                    onChanged(!value);
                  },
                  child: Row(
                    crossAxisAlignment: alignment,
                    children: <Widget>[
                      Checkbox(
                        visualDensity:
                            const VisualDensity(horizontal: -4, vertical: -4),
                        activeColor: Theme.of(context).themeColors.primaryText,
                        splashRadius: 0,
                        value: value,
                        onChanged: (bool? newValue) {
                          state.didChange(newValue);
                          onChanged(newValue!);
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: child ?? Container()),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(state.errorText ?? "",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error, fontSize: 13)),
              ],
            );
          },
        );
}
