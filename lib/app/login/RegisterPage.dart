import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:totem/components/constance.dart';
import 'package:totem/components/widgets/Button.dart';
import 'package:totem/components/widgets/Header.dart';
import 'package:totem/components/widgets/TextFormField.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PhoneForm extends StatefulWidget {
  @override
  PhoneFormState createState() {
    return PhoneFormState();
  }
}

class PhoneFormState extends State<PhoneForm> {
  final _formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  String error = '';
  String initialCountry = 'US';
  PhoneNumber numberController = PhoneNumber(isoCode: 'US');

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var auth = FirebaseAuth.instance;
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
/*          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
                child: TotemTextFormField(
              hintText: '+1 555-555-5555',
              controller: phoneController,
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a phone number in the form of +1 555-555-5555';
                }
                return null;
              },
            )),
          ),*/
          Padding(
            padding:  EdgeInsets.all(20.h),
            child: InternationalPhoneNumberInput(
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
              validator:(value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a phone number in the form of +1 555-555-5555';
                }
                return null;
              } ,
              selectorTextStyle: white16NormalTextStyle,
              initialValue: numberController,
              textFieldController: phoneController,
              formatInput: false,
              textStyle: white16NormalTextStyle,
              cursorColor: Colors.white,
              inputDecoration: InputDecoration(
                hintStyle: white16NormalTextStyle,
                hintText: '555-555-5555',
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
              //inputBorder: OutlineInputBorder(),

              onSaved: (PhoneNumber number) {
                print('On Saved: $number');
                numberController = number;
              },
            ),
          ),
          Container(child: Text(error, style: TextStyle(color: Colors.red),maxLines: 2,)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: TotemButton(
                onButtonPressed: (stop) async {
                  setState(() => error = '');
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    var number = phoneController.text;
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
                      verificationCompleted:
                          (PhoneAuthCredential credential) async {
                        stop();
                        // Android only
                        await auth.signInWithCredential(credential);
                        print('verificationCompleted');
                        await Navigator.pushReplacementNamed(context, '/');
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
                },
                buttonText: 'Submit', showArrow: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Center(
              child: Column(children: [
            Padding(
                padding: EdgeInsets.only(top: 100),
                child: TotemHeader(
                  text: 'Enter phone number',
                )),
            PhoneForm()
          ])),
        ));
  }
}

// Create a Form widget.
class CodeForm extends StatefulWidget {
  @override
  CodeFormState createState() {
    return CodeFormState();
  }
}

class CodeFormState extends State<CodeForm> {
  final _formKey = GlobalKey<FormState>();
  final codeController = TextEditingController();
  String error = '';

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var auth = FirebaseAuth.instance;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              child: TotemTextFormField(
            hintText: '132456',
            controller: codeController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a code';
              }
              return null;
            },
          )),
          Text(error, style: TextStyle(color: Colors.red)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: TotemButton(
                onButtonPressed: (stop) async {
                  setState(() => error = '');
                  if (_formKey.currentState!.validate()) {
                    final args = ModalRoute.of(context)!.settings.arguments
                        as Map<String, String>;
                    var credential = PhoneAuthProvider.credential(
                        verificationId: args['verificationId'] ?? '',
                        smsCode: codeController.text);
                    try {
                      await auth.signInWithCredential(credential);
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'invalid-verification-code') {
                        setState(() => error =
                            'The code entered was invalid. Please try again.');
                      }
                      stop();
                      return;
                    }
                    stop();
                    await Navigator.pushReplacementNamed(context, '/');
                  }
                },
                buttonText: 'Submit', showArrow: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CodeRegisterPage extends StatefulWidget {
  @override
  _CodeRegisterPageState createState() => _CodeRegisterPageState();
}

class _CodeRegisterPageState extends State<CodeRegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: Colors.black,
            child: Center(
                child: Column(children: [
              Padding(
                  padding: EdgeInsets.only(top: 100, bottom: 40),
                  child: Text(
                    'Enter code',
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                    ),
                  )),
              CodeForm()
            ]))));
  }
}
