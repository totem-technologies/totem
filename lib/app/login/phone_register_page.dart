import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/login/components/phone_register_code_entry.dart';
import 'package:totem/app/login/components/phone_register_number_entry.dart';
import 'package:totem/app/login/components/phone_register_number_error.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  late Stream<AuthRequestState> _requestStateStream;
  late StreamSubscription _subscription;
  @override
  void initState() {
    final auth = ref.read(authServiceProvider);
    _requestStateStream = auth.onAuthRequestStateChanged;
    _subscription = _requestStateStream.listen((event) {
      if (event == AuthRequestState.complete) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.loginGuideline,
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      rotation: Theme.of(context).backgroundGradientRotation,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            // call this method here to hide soft keyboard
            FocusScope.of(context).unfocus();
          },
          child: SafeArea(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: StreamBuilder<AuthRequestState>(
                    stream: _requestStateStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        switch (snapshot.data!) {
                          case AuthRequestState.failed:
                            return const PhoneRegisterNumberError();
                          case AuthRequestState.pending:
                            return const PhoneRegisterCodeEntry();
                          case AuthRequestState.complete:
                            // this gets handled by stream
                            return Container();
                          case AuthRequestState.entry:
                          default:
                            return const PhoneRegisterNumberEntry();
                        }
                      }
                      // nothing available yet
                      return Container();
                    }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
