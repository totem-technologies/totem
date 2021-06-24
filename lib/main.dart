import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/login/LoginPage.dart';
import 'app/settings/SettingsPage.dart';
import 'app/home/HomePage.dart';
import 'app/login/RegisterPage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/auth.dart';
import 'package:totem/app/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(
    child: App(),
  ));
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var routes = <String, Widget Function(dynamic)>{
      '/login': (_) => LoginPage(),
      '/login/phone': (_) => RegisterPage(),
      '/login/phone/code': (_) => CodeRegisterPage(),
      '/settings': (_) => LoggedinGuard(builder: (_) => SettingsPage()),
      '/home': (_) => LoggedinGuard(builder: (_) => HomePage())
    };
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'totem',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: AuthWidget(
        nonSignedInBuilder: (_) => LoginPage(),
        signedInBuilder: (_) => HomePage(),
      ),
      initialRoute: '/',
      routes: routes,
    );
  }
}
