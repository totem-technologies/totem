import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:go_router/go_router.dart';

import 'app/index.dart';
import 'components/index.dart';
import 'dev/dev_page.dart';
import 'models/index.dart';
import 'services/index.dart';

export 'package:go_router/src/misc/extensions.dart';

class AppRoutes {
  static const String home = '/';
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
        Circle? circle;
        if (settings.arguments != null) {
          circle = settings.arguments as Circle?;
        }
        return MaterialPageRoute(
          builder: (_) => CircleCreateSnapPage(fromCircle: circle),
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
        // case circle:
        //   Map<String, dynamic>? data =
        //       settings.arguments as Map<String, dynamic>?;
        //   if (data != null) {
        //     SnapSession session = data['session'];
        //     return PageRouteBuilder(
        //         opaque: false,
        //         fullscreenDialog: true,
        //         pageBuilder: (_, Animation<double> animation,
        //                 Animation<double> secondaryAnimation) =>
        //             CircleSessionPage(
        //               session: session,
        //             ),
        //         settings: settings);
        //   }
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

GoRouter getRouter(WidgetRef ref) {
  return GoRouter(
      observers: [
        SentryNavigatorObserver()
      ],
      routes: <GoRoute>[
        GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) =>
                const WithForegroundTask(child: HomePage()),
            routes: [
              GoRoute(
                path: 'profile',
                pageBuilder: (context, state) {
                  return const MaterialPage(
                    fullscreenDialog: true,
                    child: UserProfilePage(),
                  );
                },
              ),
              GoRoute(
                path: 'circle/:id',
                pageBuilder: (context, state) {
                  final id = state.params['id'] ?? '';
                  state.params['id'];
                  return MaterialPage(
                    fullscreenDialog: true,
                    child: CircleSessionPage(sessionID: id),
                  );
                },
              )
            ]),
        GoRoute(
          path: '/dev',
          pageBuilder: (context, state) => const MaterialPage(child: DevPage()),
        ),
        GoRoute(
            path: '/login',
            builder: (BuildContext context, GoRouterState state) =>
                const LoginPage(),
            routes: [
              GoRoute(
                path: 'phone',
                builder: (context, state) => const RegisterPage(),
              )
            ]),
      ],
      redirect: (state) {
        // Check if the route is public (non-login)?
        final publicPrefixes = ['/login', '/dev'];
        final isPublic = publicPrefixes.any((e) => state.subloc.startsWith(e));
        if (isPublic) return null;

        // Is there a loggedin user?
        AuthUser? user = ref.read(authServiceProvider).currentUser();
        final loggedIn = user != null && !user.isAnonymous;
        if (!loggedIn) return '/login';

        // no need to redirect at all
        return null;
      },
      refreshListenable: GoRouterRefreshStream(
          ref.read(authServiceProvider).onAuthStateChanged));
}
