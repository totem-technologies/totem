import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var auth = FirebaseAuth.instance;
    var user = auth.currentUser;
    return Scaffold(
      body: Center(
          child: Column(children: [
        Text('hello $user.tenantId'),
        ElevatedButton(
            onPressed: () async {
              await auth.signOut();
            },
            child: Text('logout'))
      ])),
    );
  }
}
