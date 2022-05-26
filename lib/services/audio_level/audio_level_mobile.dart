import 'dart:async';
import 'dart:math';

import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioLevel {
  static const double speakingThreshold = 45;
  static const double speakingPct = 0.25;
  static const minDB = 20;
  static const maxDB = 120;
  double lastLevel = 0;
  bool speaking = false;
  late StreamController<double> controller;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseMeter? _noiseMeter;
  AudioLevel() {
    _controller =
        StreamController<double>.broadcast(onListen: start, onCancel: stop);
  }

  late StreamController<double> _controller;

  void start() async {
    await Permission.microphone.request();
    _noiseMeter = NoiseMeter((error) {});
    _noiseSubscription = _noiseMeter!.noiseStream.listen((event) {
      double adjustedLevel =
          min(max((event.meanDecibel - minDB) / (maxDB - minDB), 0), 1);
      if (adjustedLevel != lastLevel) {
        lastLevel = adjustedLevel;
        speaking = event.meanDecibel > speakingThreshold;
        _controller.add(adjustedLevel);
      }
    });
  }

  void stop() async {
    _noiseSubscription?.cancel();
    _noiseSubscription = null;
    _noiseMeter = null;
  }

  Stream<double> get stream {
    return _controller.stream;
  }
}
