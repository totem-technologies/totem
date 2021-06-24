import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../components/Header.dart';
import '../../components/Button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var auth = FirebaseAuth.instance;
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.grey[700],
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
              TotemHeader(text: 'Settings'),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: TotemButton(
                  icon: Icons.logout,
                  text: 'Sign Out',
                  onPressed: (stop) async {
                    await auth.signOut();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
