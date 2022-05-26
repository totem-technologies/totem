import 'dart:async';
import 'dart:math';

class AudioLevelData {
  final double level;
  final bool speaking;
  AudioLevelData(this.level, this.speaking);
}

abstract class AudioLevelImpl {
  final double speakingThreshold = 0.38; // Through trial and error.
  final minDB = 20;
  final maxDB = 120;
  double lastLevel = 0;
  bool speaking = false;
  late StreamController<AudioLevelData> controller;

  AudioLevelImpl() {
    controller = StreamController<AudioLevelData>.broadcast(
        onListen: start, onCancel: stop);
  }

  void start();

  void stop();

  emitData(double level) {
    double adjustedLevel = adjustLevel(level);
    if (adjustedLevel != lastLevel) {
      lastLevel = adjustedLevel;
      speaking = adjustedLevel > speakingThreshold;
      controller.add(AudioLevelData(adjustedLevel, speaking));
    }
  }

  double adjustLevel(double level) {
    return min(max((level - minDB) / (maxDB - minDB), 0), 1);
  }

  Stream<AudioLevelData> get stream {
    return controller.stream;
  }
}
