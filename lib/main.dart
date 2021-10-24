import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:totem/app/guideline_screen.dart';
import 'package:totem/components/fade_route.dart';
import 'package:totem/theme/index.dart';
import 'app/login/login_page.dart';
import 'app/login/phone_register_page.dart';
import 'app/settings/settings_page.dart';
import 'app/home/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/auth.dart';
import 'package:totem/services/index.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xFF000000),
    systemNavigationBarDividerColor: null,
    statusBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.light,
  ));

  runApp(const ProviderScope(
    child: App(),
  ));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
/*    var routes = <String, Widget Function(dynamic)>{
      '/login': (_) => const LoginPage(),
      '/login/phone': (_) => RegisterPage(),
      '/login/guideline': (_) => const GuidelineScreen(),
      '/settings': (_) => LoggedinGuard(builder: (_) => const SettingsPage()),
      '/home': (_) => LoggedinGuard(builder: (_) => const HomePage())
    }; */
    return ScreenUtilInit(
      designSize: const Size(360, 776),
      builder: () => MaterialApp(
        localizationsDelegates: const [
          Localized.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
        ],
        debugShowCheckedModeBanner: false,
        title: 'totem',
        theme: _appTheme(context),
        home: AuthWidget(
          nonSignedInBuilder: (_) => const LoginPage(),
          signedInBuilder: (_) => const HomePage(),
        ),
        onGenerateRoute: (settings) {
          switch(settings.name) {
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginPage());
            case '/login/phone':
              return FadeRoute(page: const RegisterPage());
            case '/login/guideline':
              return FadeRoute(page: const GuidelineScreen());
            case '/settings':
              return MaterialPageRoute(builder: (_) => LoggedinGuard(builder: (_) => const SettingsPage()));
          default:
              return null;
          }
        },
//        routes: routes,
      ),
    );
  }

  ThemeData _appTheme(BuildContext context) {
    AppThemeColors themeColors = StdAppThemeColors();
    AppTextStyles textStyles = StdAppTextStyles(themeColors);
    AppThemeStyles.setStyles(colors: themeColors, textStyles: textStyles);
    return ThemeData(
      appBarTheme: const AppBarTheme(centerTitle: true, systemOverlayStyle: SystemUiOverlayStyle.dark),
      brightness: Brightness.light,
      primaryColor: themeColors.primary,
      scaffoldBackgroundColor: themeColors.screenBackground,
      fontFamily: 'Raleway',
      dialogTheme: DialogTheme(
        backgroundColor: themeColors.dialogBackground,
        contentTextStyle: TextStyle(color: themeColors.primaryText, fontFamily: 'Raleway'),
      ),
      textTheme: textStyles,
      //,
    );
  }
}
