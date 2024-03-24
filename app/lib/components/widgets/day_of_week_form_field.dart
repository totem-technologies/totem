import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:totem/theme/index.dart';

class DayOfWeekFormField extends FormField<List<int>> {
  DayOfWeekFormField({
    required List<int> super.initialValue,
    super.onSaved,
    super.validator,
    super.autovalidateMode,
    super.key,
  }) : super(
            builder: (FormFieldState<List<int>> state) {
              final themeColors = Theme.of(state.context).themeColors;
              final textStyles = Theme.of(state.context).textStyles;
              Widget dayOfWeekItem(String item, int index) {
                return InkWell(
                  onTap: () {
                    if (state.value!.contains(index)) {
                      state.value!.remove(index);
                    } else {
                      state.value!.add(index);
                    }
                    state.didChange(state.value);
                  },
                  child: Row(
                    children: [
                      Checkbox(
                          activeColor: themeColors.primaryText,
                          value: state.value!.contains(index),
                          onChanged: (bool? value) {
                            if (state.value!.contains(index)) {
                              state.value!.remove(index);
                            } else {
                              state.value!.add(index);
                            }
                            state.didChange(state.value);
                          }),
                      Text(item),
                    ],
                  ),
                );
              }

              List<Widget> rowItems() {
                final t = AppLocalizations.of(state.context)!;
                final locale = t.localeName;
                final daysOfWeek = dateTimeSymbolMap()[locale].WEEKDAYS;

                List<Widget> items = [];
                for (int index = 1; index <= 4; index++) {
                  int secondIndex = index < 3 ? index + 4 : 0;
                  items.add(Row(
                    children: [
                      Expanded(child: dayOfWeekItem(daysOfWeek[index], index)),
                      Expanded(
                          child: (index < 4)
                              ? dayOfWeekItem(
                                  daysOfWeek[secondIndex], secondIndex)
                              : Container()),
                    ],
                  ));
                }
                return items;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...rowItems(),
                  state.hasError
                      ? Text(
                          state.errorText!,
                          style: textStyles.formErrorLabel,
                        )
                      : Container()
                ],
              );
            });
}
