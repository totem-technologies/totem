import 'dart:async';
import 'audio_level_impl.dart';

import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioLevel extends AudioLevelImpl {
  StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseMeter? _noiseMeter;

  @override
  void start() async {
    await Permission.microphone.request();
    _noiseMeter = NoiseMeter((error) {});
    _noiseSubscription = _noiseMeter!.noiseStream.listen((event) {
      emitData(event.meanDecibel);
    });
  }

  @override
  void stop() async {
    _noiseSubscription?.cancel();
    _noiseSubscription = null;
    _noiseMeter = null;
  }
}
