import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum CountdownDisplayFormat { minutes, hoursAndMinutes, override }

/// State of the countdown timer that can be set at different time transitions
class CountdownState {
  const CountdownState({
    this.minutesRemaining,
    this.displayValue,
    this.displayFormat,
    this.color,
    this.backgroundColor,
    this.valueLabel,
    this.valueOverride,
  });

  // Minutes remaining at which the stat is set
  final int? minutesRemaining;
  // Whether to display the time value along with progress indicator and icon
  final bool? displayValue;
  // Format of the time value to display (or override)
  final CountdownDisplayFormat? displayFormat;
  // Color of the progress bar and time value
  final Color? color;
  // Background color of the progress and icon color
  final Color? backgroundColor;
  // Text to display below the time value
  final String? valueLabel;
  // Text to display instead of the time value if displayFormat is override
  final String? valueOverride;

  CountdownState.from(CountdownState base, CountdownState? overrides)
      : minutesRemaining = overrides?.minutesRemaining != null
            ? overrides!.minutesRemaining
            : base.minutesRemaining,
        displayValue = overrides?.displayValue != null
            ? overrides!.displayValue
            : base.displayValue,
        displayFormat = overrides?.displayFormat != null
            ? overrides!.displayFormat
            : base.displayFormat,
        color = overrides?.color != null ? overrides!.color : base.color,
        backgroundColor = overrides?.backgroundColor != null
            ? overrides!.backgroundColor
            : base.backgroundColor,
        valueLabel = overrides?.valueLabel != null
            ? overrides!.valueLabel
            : base.valueLabel,
        valueOverride = overrides?.valueOverride != null
            ? overrides!.valueOverride
            : base.valueOverride;
}

/// A countdown timer widget that displays a progress bar with icon and a
/// time value. The progress bar counts down from startTime to endTime in
/// minutes. It will then  counts up for overTimeMinutes.
class CountdownTimer extends ConsumerStatefulWidget {
  const CountdownTimer({
    Key? key,
    required this.startTime,
    required this.endTime,
    this.overtimeMinutes = 30,
    this.defaultState = const CountdownState(
      displayValue: true,
      displayFormat: CountdownDisplayFormat.hoursAndMinutes,
      color: Colors.white,
      backgroundColor: Colors.grey,
      valueLabel: 'remaining',
    ),
    this.stateTransitions = const <CountdownState>[
      CountdownState(
          minutesRemaining: 5,
          displayValue: true,
          displayFormat: CountdownDisplayFormat.minutes,
          color: Colors.yellow,
          valueLabel: 'ending soon'),
      CountdownState(
          minutesRemaining: 0,
          displayFormat: CountdownDisplayFormat.override,
          color: Colors.orange,
          valueLabel: 'ending',
          valueOverride: 'Now'),
      CountdownState(
          minutesRemaining: -1,
          displayFormat: CountdownDisplayFormat.hoursAndMinutes,
          color: Colors.red,
          valueLabel: 'overtime'),
    ],
  }) : super(key: key);

  // Time when the countdown starts
  final DateTime startTime;
  // Time when the countdown ends
  final DateTime endTime;
  // Over time minutes to count up after the countdown ends
  final int overtimeMinutes;
  // Default state of the countdown timer
  final CountdownState defaultState;
  // List of state transitions to set at different time transitions, these
  // are applied as override values to the defaultState
  final List<CountdownState> stateTransitions;

  @override
  CountdownTimerState createState() => CountdownTimerState();
}

class CountdownTimerState extends ConsumerState<CountdownTimer> {
  late DateTime _endTime;
  late String _valueDisplay;
  late Duration _timeRemaining;
  late double _lastPercentage;
  double _percentRemaining = 1;
  late Duration _totalTime;
  late bool _displayValue;
  late CountdownState _currentState;
  late Timer _timer;

  @override
  void initState() {
    _currentState = CountdownState.from(widget.defaultState, null);
    _updateInitialValues();
    _timer = Timer.periodic(const Duration(seconds: 1), _updateTimerValue);
    super.initState();
  }

