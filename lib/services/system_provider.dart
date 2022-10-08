import 'package:totem/models/index.dart';

abstract class SystemProvider {
  Future<SystemVideo> getSystemVideo();
  Future<List<CircleTheme>> getSystemCircleThemes();
}
