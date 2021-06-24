import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../components/TextFormField.dart';
import '../../components/Button.dart';

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
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
                child: TotemTextFormField(
              hintText: '+1 555-555-5555',
              controller: phoneController,
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a phone number';
                }
                return null;
              },
            )),
          ),
          Text(error, style: TextStyle(color: Colors.red)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: TotemButton(
                onPressed: (stop) async {
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
                text: 'Submit',
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
        body: Container(
            color: Colors.black,
            child: Center(
                child: Column(children: [
              Padding(
                  padding: EdgeInsets.only(top: 100, bottom: 40),
                  child: Text(
                    'Enter phone number',
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                    ),
                  )),
              PhoneForm(),
              TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/home'),
                  child: Text('hj'))
            ]))));
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
                onPressed: (stop) async {
                  setState(() => error = '');
                  if (_formKey.currentState!.validate()) {
                    final args = ModalRoute.of(context)!.settings.arguments
                        as Map<String, String>;
                    var credential = PhoneAuthProvider.credential(
                        verificationId: args['verificationId'] ?? '',
                        smsCode: codeController.text);
                    await auth.signInWithCredential(credential);
                    await Navigator.pushReplacementNamed(context, '/');
                  }
                },
                text: 'Submit',
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
