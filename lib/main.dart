import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:totem/app/login/CodeRegisterPage.dart';
import 'app/login/LoginPage.dart';
import 'app/login/RegisterPage2.dart';
import 'app/settings/SettingsPage.dart';
import 'app/home/HomePage.dart';
import 'app/login/RegisterPage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/auth.dart';

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
      '/login/phone': (_) => RegisterPage2(),
      '/login/phone/code': (_) => CodeRegisterPage2(),
      '/settings': (_) => LoggedinGuard(builder: (_) => SettingsPage()),
      '/home': (_) => LoggedinGuard(builder: (_) => HomePage())
    };
    return ScreenUtilInit(
      designSize: Size(360, 776),
      builder:()=> MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'totem',
        theme: ThemeData(
          brightness: Brightness.dark,
        ),
        home: AuthWidget(
          nonSignedInBuilder: (_) => LoginPage(),
          signedInBuilder: (_) => HomePage(),
        ),
        routes: routes,
      ),
    );
  }
}
