import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/guideline_screen.dart';
import 'package:totem/app/profile/index.dart';
import 'package:totem/app/profile/onboarding_profile_page.dart';
import 'package:totem/components/fade_route.dart';
import 'package:totem/theme/index.dart';

import 'app/auth.dart';
import 'app/circle/circle_create_page.dart';
import 'app/circle/circle_create_snap_page.dart';
import 'app/home/home_page.dart';
import 'app/login/login_page.dart';
import 'app/login/phone_register_page.dart';
import 'app/settings/settings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (kDebugMode) {
    // Force disable Crashlytics collection while doing every day development.
    // Temporarily toggle this to true if you want to test crash reporting in your app.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  } else {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }
  runApp(const ProviderScope(
    child: App(),
  ));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xFF000000),
      systemNavigationBarDividerColor: null,
      statusBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
    ));
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
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
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/login/phone':
            return FadeRoute(page: const RegisterPage());
          case '/login/guideline':
            return FadeRoute(page: const GuidelineScreen());
          case '/login/onboarding':
            return FadeRoute(page: const OnboardingProfilePage());
          case '/circle/create':
            return MaterialPageRoute(builder: (_) => const CircleCreatePage());
          case '/snap_circle/create':
            return MaterialPageRoute(
                builder: (_) => const CircleCreateSnapPage());
          case '/settings':
            return MaterialPageRoute(
                builder: (_) =>
                    LoggedinGuard(builder: (_) => const SettingsPage()));
          case '/profile':
            return MaterialPageRoute(
                builder: (_) =>
                    LoggedinGuard(builder: (_) => const UserProfilePage()));
          default:
            return null;
        }
      },
    );
  }

  ThemeData _appTheme(BuildContext context) {
    AppThemeColors themeColors = StdAppThemeColors();
    AppTextStyles textStyles = StdAppTextStyles(themeColors);
    AppThemeStyles.setStyles(colors: themeColors, textStyles: textStyles);
    return ThemeData(
      appBarTheme: AppBarTheme(
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: themeColors.primaryText),
      ),
      brightness: Brightness.light,
      primaryColor: themeColors.primary,
      scaffoldBackgroundColor: themeColors.screenBackground,
      fontFamily: 'Raleway',
      dialogTheme: DialogTheme(
        backgroundColor: themeColors.dialogBackground,
        contentTextStyle: textStyles.dialogContent,
      ),
      textTheme: textStyles,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            primary: themeColors.linkText,
            textStyle: textStyles.textLinkButton),
      ),
      //,
    );
  }
}
