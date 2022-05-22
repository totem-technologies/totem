import 'dart:async';

import 'package:js/js.dart';

@JS('AudioLevels.getAudioLevel')
external _getAudioLevel(Function(double) callback);

@JS('AudioLevels.stopAudioStream')
external stopAudioStream();

class AudioLevel {
  static const speakingThreshold = 45;
  AudioLevel() {
    _controller =
        StreamController<bool>.broadcast(onListen: start, onCancel: stop);
  }
  bool last = false;
  late StreamController<bool> _controller;

  _callback(level) {
    bool speaking = level > speakingThreshold;
    if (speaking != last) {
      last = speaking;
      _controller.add(speaking);
    }
  }

  void start() {
    _getAudioLevel(allowInterop(_callback));
  }

  void stop() {
    stopAudioStream();
  }

  Stream<bool> get stream {
    return _controller.stream;
  }
}
