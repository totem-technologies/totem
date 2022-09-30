import 'package:totem/models/system_video.dart';

abstract class SystemProvider {
  Future<SystemVideo> getSystemVideo();
}
