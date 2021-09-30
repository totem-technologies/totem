import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:totem/components/constants.dart';
import 'package:totem/components/widgets/buttons.dart';
import 'package:totem/app/providers.dart';
import 'package:totem/app/login/pin_code_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CodeRegisterPage extends StatefulWidget {
  const CodeRegisterPage({Key? key}) : super(key: key);

  @override
  _CodeRegisterPageState createState() => _CodeRegisterPageState();
}

final errors = {'invalid-verification-code': 'Invalid code. Please try again.'};

class _CodeRegisterPageState extends State<CodeRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final AutovalidateMode _autoValidate = AutovalidateMode.disabled;

  String pinValue = '';
  String error = '';

  ///Validates OTP code
  void signInWithPhoneNumber(Function stop) async {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: args['verificationId'] ?? '',
      smsCode: pinValue,
    );
    try {
      await context.read(firebaseAuthProvider).signInWithCredential(credential);

      ///New screen after successful validation
      await Navigator.pushNamedAndRemoveUntil(
          context, '/login/guideline', (Route<dynamic> route) => false);
    } on FirebaseAuthException catch (e) {
      if (errors.containsKey(e.code)) {
        setState(() => error = errors[e.code]!);
      } else {
        setState(() => error = e.message!);
      }
      debugPrint('Error:$e');
    } finally {
      stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 35.w, right: 35.w),
            child: Column(
              children: [
                SizedBox(
                  height: 40.h,
                ),
                Text(
                  'Signup',
                  style: white32BoldTextStyle,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5.w),
                  child: Container(
                    height: 5.h,
                    width: 90.w,
                    decoration: BoxDecoration(
                        color: yellowColor,
                        borderRadius: BorderRadius.circular(10.w)),
                  ),
                ),
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
          ),
        ),
      ),
    );
  }
}
