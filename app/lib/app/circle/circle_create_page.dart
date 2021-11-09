import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/components/widgets/sub_page_header.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CircleCreatePage extends ConsumerStatefulWidget {
  const CircleCreatePage({Key? key}) : super(key: key);

  @override
  _CircleCreatePageState createState() => _CircleCreatePageState();
}

class _CircleCreatePageState extends ConsumerState<CircleCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numSessionsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<int> _daysOfWeek = [];
  bool _busy = false;
  final _focusNodeNumSessions = FocusNode();
  final _focusNodeDescription = FocusNode();
  DateTime? _startDate;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: false,
      actions: [
        KeyboardActionsItem(
          focusNode: _focusNodeNumSessions,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final textStyles = themeData.textStyles;
    final themeColors = themeData.themeColors;
    final t = AppLocalizations.of(context)!;
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            // call this method here to hide soft keyboard
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              SafeArea(
                top: true,
                bottom: false,
                child: Column(
                  children: [
                    SubPageHeader(title: t.createCircle),
                    Expanded(
                      child: KeyboardActions(
                        tapOutsideBehavior: TapOutsideBehavior.opaqueDismiss,
                        config: _buildConfig(context),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: themeData.pageHorizontalPadding),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  ThemedTextFormField(
                                    labelText: t.name,
                                    controller: _nameController,
                                    autofocus: true,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    textInputAction: TextInputAction.next,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return t.errorEnterName;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  ThemedTextFormField(
                                    focusNode: _focusNodeNumSessions,
                                    labelText: t.numberOfSessions,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            signed: false, decimal: false),
                                    controller: _numSessionsController,
                                    textInputAction: TextInputAction.next,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return t.errorEnterNumSessions;
                                      }
                                      try {
                                        var num = double.parse(
                                                _numSessionsController.text)
                                            .toInt();
                                        if (num > 100) {
                                          return t.errorEnterNumSessions;
                                        }
                                      } catch (e) {
                                        return t.errorEnterNumSessions;
                                      }

                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  DateTimeField(
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    decoration: ThemedInputDecoration(
                                      labelText: t.startDate,
                                      textStyles: textStyles,
                                      themeColors: themeColors,
                                    ),
                                    format: DateFormat.yMMMd(),
                                    onShowPicker: (context, currentValue) {
                                      final now = DateTime.now();
                                      return showDatePicker(
                                        context: context,
                                        firstDate: now,
                                        initialDate: currentValue ?? now,
                                        lastDate: DateTime(2100),
                                      );
                                    },
                                    validator: (value) {
                                      if (value == null) {
                                        return t.errorStartDate;
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _startDate = value;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  DayOfWeekFormField(
                                      initialValue: _daysOfWeek,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      onSaved: (value) {
                                        _daysOfWeek = value!;
                                      },
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return t.errorSelectAtLeastOneDay;
                                        }
                                        return null;
                                      }),
                                  const SizedBox(height: 20),
                                  DateTimeField(
                                    decoration: ThemedInputDecoration(
                                      labelText: t.startTime,
                                      textStyles: textStyles,
                                      themeColors: themeColors,
                                    ),
                                    format: DateFormat("h:mm a"),
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    onShowPicker:
                                        (context, currentValue) async {
                                      final TimeOfDay? time =
                                          await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.fromDateTime(
                                            currentValue ?? DateTime.now()),
                                      );
                                      return time == null
                                          ? null
                                          : DateTimeField.convert(time);
                                    },
                                    onSaved: (value) {
                                      _startTime = value;
                                    },
                                    validator: (value) {
                                      if (value == null) {
                                        return t.errorStartTime;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  ThemedTextFormField(
                                    focusNode: _focusNodeDescription,
                                    controller: _descriptionController,
                                    labelText: t.description,
                                    maxLines: 0,
                                    textInputAction: TextInputAction.done,
                                  ),
                                  const SizedBox(height: 30),
                                  ThemedRaisedButton(
                                    label: t.createCircle,
                                    onPressed: () {
                                      _saveCircle();
                                    },
                                  ),
                                  const SizedBox(height: 50)
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_busy)
                const Center(
                  child: BusyIndicator(),
                )
            ],
          ),
        ),
      ),
    );
  }

  void _saveCircle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _busy = true);
    _formKey.currentState!.save();
    int numSessions = double.parse(_numSessionsController.text).toInt();

    var repo = ref.read(repositoryProvider);
    try {
      final circle = await repo.createCircle(
          name: _nameController.text,
          numSessions: numSessions,
          startDate: _startDate!,
          startTime: _startTime!,
          daysOfTheWeek: _daysOfWeek,
          description: _descriptionController.text);
      if (circle != null) {
        Navigator.of(context).pop();
        return;
      }
    } catch (ex) {
      debugPrint('Error creating circle: ' + ex.toString());
    }
    setState(() => _busy = false);
  }
}
