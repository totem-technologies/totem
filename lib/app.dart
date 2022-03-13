import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/theme/index.dart';

import 'app/auth.dart';
import 'app/home/home_page.dart';
import 'app/login/login_page.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  @override
  void initState() {
    super.initState();
    initDynamicLinks();
  }

  Future<void> initDynamicLinks() async {
    dynamicLinks.onLink.listen((dynamicLinkData) {
      _handleDynamicLink(dynamicLinkData.link);
    }).onError((error) {
      debugPrint('onLink error');
      debugPrint(error.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xFF000000),
      systemNavigationBarDividerColor: null,
      statusBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
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
      home: WithForegroundTask(
        child: AuthWidget(
          nonSignedInBuilder: (_) => const LoginPage(),
          signedInBuilder: (_) => const HomePage(),
        ),
      ),
      onGenerateRoute: AppRoutes.generateRoute,
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
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoWillPopScopePageTransionsBuilder(),
        },
      ),
    );
  }

  Future<void> _handleDynamicLink(Uri link) async {
    debugPrint('Handling dynamic link: ${link.path}');
  }
}