import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum CountdownDisplayType { minutes, hoursAndMinutes }

class CountdownTimer extends ConsumerStatefulWidget {
  const CountdownTimer({
    Key? key,
    required this.startTime,
    required this.endTime,
    required this.displayValue,
    required this.color,
    required this.backgroundColor,
    this.displayType = CountdownDisplayType.hoursAndMinutes,
    this.valueLabel = '',
    this.endValue = '0',
    this.endValueLabel = '',
  }) : super(key: key);

  final DateTime startTime;
  final DateTime endTime;
  final bool displayValue;
  final Color color;
  final Color backgroundColor;
  final CountdownDisplayType displayType;
  final String valueLabel;
  final String endValue;
  final String endValueLabel;

  @override
  CountdownTimerState createState() => CountdownTimerState();
}

class CountdownTimerState extends ConsumerState<CountdownTimer> {
  late String _valueDisplay;
  late String _valueLabel;
  late Duration _timeRemaining;
  late double _percentRemaining;
  late bool _displayValue;
  late int _totalMinutes;

  @override
  void initState() {
    _updateTimeValues();
    Timer.periodic(const Duration(minutes: 1), _updateTimerValue);
    super.initState();
  }

  @override
  void didUpdateWidget(CountdownTimer oldWidget) {
    _updateTimeValues();
    super.didUpdateWidget(oldWidget);
  }

  void _updateTimeValues() {
    _displayValue = widget.displayValue;
    _totalMinutes = widget.endTime.difference(widget.startTime).inMinutes + 1;
    _updateTimeRemaining();
  }

  void _updateTimeRemaining() {
    int expiresMinutes =
        widget.endTime.difference(DateTime.now()).inMinutes + 1;
    _timeRemaining = Duration(minutes: expiresMinutes);
    if (_timeRemaining.inMinutes > 0) {
      _percentRemaining = _timeRemaining.inMinutes / _totalMinutes;
    } else {
      _timeRemaining = const Duration(minutes: 0);
      _percentRemaining = 0;
    }

    _percentRemaining = expiresMinutes / _totalMinutes;
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
                color: widget.backgroundColor,
                size: 40,
              ),
              CircularProgressIndicator(
                strokeWidth: 6.0,
                value: _percentRemaining,
                color: widget.color,
                backgroundColor: widget.backgroundColor,
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
          style: textStyles.headline6?.merge(TextStyle(color: widget.color)),
        ),
        Text(
          _valueLabel,
          style: textStyles.headline5?.merge(TextStyle(color: widget.color)),
        )
      ],
    );
  }

  void _updateValueDisplay() {
    if (_timeRemaining.inMinutes > 0) {
      if (widget.displayType == CountdownDisplayType.minutes) {
        _valueDisplay = '${_timeRemaining.inMinutes}';
      } else {
        int hours = _timeRemaining.inHours;
        int minutes = hours == 0
            ? _timeRemaining.inMinutes
            : _timeRemaining.inMinutes.remainder(hours * 60);
        String minuteString = minutes.toString().padLeft(2, "0");
        String hourString = hours > 0 ? hours.toString() : '';
        _valueDisplay = '$hourString:$minuteString';
      }
      _valueLabel = widget.valueLabel;
    } else {
      _valueDisplay = widget.endValue;
      _valueLabel = widget.endValueLabel;
    }
  }

  void _updateTimerValue(Timer timer) {
    setState(() {
      _updateTimeRemaining();
    });
  }
}
