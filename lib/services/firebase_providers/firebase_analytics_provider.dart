import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/analytics_provider.dart';

class FirebaseAnalyticsProvider extends AnalyticsProvider {
  @override
  void setAuthUser(AuthUser? user) {
    FirebaseAnalytics.instance.setUserId(id: user?.uid);
  }

  @override
  void joinedSnapSession(Session session) {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    analytics.logEvent(name: "joinedSnapSession", parameters: {
      "sessionId": session.id,
      "sessionName": session.circle.name
    });
  }

  void showScreen(String name) {
    FirebaseAnalytics.instance.logScreenView(screenName: name);
  }
}
