import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

// Create a Form widget.
class PhoneForm extends StatefulWidget {
  @override
  PhoneFormState createState() {
    return PhoneFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class PhoneFormState extends State<PhoneForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<PhoneFormState>.
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
          Container(
              color: Colors.white,
              child: TextFormField(
                controller: phoneController,
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              )),
          Text(error, style: TextStyle(color: Colors.red)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                setState(() => error = '');
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  await auth.verifyPhoneNumber(
                    phoneNumber: phoneController.text,
                    // phoneNumber: '+1 805 453 3502',
                    verificationCompleted:
                        (PhoneAuthCredential credential) async {
                      // Android only
                      await auth.signInWithCredential(credential);
                      print('verificationCompleted');
                    },
                    verificationFailed: (FirebaseAuthException e) {
                      setState(() => error = e.message ?? '');
                      print('verificationFailed');
                    },
                    codeSent: (String verificationId, int? resendToken) {
                      print('codeSent');
                      Navigator.pushNamed(context, '/login/phone/code',
                          arguments: {'verificationId': verificationId});
                    },
                    codeAutoRetrievalTimeout: (String verificationId) {
                      print('codeAutoRetrievalTimeout');
                    },
                  );
                }
              },
              child: Text('Submit'),
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
                  padding: EdgeInsets.only(top: 50, bottom: 40),
                  child: Text(
                    'Enter number',
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                    ),
                  )),
              PhoneForm()
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

// Create a corresponding State class.
// This class holds data related to the form.
class CodeFormState extends State<CodeForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<PhoneFormState>.
  final _formKey = GlobalKey<FormState>();
  final codeController = TextEditingController();
  String error = '';

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    codeController.dispose();
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
          Container(
              color: Colors.white,
              child: TextFormField(
                controller: codeController,
                // The validator receives the text that the user has entered.
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
            child: ElevatedButton(
              onPressed: () async {
                setState(() => error = '');
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  final args = ModalRoute.of(context)!.settings.arguments
                      as Map<String, String>;

                  // Create a PhoneAuthCredential with the code
                  var credential = PhoneAuthProvider.credential(
                      verificationId: args['verificationId'] ?? '',
                      smsCode: codeController.text);
                  // Sign the user in (or link) with the credential
                  await auth.signInWithCredential(credential);
                  await Navigator.pushNamed(context, '/');
                }
              },
              child: Text('Submit'),
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
                  padding: EdgeInsets.only(top: 50, bottom: 40),
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
