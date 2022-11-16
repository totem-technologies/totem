import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:totem/components/index.dart';
import 'package:totem/theme/index.dart';

class CountdownTimerTest extends StatefulWidget {
  const CountdownTimerTest({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CountdownTimerTestState();
}

class CountdownTimerTestState extends State<CountdownTimerTest> {
  bool showing = true;
  int duration = 1800; // 30 min in seconds
  DateTime startTime = DateTime.now();
  late DateTime endTime;
  int overtime = 1800; // 30 min in seconds
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _overtimeController = TextEditingController();

  @override
  void initState() {
    _durationController.text = duration.toString();
    _overtimeController.text = overtime.toString();
    endTime = DateTime.now().add(Duration(seconds: duration));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final themeColors = Theme.of(context).themeColors;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        // call this method here to hide soft keyboard
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        children: [
          Material(
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: SizedBox(
                      width: 200,
                      child: CountdownTimer(
                        startTime: startTime,
                        endTime: endTime,
                        overtimeMinutes: (overtime / 60).round(),
                        defaultState: CountdownState(
                          displayValue: true,
                          displayFormat: CountdownDisplayFormat.hoursAndMinutes,
                          color: themeColors.primary,
                          backgroundColor: themeColors.secondaryText,
                          valueLabel: t.remaining,
                        ),
                        stateTransitions: [
                          CountdownState(
                            minutesRemaining: 5,
                            displayValue: true,
                            displayFormat: CountdownDisplayFormat.minutes,
                            color: themeColors.reversedText,
                            valueLabel: t.endsIn,
                          ),
                          CountdownState(
                            minutesRemaining: 0,
                            displayValue: true,
                            displayFormat: CountdownDisplayFormat.override,
                            color: themeColors.alertBackground,
                            backgroundColor: themeColors.alertBackground,
                            valueLabel: t.ending,
                            valueOverride: t.now,
                          ),
                          CountdownState(
                            minutesRemaining: -1,
                            displayValue: true,
                            displayFormat:
                                CountdownDisplayFormat.hoursAndMinutes,
                            color: themeColors.alertBackground,
                            valueLabel: t.overtime,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    SizedBox(
                      width: 100,
                      child: Column(
                        children: [
                          const Text('Duration',
                              style: TextStyle(color: Colors.white)),
                          TextField(
                            controller: _durationController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 1.0,
                                ),
                              ),
                              hintText: 'seconds',
                              hintStyle: const TextStyle(color: Colors.white),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onEditingComplete: () {
                              updateState();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 30),
                    SizedBox(
                      width: 100,
                      child: Column(
                        children: [
                          const Text('Overtime',
                              style: TextStyle(color: Colors.white)),
                          TextField(
                            controller: _overtimeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 1.0,
                                ),
                              ),
                              hintText: 'seconds',
                              hintStyle: const TextStyle(color: Colors.white),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onEditingComplete: () {
                              updateState();
                            },
                          ),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 30),
                  Center(
                    child: ThemedRaisedButton(
                      label: 'Restart',
                      onPressed: () {
                        reset();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              color: Colors.grey,
              child: const SafeArea(
                  top: true, bottom: false, child: SizedBox(height: 25)),
            ),
          )
        ],
      ),
    );
  }

  void updateState() {
    setState(() {
      try {
        duration = int.parse(_durationController.text);
        overtime = int.parse(_overtimeController.text);
        endTime = startTime.add(Duration(seconds: duration));
      } catch (ex) {
        debugPrint(ex.toString());
      }
    });
  }

  void reset() {
    setState(() {
      startTime = DateTime.now();
      endTime = DateTime.now().add(Duration(seconds: duration));
    });
  }
}
