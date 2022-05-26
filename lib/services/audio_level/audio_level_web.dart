import 'package:js/js.dart';
import 'audio_level_impl.dart';

@JS('AudioLevels.getAudioLevel')
external _getAudioLevel(Function(double) callback);

@JS('AudioLevels.stopAudioStream')
external stopAudioStream();

class AudioLevel extends AudioLevelImpl {
  @override
  void start() {
    _getAudioLevel(allowInterop(emitData));
  }

  @override
  void stop() {
    stopAudioStream();
  }
}
