import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/applinks/index.dart';
import 'package:totem/services/index.dart';

import 'circle/circle_join_dialog.dart';

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
    if (user != null && !user.isAnonymous) {
      repo.user = user;

      return widget.signedInBuilder(context);
    }
    repo.user = null;
    return widget.nonSignedInBuilder(context);
  }

  void _handleAppLink(AppLink? link) async {
    if (link != null) {
      Future.delayed(const Duration(milliseconds: 2000), () async {
        if (link.type == AppLinkType.snapSession) {
          var repo = ref.read(repositoryProvider);
          SnapCircle? circle = await repo.circleFromId(link.value);
          if (circle != null) {
            String? sessionImage = await CircleJoinDialog.showDialog(context,
                session: circle.snapSession);
            if (sessionImage != null && sessionImage.isNotEmpty) {
              await repo.createActiveSession(
                session: circle.activeSession!,
              );
              Future.delayed(const Duration(milliseconds: 300), () async {
                Navigator.of(context).pushNamed(AppRoutes.circle, arguments: {
                  'session': circle.snapSession,
                  'image': sessionImage,
                });
              });
            }
          }
        }
      });
    }
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
