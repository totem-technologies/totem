import 'dart:async';
import 'dart:math';

import 'package:js/js.dart';

@JS('AudioLevels.getAudioLevel')
external _getAudioLevel(Function(double) callback);

@JS('AudioLevels.stopAudioStream')
external stopAudioStream();

class AudioLevel {
  static const speakingThreshold = 45;
  static const double speakingPct = 0.25;
  static const minDB = 20;
  static const maxDB = 120;
  AudioLevel() {
    _controller =
        StreamController<double>.broadcast(onListen: start, onCancel: stop);
  }
  double lastLevel = 0;
  late StreamController<double> _controller;
  bool speaking = false;

  _callback(level) {
    double adjustedLevel = max((level - minDB) / (maxDB - minDB), 0);
    if (adjustedLevel != lastLevel) {
      lastLevel = adjustedLevel;
      speaking = level > speakingThreshold;
      _controller.add(adjustedLevel);
    }
  }

  void start() {
    _getAudioLevel(allowInterop(_callback));
  }

  void stop() {
    stopAudioStream();
  }

  Stream<double> get stream {
    return _controller.stream;
  }
}
