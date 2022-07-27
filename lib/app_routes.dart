import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app/index.dart';
import 'dev/dev_page.dart';
import 'models/index.dart';
import 'services/index.dart';

export 'package:go_router/src/misc/extensions.dart';

class AppRoutes {
  static const String home = 'home';
  static const String login = 'login';
  static const String loginPhone = 'phone';
  static const String loginGuideline = 'guideline';
  static const String loginOnboarding = 'onboarding';
  static const String circle = "circle";
  static const String circleCreateScheduled = 'scheduledcreate';
  static const String circleCreate = 'create';
  static const String userProfile = 'profile';
  static const String dev = '/dev';

  static AppRoutes? _instance;
  static AppRoutes get instance {
    _instance ??= AppRoutes();
    return _instance!;
  }

  String? _pendingRoute;

  GoRouter getRouter(WidgetRef ref) {
    return GoRouter(
        observers: [
          SentryNavigatorObserver()
        ],
        routes: <GoRoute>[
          GoRoute(
            name: home,
            path: '/',
            pageBuilder: (context, state) => _fadeTransitionPage(
                state: state,
                child: const WithForegroundTask(child: HomePage())),
            routes: [
              GoRoute(
                name: userProfile,
                path: 'profile',
                builder: (context, state) => const UserProfilePage(),
              ),
              GoRoute(
                name: circle,
                path: 'circle/:id',
                pageBuilder: (context, state) {
                  final id = state.params['id'] ?? '';
                  state.params['id'];
                  return _fadeTransitionPage(
                      state: state,
                      child: CircleSessionPage(sessionID: id),
                      opaque: false,
                      fullscreenDialog: true);
                },
              ),
              GoRoute(
                name: circleCreate,
                path: 'create',
                pageBuilder: (context, state) => const MaterialPage(
                    child: CircleCreateSnapPage(), fullscreenDialog: true),
              ),
            ],
          ),
          GoRoute(
            path: dev,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DevPage()),
          ),
          GoRoute(
            name: login,
            path: '/login',
            pageBuilder: (BuildContext context, GoRouterState state) =>
                const NoTransitionPage(child: WelcomePage()),
            routes: [
              GoRoute(
                name: loginPhone,
                path: 'phone',
                pageBuilder: (context, state) => _fadeTransitionPage(
                  state: state,
                  child: const RegisterPage(),
                ),
              ),
            ],
          ),
        ],
        redirect: (state) {
          // Is there a logged in user?
          AuthUser? user = ref.read(authServiceProvider).currentUser();
          final loggedIn = user != null && !user.isAnonymous;

          // Authenticated user should not be hitting the login page,
          // so redirect to the home page if this is the case.
          if (loggedIn && state.subloc.contains(login)) {
            // Auth completed here, check for any pending links to circle
            // if there is, redirect to that
            if (_pendingRoute != null) {
              String path = _pendingRoute!;
              _pendingRoute = null;
              return path;
            }
            // otherwise just redirect to home
            return '/';
          }

          // Check if the route is public (non-login)?
          final publicPrefixes = ['/login', '/dev'];
          final isPublic =
              publicPrefixes.any((e) => state.subloc.startsWith(e));
          if (isPublic) return null;

          // Any other route that isn't public should require the user
          // to be logged in, so send to login page if not
          // if the route is a circle, then preserve the route and redirect after
          // login
          if (!loggedIn) {
            _pendingRoute = state.location;
            return '/login';
          }
          // if this is a snap circle link, redirect to the circle page
          if (state.subloc == home && state.queryParams.containsKey('snap')) {
            return '${home}circle/${state.queryParams['snap']}';
          }
          // no need to redirect at all
          return null;
        },
        refreshListenable: GoRouterRefreshStream(
            ref.read(authServiceProvider).onAuthStateChanged));
  }

  Page<void> _fadeTransitionPage({
    required GoRouterState state,
    required Widget child,
    bool opaque = true,
    bool fullscreenDialog = false,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      opaque: opaque,
      fullscreenDialog: fullscreenDialog,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
}
