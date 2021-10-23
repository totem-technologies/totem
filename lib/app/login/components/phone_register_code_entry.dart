import 'package:flutter/material.dart';
import 'package:totem/components/constants.dart';
import 'package:totem/components/widgets/buttons.dart';
import 'package:totem/app/providers.dart';
import 'package:totem/app/login/pin_code_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/services/auth/index.dart';
import 'package:totem/services/index.dart';

class PhoneRegisterCodeEntry extends StatefulWidget {
  const PhoneRegisterCodeEntry({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PhoneRegisterCodeEntryState();
}

final errors = {'invalid-verification-code': 'Invalid code. Please try again.'};

class _PhoneRegisterCodeEntryState extends State<PhoneRegisterCodeEntry> {
  final _formKey = GlobalKey<FormState>();
  final AutovalidateMode _autoValidate = AutovalidateMode.disabled;

  String pinValue = '';
  String error = '';

  ///Validates OTP code
  void signInWithPhoneNumber(Function stop) async {
    try {
      await context.read(authServiceProvider).verifyCode(pinValue);
      await Navigator.pushReplacementNamed(context, '/login/guideline',);
    } on AuthException catch (e) {
      setState(() => error = e.message!);
      debugPrint('Error:$e');
    } finally {
      stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Localized.of(context).t;
    final textStyles = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(left: 35.w, right: 35.w),
      child: Column(
        children: [
          SizedBox(
            height: 40.h,
          ),
          Text(t('signup'), style: textStyles.headline1),
          const ContentDivider(),
          SizedBox(
            height: 20.h,
          ),
          Text(
            'Enter your Code',
            style: white16BoldTextStyle,
          ),
          SizedBox(
            height: 90.h,
          ),

          ///OTP textFields
          Form(
              key: _formKey,
              autovalidateMode: _autoValidate,
              child: PinCodeWidget(
                onChanged: (v) {
                  setState(() => error = '');
                  pinValue = v;
                },
                onComplete: (v) {
                  pinValue = v;
                },
              )),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              error,
              style: const TextStyle(color: Colors.red),
              maxLines: 2,
            ),
          ),
          SizedBox(
            height: 80.h,
          ),
          TotemContinueButton(
            onButtonPressed: (stop) async {
              setState(() => error = '');
              var isSixDigits =
                  pinValue.length == 6 && int.tryParse(pinValue) != null;
              if (!isSixDigits) {
                setState(() => error = 'Please enter a 6 digit code');
                stop();
              } else if (_formKey.currentState!.validate()) {
                signInWithPhoneNumber(stop);
              }
            },
            buttonText: 'Submit',
          ),
        ],
      ),
    );
  }
}
