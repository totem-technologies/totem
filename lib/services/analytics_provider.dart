import 'package:totem/models/index.dart';

abstract class AnalyticsProvider {
  void setAuthUser(AuthUser? user);
  void joinedSnapSession(Session session);
}
