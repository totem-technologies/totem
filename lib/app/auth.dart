import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/applinks/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

class AuthWidget extends ConsumerStatefulWidget {
  const AuthWidget({
    Key? key,
    required this.signedInBuilder,
    required this.nonSignedInBuilder,
  }) : super(key: key);
  final WidgetBuilder nonSignedInBuilder;
  final WidgetBuilder signedInBuilder;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthWidget();
}

class _AuthWidget extends ConsumerState<AuthWidget> {
  late AppLinks _appLinks;
  late StreamSubscription _streamSubscription;
  AppLink? _pendingLink;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks.instance;
    _streamSubscription = _appLinks.linkStream.listen((link) {
      _handleAppLink(link);
    });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authStateChanges = ref.watch(authStateChangesProvider);
    final repo = ref.watch(repositoryProvider);
    return authStateChanges.when(
      data: (user) => _data(context, repo, user),
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => const Scaffold(
        body: EmptyContent(
          title: 'Something went wrong',
          message: 'Can\'t load data right now.',
        ),
      ),
    );
  }

  Widget _data(BuildContext context, TotemRepository repo, AuthUser? user) {
    ref.read(analyticsProvider).setAuthUser(user);
    if (user != null && !user.isAnonymous) {
      repo.user = user;
      if (_pendingLink != null) {
        AppLink link = _pendingLink!;
        _pendingLink = null;
        _handleAppLink(link, delay: 1000);
      }
      return widget.signedInBuilder(context);
    }
    repo.user = null;
    return widget.nonSignedInBuilder(context);
  }

  void _handleAppLink(AppLink? link, {int delay = 2000}) async {
    if (link != null) {
      Future.delayed(Duration(milliseconds: delay), () async {
        if (link.type == AppLinkType.snapSession) {
          var auth = ref.read(authServiceProvider);
          var repo = ref.read(repositoryProvider);
          if (auth.currentUser() != null) {
            SnapCircle? circle = await repo.circleFromId(link.value);
            if (circle != null) {
              if (!mounted) return;
              if (circle.state != SessionState.complete &&
                  circle.state != SessionState.cancelled) {
                _joinCircle(circle, repo);
              } else {
                // Make sure there isn't a new one already started as well,
                // should only be 1 that is waiting with a previous circle referencing this one
                SnapCircle? pending = await repo.circleFromPreviousIdAndState(
                    circle.id, SessionState.waiting);
                if (pending == null) {
                  // this is a create new circle moment
                  SnapCircle? newCircle = await repo.createSnapCircle(
                      name: circle.name,
                      description: circle.description,
                      keeper: circle.keeper,
                      previousCircle: circle.id);
                  if (newCircle != null) {
                    _joinCircle(newCircle, repo);
                  } else {
                    await _promptMissingCircle();
                  }
                } else {
                  // join the pending one
                  _joinCircle(pending, repo);
                }
              }
            } else {
              // circle doesn't exist... give an uh-oh message!
              await _promptMissingCircle();
            }
          } else {
            // cache as a pending link
            _pendingLink = link;
          }
        }
      });
    }
  }

  void _joinCircle(SnapCircle circle, TotemRepository repo) async {
    await repo.createActiveSession(
      circle: circle,
    );
    if (!mounted) return;
    //await Navigator.of(context).pushNamed(AppRoutes.circleRoute(circle.snapSession.id));
  }

  Future<void> _promptMissingCircle() async {
    final t = AppLocalizations.of(context)!;
    await showDialog<bool>(
      context: context,
      /*it shows a popup with few options which you can select, for option we
        created enums which we can use with switch statement, in this first switch
        will wait for the user to select the option which it can use with switch cases*/
      builder: (BuildContext context) {
        final actions = [
          TextButton(
            child: Text(t.ok),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ];
        return AlertDialog(
          title: Text(
            t.circleDoesNotExist,
          ),
          content: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: Theme.of(context).maxRenderWidth),
            child: Text(t.circleDoesNotExistMessage),
          ),
          actions: actions,
        );
      },
    );
  }
}

class LoggedinGuard extends ConsumerWidget {
  const LoggedinGuard({Key? key, required this.builder}) : super(key: key);
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateChanges = ref.watch(authStateChangesProvider);
    return authStateChanges.when(
      data: (user) => _data(context, user),
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => const Scaffold(
        body: EmptyContent(
          title: 'Something went wrong',
          message: 'Can\'t load data right now.',
        ),
      ),
    );
  }

  Widget _data(BuildContext context, AuthUser? user) {
    if (user != null && !user.isAnonymous) {
      return builder(context);
    }
    return const EmptyContent(title: 'You are now logged out', message: '');
  }
}

class EmptyContent extends StatelessWidget {
  const EmptyContent({
    Key? key,
    this.title = 'Nothing here',
    this.message = '',
  }) : super(key: key);
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontSize: 32.0, color: Colors.white),
            ),
            Text(
              message,
              style: const TextStyle(fontSize: 16.0, color: Colors.white),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 50, bottom: 40),
            ),
            ThemedRaisedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (Route<dynamic> route) => false);
                },
                label: 'Go Home')
          ],
        ),
      ),
    );
  }
}
