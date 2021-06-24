import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/providers.dart';

class AuthWidget extends ConsumerWidget {
  const AuthWidget({
    Key? key,
    required this.signedInBuilder,
    required this.nonSignedInBuilder,
  }) : super(key: key);
  final WidgetBuilder nonSignedInBuilder;
  final WidgetBuilder signedInBuilder;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final authStateChanges = watch(authStateChangesProvider);
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

  Widget _data(BuildContext context, User? user) {
    if (user != null && !user.isAnonymous) {
      return signedInBuilder(context);
    }
    return nonSignedInBuilder(context);
  }
}

class LoggedinGuard extends ConsumerWidget {
  const LoggedinGuard({Key? key, required this.builder}) : super(key: key);
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final authStateChanges = watch(authStateChangesProvider);
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

  Widget _data(BuildContext context, User? user) {
    if (user != null && !user.isAnonymous) {
      return builder(context);
    }
    return EmptyContent();
  }
}

class EmptyContent extends StatelessWidget {
  const EmptyContent({
    Key? key,
    this.title = 'Nothing here',
    this.message = 'Add a new item to get started',
  }) : super(key: key);
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontSize: 32.0, color: Colors.black54),
          ),
          Text(
            message,
            style: const TextStyle(fontSize: 16.0, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
