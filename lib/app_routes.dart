import 'package:flutter/material.dart';

import 'app/index.dart';
import 'components/index.dart';
import 'models/index.dart';
import 'dev/dev_page.dart';

class AppRoutes {
  static const String loginPhone = '/login/phone';
  static const String loginGuideline = '/login/guideline';
  static const String loginOnboarding = '/login/onboarding';
  static const String circleCreate = '/circle_scheduled/create';
  static const String snapCircleCreate = '/circle/create';
  static const String appSettings = '/settings';
  static const String userProfile = '/profile';
  static const String circle = '/circle';
  static const String dev = '/dev';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginPhone:
        return FadeRoute(
          page: const RegisterPage(),
          settings: settings,
        );
      case loginGuideline:
        return FadeRoute(
          page: const GuidelineScreen(),
          settings: settings,
        );
      case loginOnboarding:
        return FadeRoute(
          page: const OnboardingProfilePage(),
          settings: settings,
        );
      case circleCreate:
        return MaterialPageRoute(
          builder: (_) => const CircleCreatePage(),
          settings: settings,
        );
      case snapCircleCreate:
        return MaterialPageRoute(
          builder: (_) => const CircleCreateSnapPage(),
          settings: settings,
        );
      case appSettings:
        return MaterialPageRoute(
          builder: (_) => LoggedinGuard(builder: (_) => const SettingsPage()),
          settings: settings,
        );
      case userProfile:
        return MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) =>
              LoggedinGuard(builder: (_) => const UserProfilePage()),
          settings: settings,
        );
      case circle:
        Map<String, dynamic>? data =
            settings.arguments as Map<String, dynamic>?;
        if (data != null) {
          SnapSession session = data['session'];
          return PageRouteBuilder(
              opaque: false,
              fullscreenDialog: true,
              pageBuilder: (_, Animation<double> animation,
                      Animation<double> secondaryAnimation) =>
                  CircleSessionPage(
                    session: session,
                  ),
              settings: settings);
        }
        break;
      case dev:
        return MaterialPageRoute(
          builder: (_) => const DevPage(),
          settings: settings,
        );
      default:
        return null;
    }
    return null;
  }
}
