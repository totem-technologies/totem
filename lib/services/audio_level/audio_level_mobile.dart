import 'dart:async';

import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioLevel {
  static const double speakingThreshold = 52;
  late StreamController<bool> controller;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseMeter? _noiseMeter;
  AudioLevel() {
    _controller =
        StreamController<bool>.broadcast(onListen: start, onCancel: stop);
  }

  late StreamController<bool> _controller;

  void start() async {
    await Permission.microphone.request();
    _noiseMeter = NoiseMeter((error) {});
    _noiseSubscription = _noiseMeter!.noiseStream.listen((event) {
      _controller.add(event.maxDecibel > speakingThreshold);
    });
  }

  void stop() async {
    _noiseSubscription?.cancel();
    _noiseSubscription = null;
    _noiseMeter = null;
  }

  Stream<bool> get stream {
    return _controller.stream;
  }
}
