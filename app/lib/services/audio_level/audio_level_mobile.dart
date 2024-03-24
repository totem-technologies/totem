import 'dart:async';

import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'audio_level_impl.dart';

class AudioLevel extends AudioLevelImpl {
  StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseMeter? _noiseMeter;

  @override
  void start() async {
    await Permission.microphone.request();
    _noiseMeter = NoiseMeter();
    _noiseSubscription = _noiseMeter!.noise.listen((event) {
      emitData(event.meanDecibel);
    });
  }

  @override
  void stop() async {
    await _noiseSubscription?.cancel();
    _noiseSubscription = null;
    _noiseMeter = null;
  }
}