  @override
  void didUpdateWidget(CountdownTimer oldWidget) {
    _updateInitialValues();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateInitialValues() {
    // Make sure differences in minutes always round up
    _endTime = DateTime(
      widget.endTime.year,
      widget.endTime.month,
      widget.endTime.day,
      widget.endTime.hour,
      widget.endTime.minute,
      59,
    );
    _totalTime = _endTime.difference(widget.startTime);
    _displayValue = _currentState.displayValue ?? false;
    _updateTimeAndState();
  }

  // Update the remaining minutes, percentage and any UI state transitions
  void _updateTimeAndState() {
    _timeRemaining = _endTime.difference(DateTime.now());
    // debugPrint(
    //     'CountdownTimer: total: $_totalTime, remaining: $_timeRemaining');
    _lastPercentage = _percentRemaining;
    if (_timeRemaining.inSeconds > 0) {
      _percentRemaining = _timeRemaining.inSeconds / _totalTime.inSeconds;
    } else if (_timeRemaining.inSeconds == 0) {
      _percentRemaining = 0;
    } else {
      int negativeSeconds = _timeRemaining.inSeconds.abs();
      if (negativeSeconds > 0) {
        _percentRemaining = negativeSeconds >= widget.overtimeMinutes * 60
            ? 1
            : negativeSeconds / (widget.overtimeMinutes * 60);
      } else {
        _percentRemaining = 0;
      }
    }
    CountdownState? newState;
    for (final CountdownState state in widget.stateTransitions) {
      if (state.minutesRemaining != null &&
          _timeRemaining.inMinutes <= state.minutesRemaining!) {
        newState = state;
      }
    }
    if (newState != null) {
      _currentState = CountdownState.from(widget.defaultState, newState);
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateValueDisplay();
    return InkWell(
      onTap: () {
        setState(() {
          _displayValue = !_displayValue;
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_displayValue) ...[
            _buildValueDisplay(),
            const SizedBox(width: 10)
          ],
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                LucideIcons.clock,
                color: _currentState.backgroundColor,
                size: 40,
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: _lastPercentage, end: _percentRemaining),
                duration: const Duration(seconds: 1),
                builder: (context, value, _) => CircularProgressIndicator(
                  strokeWidth: 6.0,
                  value: value,
                  color: _currentState.color,
                  backgroundColor: _currentState.backgroundColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValueDisplay() {
    final textStyles = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _valueDisplay,
          style: textStyles.headline6
              ?.merge(TextStyle(color: _currentState.color)),
        ),
        Text(
          _currentState.valueLabel ?? '',
          style: textStyles.headline5
              ?.merge(TextStyle(color: _currentState.color)),
        )
      ],
    );
  }

  void _updateValueDisplay() {
    switch (_currentState.displayFormat) {
      case CountdownDisplayFormat.minutes:
        // Just shows minutes with option + if over time
        String minuteString = _timeRemaining.inMinutes.abs().toString();
        String plus = _timeRemaining.inMinutes < 0 ? '+' : '';
        _valueDisplay = '$plus$minuteString';
        break;
      case CountdownDisplayFormat.hoursAndMinutes:
        // Shows hours:minutes or :minutes with option + if over time
        {
          int hours = _timeRemaining.inHours.abs();
          int minutes = hours == 0
              ? _timeRemaining.inMinutes.abs()
              : _timeRemaining.inMinutes.abs().remainder(hours * 60);
          String plus = _timeRemaining.isNegative ? '+' : '';
          String minuteString = minutes.toString().padLeft(2, "0");
          String hourString = hours > 0 ? hours.toString() : '';
          _valueDisplay = '$plus$hourString:$minuteString';
        }
        break;
      case CountdownDisplayFormat.override:
        // Shows a custom override static string
        _valueDisplay = _currentState.valueOverride ?? '';
        break;
      default:
        _valueDisplay = '';
    }
  }

  void _updateTimerValue(Timer timer) {
    debugPrint('CountdownTimer: ${DateTime.now()}');
    setState(() {
      _updateTimeAndState();
    });
  }
}
