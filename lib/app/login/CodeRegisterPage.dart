import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:totem/components/constance.dart';
import 'package:totem/components/widgets/Button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../guideline_screen.dart';


class CodeRegisterPage2 extends StatefulWidget {
  @override
  _CodeRegisterPage2State createState() => _CodeRegisterPage2State();
}

class _CodeRegisterPage2State extends State<CodeRegisterPage2> {
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User user;
  late SharedPreferences prefs;
  String error = '';
  bool isLoggedIn = false;
  String name = '';
  late String otpValue;

  ///Getting SMS

  ///Validates OTP code
  void signInWithPhoneNumber2(Function stop) async {
    try {
      otpValue = _smsController1.text +
          _smsController2.text +
          _smsController3.text +
          _smsController4.text +
          _smsController5.text +
          _smsController6.text;
      final args = ModalRoute.of(context)!.settings.arguments
      as Map<String, String>;
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: args['verificationId'] ?? '',
        smsCode: otpValue,
      );

      user = (await _auth.signInWithCredential(credential)).user!;

      print(user.uid);

      prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', user.uid);

      await Fluttertoast.showToast(
          msg: "You're logged-in with ${user.uid}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0
      );

      stop();
      ///New screen after successful validation
      await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => GuidelineScreen(user.uid)), (Route<dynamic> route) => false
      );
    } catch (e) {
      stop();
      print('Error:$e');
    }
  }

/*  ///Validates OTP code
  void signInWithPhoneNumber(Function stop) async {
    try {
      var otpValue = _smsController1.text +
          _smsController2.text +
          _smsController3.text +
          _smsController4.text +
          _smsController5.text +
          _smsController6.text;
      final args = ModalRoute.of(context)!.settings.arguments
      as Map<String, String>;

      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: args['verificationId'] ?? '',
        smsCode: otpValue,
      );
        await _auth.signInWithCredential(credential);
        user = (await _auth.signInWithCredential(credential)).user!;
        print(user.uid);

        prefs = await SharedPreferences.getInstance();
        await prefs.setString('uid', user.uid);
      await Fluttertoast.showToast(
          msg: "You're logged-in",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0
      );

      ///New screen after successful validation
      await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => GuidelineScreen(user.uid)), (Route<dynamic> route) => false
      );
      stop();


    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        setState(() => error =
        'The code entered was invalid. Please try again.');
      }
      stop();
      return;
    }
  }*/

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
                  "Signup",
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
                  "Enter your Code",
                  style: white16BoldTextStyle,
                ),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                  "Enter the 4 digit code",
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
                      //SizedBox(height: SizeConfig.screenHeight * 0.15),
                      Wrap(
                        //crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        runSpacing: 20.h,
                        spacing: 20.w,
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                TotemButton(
                  onButtonPressed: (stop) async {
                    setState(() => error = '');
                    if(_smsController1.text.isEmpty ||
                        _smsController2.text.isEmpty ||
                        _smsController3.text.isEmpty ||
                        _smsController4.text.isEmpty ||
                        _smsController5.text.isEmpty ||
                        _smsController6.text.isEmpty){
                      setState(() => error =
                      'Please enter a code');
                    }
                    else if (_formKey.currentState!.validate()) {
                      signInWithPhoneNumber2(stop);
                    }
                  },
                  buttonText: 'Submit', showArrow: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}