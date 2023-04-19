import 'package:js/js.dart';
import 'audio_level_impl.dart';

@JS('FlutterAudioLevel.getAudioLevel')
external void _getAudioLevel(Function(double) callback);

@JS('FlutterAudioLevel.stopAudioStream')
external void stopAudioStream();

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
