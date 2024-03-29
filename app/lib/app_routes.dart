import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:totem/app/startup_events/startup_events_screen.dart';
import 'package:totem/services/account_state/account_state_event_manager.dart';
import 'package:totem/theme/index.dart';

import 'app/index.dart';
import 'components/widgets/dialog_container.dart';
import 'dev/dev_page.dart';
import 'models/index.dart';
import 'services/index.dart';

export 'package:go_router/src/misc/extensions.dart';

class GoRouterRefreshStreams extends ChangeNotifier {
  late final List<StreamSubscription<dynamic>> _subscriptions;
  GoRouterRefreshStreams(List<Stream<dynamic>> streams) {
    notifyListeners();
    _subscriptions = streams.map((stream) {
      return stream.asBroadcastStream().listen(
            (dynamic _) => notifyListeners(),
          );
    }).toList();
  }

  @override
  void dispose() {
    void cancel(StreamSubscription<dynamic> e) {
      e.cancel();
    }

    _subscriptions.forEach(cancel);
    super.dispose();
  }
}

class AppRoutes {
  static const String home = 'home';
  static const String login = 'login';
  static const String loginPhone = 'phone';
  static const String loginGuideline = 'guideline';
  static const String loginOnboarding = 'onboarding';
  static const String circle = "circle";
  static const String circleCreateScheduled = 'scheduledcreate';
  static const String circleCreate = 'create';
  static const String circleEnded = 'circleEnded';
  static const String userProfile = 'profile';
  static const String dev = 'dev';

  static AppRoutes? _instance;
  static AppRoutes get instance {
    _instance ??= AppRoutes();
    return _instance!;
  }

  String? _pendingRoute;

  GoRouter getRouter(WidgetRef ref) {
    return GoRouter(
      // debugLogDiagnostics: true,
      observers: [SentryNavigatorObserver()],
      routes: <GoRoute>[
        GoRoute(
          name: home,
          path: '/',
          pageBuilder: (context, state) =>
              _fadeTransitionPage(state: state, child: const HomePage()),
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
                final id = state.pathParameters['id'] ?? '';
                state.pathParameters['id'];
                return _fadeTransitionPage(
                    state: state,
                    child: WithForegroundTask(
                        child: CircleSessionPage(sessionID: id)),
                    opaque: false,
                    fullscreenDialog: true);
              },
            ),
            GoRoute(
              name: circleCreate,
              path: 'create',
              pageBuilder: (context, state) {
                CircleTemplate? template = state.extra as CircleTemplate?;
                return MaterialPage(
                    child: CircleCreatePage(fromCircle: template),
                    fullscreenDialog: true);
              },
            ),
            GoRoute(
              name: circleEnded,
              path: 'ended',
              pageBuilder: (context, state) {
                Map<String, dynamic> extra = Map<String, dynamic>.from(
                    state.extra as Map? ?? <String, dynamic>{});
                final bool removed = extra['removed'] as bool? ?? false;
                final Circle? circle = extra['circle'] as Circle?;
                final SessionState sessionState =
                    extra['state'] as SessionState? ?? SessionState.complete;
                return _fadeTransitionPage(
                    state: state,
                    child: CircleSessionEndedPage(
                        removed: removed,
                        circle: circle,
                        sessionState: sessionState),
                    opaque: false,
                    fullscreenDialog: true);
              },
            )
          ],
        ),
        GoRoute(
          path: '/startup',
          pageBuilder: (context, state) => _fadeTransitionPage(
            state: state,
            child: const StartupEventsScreen(),
          ),
        ),
        GoRoute(
          name: dev,
          path: '/dev',
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
      redirect: (context, state) async {
        debugPrint(
            'Router redirect: ${state.fullPath}, query: ${state.pathParameters}');
        // Is there a logged in user?
        UserAuthAccountState? user =
            ref.read(userAccountStateProvider).asData?.value;
        final loggedIn = user != null && user.isLoggedIn;

        // Authenticated user should not be hitting the login page,
        // so redirect to the home page if this is the case.
        if (loggedIn && state.matchedLocation.contains('/login')) {
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
            publicPrefixes.any((e) => state.matchedLocation.startsWith(e));
        if (isPublic) return null;

        // Any other route that isn't public should require the user
        // to be logged in, so send to login page if not
        // if the route is a circle, then preserve the route and redirect after
        // login
        if (!loggedIn) {
          _pendingRoute = state.uri.toString();
          return '/login';
        }

        // Check for authenticated events
        final accountEventsMgr = ref.read(accountStateEventManager);
        if (accountEventsMgr.shouldShowEvents(AccountStateEventType.startup)) {
          if (state.matchedLocation == '/startup') {
            return null;
          }
          _pendingRoute = state.uri.toString();
          return '/startup';
        }

        // check for any pending routes and restore them
        if (_pendingRoute != null) {
          String path = _pendingRoute!;
          _pendingRoute = null;
          return path;
        }

        // if this is a snap circle link, redirect to the circle page
        if (state.matchedLocation == '/' &&
            state.uri.queryParameters.containsKey('snap')) {
          return '/circle/${state.uri.queryParameters['snap']}';
        }

        // the ended path can only be accessed if the extra data is
        // provided, otherwise redirect to the home page
        if (state.matchedLocation == '/ended' && state.extra == null) {
          return null; // '/';
        }

        // no need to redirect at all
        return null;
      },
      refreshListenable:
          // ignore: deprecated_member_use
          GoRouterRefreshStreams([ref.read(userAccountStateProvider.stream)]),
    );
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

class DialogPage<T> extends Page<T> {
  final Widget child;
  final double? maxWidth;
  const DialogPage({required this.child, super.key, this.maxWidth});

  @override
  Route<T> createRoute(BuildContext context) => DialogRoute<T>(
      context: context,
      settings: this,
      barrierColor: Theme.of(context).themeColors.blurBackground,
      builder: (context) => Material(
            color: Colors.transparent,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
              child: Center(
                child: SingleChildScrollView(
                  child: DialogContainer(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth:
                              maxWidth ?? Theme.of(context).maxRenderWidth),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ));
}
