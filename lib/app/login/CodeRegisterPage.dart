import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:totem/components/constants.dart';
import 'package:totem/components/widgets/Button.dart';
import 'package:totem/app/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CodeRegisterPage extends StatefulWidget {
  const CodeRegisterPage({Key? key}) : super(key: key);

  @override
  _CodeRegisterPageState createState() => _CodeRegisterPageState();
}

class _CodeRegisterPageState extends State<CodeRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final AutovalidateMode _autoValidate = AutovalidateMode.disabled;

  late FocusNode pin2FocusNode;
  late FocusNode pin3FocusNode;
  late FocusNode pin4FocusNode;
  late FocusNode pin5FocusNode;
  late FocusNode pin6FocusNode;

  late String pin1;
  late String pin2;
  late String pin3;
  late String pin4;
  late String pin5;
  late String pin6;
  final TextEditingController _smsController1 = TextEditingController();
  final TextEditingController _smsController2 = TextEditingController();
  final TextEditingController _smsController3 = TextEditingController();
  final TextEditingController _smsController4 = TextEditingController();
  final TextEditingController _smsController5 = TextEditingController();
  final TextEditingController _smsController6 = TextEditingController();
  late User user;
  String error = '';
  bool isLoggedIn = false;
  String name = '';
  late String otpValue;

  ///Validates OTP code
  void signInWithPhoneNumber(Function stop) async {
    try {
      otpValue = _smsController1.text +
          _smsController2.text +
          _smsController3.text +
          _smsController4.text +
          _smsController5.text +
          _smsController6.text;
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, String>;
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: args['verificationId'] ?? '',
        smsCode: otpValue,
      );

      user = (await context
              .read(firebaseAuthProvider)
              .signInWithCredential(credential))
          .user!;

      print(user.uid);

      stop();

      ///New screen after successful validation
      await Navigator.pushNamedAndRemoveUntil(
          context, '/login/guideline', (Route<dynamic> route) => false);
    } catch (e) {
      stop();
      setState(() => error = '$e');
      print('Error:$e');
    }
  }

  @override
  void initState() {
    super.initState();

    pin2FocusNode = FocusNode();
    pin3FocusNode = FocusNode();
    pin4FocusNode = FocusNode();
    pin5FocusNode = FocusNode();
    pin6FocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    pin2FocusNode.dispose();
    pin3FocusNode.dispose();
    pin4FocusNode.dispose();
    pin5FocusNode.dispose();
    pin6FocusNode.dispose();
  }

  void nextField(String value, FocusNode focusNode) {
    if (value.length == 1) {
      focusNode.requestFocus();
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
                  height: 10.h,
                ),
                Text(
                  'Enter the code',
                  style: white16NormalTextStyle,
                ),
                SizedBox(
                  height: 90.h,
                ),

                ///OTP textFields
                Form(
                  key: _formKey,
                  autovalidateMode: _autoValidate,
                  child: Column(
                    children: [
                      Wrap(
                        alignment: WrapAlignment.center,
                        runSpacing: 20.h,
                        spacing: 20.w,
                        children: [
                          SizedBox(
                            width: 50.w,
                            child: TextFormField(
                              controller: _smsController1,
                              cursorColor: Colors.white,
                              autofocus: true,
                              style: white16BoldTextStyle,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: otpInputDecoration,
                              onSaved: (newValue) => pin1 = newValue!,
                              onChanged: (value) {
                                nextField(value, pin2FocusNode);
                              },
                            ),
                          ),
                          SizedBox(
                            width: 50.w,
                            child: TextFormField(
                              controller: _smsController2,
                              cursorColor: Colors.white,
                              focusNode: pin2FocusNode,
                              style: white16BoldTextStyle,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: otpInputDecoration,
                              onSaved: (newValue) => pin2 = newValue!,
                              onChanged: (value) =>
                                  nextField(value, pin3FocusNode),
                            ),
                          ),
                          SizedBox(
                            width: 50.w,
                            child: TextFormField(
                              controller: _smsController3,
                              cursorColor: Colors.white,
                              focusNode: pin3FocusNode,
                              style: white16BoldTextStyle,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: otpInputDecoration,
                              onSaved: (newValue) => pin3 = newValue!,
                              onChanged: (value) =>
                                  nextField(value, pin4FocusNode),
                            ),
                          ),
                          SizedBox(
                            width: 50.w,
                            child: TextFormField(
                              controller: _smsController4,
                              cursorColor: Colors.white,
                              focusNode: pin4FocusNode,
                              style: white16BoldTextStyle,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: otpInputDecoration,
                              onSaved: (newValue) => pin4 = newValue!,
                              onChanged: (value) =>
                                  nextField(value, pin5FocusNode),
                            ),
                          ),
                          SizedBox(
                            width: 50.w,
                            child: TextFormField(
                              controller: _smsController5,
                              cursorColor: Colors.white,
                              focusNode: pin5FocusNode,
                              style: white16BoldTextStyle,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: otpInputDecoration,
                              onSaved: (newValue) => pin5 = newValue!,
                              onChanged: (value) =>
                                  nextField(value, pin6FocusNode),
                            ),
                          ),
                          SizedBox(
                            width: 50.w,
                            child: TextFormField(
                              controller: _smsController6,
                              cursorColor: Colors.white,
                              focusNode: pin6FocusNode,
                              style: white16BoldTextStyle,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: otpInputDecoration,
                              onSaved: (newValue) => pin6 = newValue!,
                              onChanged: (value) {
                                if (value.length == 1) {
                                  pin6FocusNode.unfocus();
                                  // Then you need to check is the code is correct or not
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 100.h,
                ),
                TotemContinueButton(
                  onButtonPressed: (stop) async {
                    setState(() => error = '');
                    if (_smsController1.text.isEmpty ||
                        _smsController2.text.isEmpty ||
                        _smsController3.text.isEmpty ||
                        _smsController4.text.isEmpty ||
                        _smsController5.text.isEmpty ||
                        _smsController6.text.isEmpty) {
                      setState(() => error = 'Please enter a code');
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
