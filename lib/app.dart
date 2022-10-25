import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/config.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

Widget _wrapWithBanner(Widget child) {
  if (!AppConfig.isDev) {
    return child;
  }
  return Directionality(
      textDirection: TextDirection.ltr,
      child: Banner(
        location: BannerLocation.bottomStart,
        message: 'DEV',
        color: Colors.green.withOpacity(0.5),
        textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12.0,
            letterSpacing: 1.0,
            color: Colors.white),
        child: child,
      ));
}

class App extends ConsumerStatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  late final _router = AppRoutes.instance.getRouter(ref);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: null,
      statusBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top]);
    ref.watch(authStateChangesProvider);
    return _wrapWithBanner(MaterialApp.router(
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
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
    ));
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
            foregroundColor: themeColors.linkText,
            textStyle: textStyles.textLinkButton),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: textStyles.inputLabel,
        hintStyle: textStyles.hintInputLabel,
        errorStyle: textStyles.bodyText1!
            .copyWith(color: themeColors.error, fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: themeColors.divider,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: themeColors.divider,
            width: 1.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: themeColors.error,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: themeColors.divider,
            width: 1.0,
          ),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoWillPopScopePageTransionsBuilder(),
        },
      ),
    );
  }
}
