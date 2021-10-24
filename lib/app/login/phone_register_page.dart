import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/login/components/phone_register_code_entry.dart';
import 'package:totem/app/login/components/phone_register_number_entry.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/app/providers.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  late Stream<AuthRequestState> _requestStateStream;

  @override
  void initState() {
    var auth = context.read(authServiceProvider);
    _requestStateStream = auth.onAuthRequestStateChanged;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
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
                          case AuthRequestState.pending:
                            return const PhoneRegisterCodeEntry();
                          case AuthRequestState.entry:
                          default:
                            return const PhoneRegisterNumberEntry();
                        }
                      }
                      // nothing available yet
                      return Container();
                    }
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
