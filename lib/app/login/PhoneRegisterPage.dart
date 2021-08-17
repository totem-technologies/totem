import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:totem/components/constants.dart';
import 'package:totem/components/widgets/Button.dart';
import 'package:totem/app/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  String initialCountry = 'US';
  PhoneNumber numberController = PhoneNumber(isoCode: 'US');
  String error = '';

  void onSubmit(Function stop) async {
    var auth = context.read(firebaseAuthProvider);
    setState(() => error = '');
    // Validate returns true if the form is valid, or false otherwise.
    if (formKey.currentState!.validate()) {
      var number = _phoneNumberController.text;
      if (!number.startsWith('+')) {
        if (number.length == 10) {
          // US user only input 10 digits
          number = '1' + number;
        }
        number = '+' + number;
      }
      print(number);
      await auth.verifyPhoneNumber(
        phoneNumber: number,
        verificationCompleted: (PhoneAuthCredential credential) async {
          stop();
          // Android only
          print('verificationCompleted');
          await auth.signInWithCredential(credential);
          await Navigator.pushNamedAndRemoveUntil(
              context, '/login/guideline', (Route<dynamic> route) => false);
        },
        verificationFailed: (FirebaseAuthException e) {
          stop();
          setState(() => error = e.message ?? '');
          print('verificationFailed');
        },
        codeSent: (String verificationId, int? resendToken) {
          stop();
          print('codeSent');
          Navigator.pushNamed(context, '/login/phone/code',
              arguments: {'verificationId': verificationId});
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          stop();
          print('codeAutoRetrievalTimeout');
        },
      );
    } else {
      stop();
    }
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
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
                  padding: EdgeInsets.only(top: 5.h),
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
                  'Enter your Phone Number',
                  style: white16BoldTextStyle,
                ),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                  'We will send you a code to login',
                  style: white16NormalTextStyle,
                ),
                SizedBox(
                  height: 90.h,
                ),

                ///Country Picker and textField
                Form(
                  key: formKey,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InternationalPhoneNumberInput(
                          onInputChanged: (PhoneNumber number) {
                            print(number.phoneNumber);
                          },
                          onInputValidated: (bool value) {
                            print(value);
                          },
                          selectorConfig: SelectorConfig(
                            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                            showFlags: true,
                            trailingSpace: false,
                          ),
                          ignoreBlank: false,
                          autoValidateMode: AutovalidateMode.disabled,
                          selectorTextStyle: white16NormalTextStyle,
                          initialValue: numberController,
                          textFieldController: _phoneNumberController,
                          formatInput: false,
                          textStyle: white16NormalTextStyle,
                          hintText: 'Phone Number',
                          cursorColor: Colors.white,
                          inputDecoration: InputDecoration(
                            hintStyle: white16NormalTextStyle,
                            hintText: 'Phone Number',
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                              signed: true, decimal: true),
                          onSaved: (PhoneNumber number) {
                            print('On Saved: $number');
                            numberController = number;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Container(
                              child: Text(
                            error,
                            style: TextStyle(color: Colors.red),
                            maxLines: 2,
                          )),
                        ),
                        SizedBox(
                          height: 30.h,
                        ),
                        TotemContinueButton(
                          onButtonPressed: onSubmit,
                          buttonText: 'Submit',
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
