import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:totem/app/guideline_screen.dart';
import 'package:totem/app/login/code_register_page.dart';
import 'app/login/login_page.dart';
import 'app/login/phone_register_page.dart';
import 'app/settings/settings_page.dart';
import 'app/home/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(
    child: App(),
  ));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var routes = <String, Widget Function(dynamic)>{
      '/login': (_) => const LoginPage(),
      '/login/phone': (_) => const RegisterPage(),
      '/login/phone/code': (_) => const CodeRegisterPage(),
      '/login/guideline': (_) => const GuidelineScreen(),
      '/settings': (_) => LoggedinGuard(builder: (_) => const SettingsPage()),
      '/home': (_) => LoggedinGuard(builder: (_) => const HomePage())
    };
    return ScreenUtilInit(
      designSize: const Size(360, 776),
      builder: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'totem',
        theme: ThemeData(
            brightness: Brightness.dark, scaffoldBackgroundColor: Colors.black),
        home: AuthWidget(
          nonSignedInBuilder: (_) => const LoginPage(),
          signedInBuilder: (_) => const HomePage(),
        ),
        routes: routes,
      ),
    );
  }
}
