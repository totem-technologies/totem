import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/login/components/phone_register_code_entry.dart';
import 'package:totem/app/login/components/phone_register_number_entry.dart';
import 'package:totem/app/login/components/phone_register_number_error.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/theme/index.dart';

enum RegisterState {
  phone,
  code,
  error,
}

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({Key? key, required this.state}) : super(key: key);
  final RegisterState state;

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  @override
  void dispose() {
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
                child: Builder(builder: (context) {
                  switch (widget.state) {
                    case RegisterState.error:
                      return const PhoneRegisterNumberError();
                    case RegisterState.code:
                      return const PhoneRegisterCodeEntry();
                    case RegisterState.phone:
                    default:
                      return const PhoneRegisterNumberEntry();
                  }
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
