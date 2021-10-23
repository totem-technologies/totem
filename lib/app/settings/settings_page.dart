import 'package:flutter/material.dart';
import 'package:totem/components/widgets/buttons.dart';
import 'package:totem/components/widgets/headers.dart';
import 'package:totem/app/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: SafeArea(
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
              const TotemHeader(text: 'Settings'),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: TotemButton(
                  icon: Icons.logout,
                  buttonText: 'Sign Out',
                  onButtonPressed: (stop) async {
                    await context.read(authServiceProvider).signOut();
                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
