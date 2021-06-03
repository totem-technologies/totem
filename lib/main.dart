import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:totem/LoginPage.dart';
import 'HomePage.dart';
import 'RegisterPage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AppBuilder());
}

class AppBuilder extends StatefulWidget {
  // Create the initialization Future outside of `build`:
  @override
  _AppBuilderState createState() => _AppBuilderState();
}

class _AppBuilderState extends State<AppBuilder> {
  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  User? _user;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization.then((_) async {
        // Log user in as anon if they have no account.
        var auth = FirebaseAuth.instance;
        _user = auth.currentUser ??
            await auth.signInAnonymously().then((value) => value.user);
        ;
        auth.authStateChanges().listen((User? user) {
          setState(() {
            _user = user;
          });
        });
        return _initialization;
      }),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return BareApp(child: SomethingWentWrong());
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done || _user != null) {
          return App(loggedIn: _user!.isAnonymous == false);
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return BareApp(child: Loading());
      },
    );
  }
}

class BareApp extends StatelessWidget {
  const BareApp({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'totem',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: child);
  }
}

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Colors.amber, child: Center(child: Text('loading...'))),
    );
  }
}

class SomethingWentWrong extends StatelessWidget {
  const SomethingWentWrong({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('oops'),
    );
  }
}

class App extends StatelessWidget {
  App({Key? key, required this.loggedIn}) : super(key: key);
  final bool loggedIn;

  @override
  Widget build(BuildContext context) {
    var routes = <String, Widget Function(dynamic)>{
      '/login': (context) => LoginPage(),
      '/login/phone': (context) => RegisterPage(),
      '/login/phone/code': (context) => CodeRegisterPage(),
    };
    Widget home = LoginPage();
    if (loggedIn) {
      home = HomePage();
      var loggedInRoutes = {'/protected': (context) => LoginPage()};
      routes.addAll(loggedInRoutes);
    }
    var globalRoutes = {
      '/500': (context) => SomethingWentWrong(),
      '/loading': (context) => Loading(),
    };
    return MaterialApp(
      title: 'totem',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: home,
      initialRoute: '/',
      routes: {...routes, ...globalRoutes},
    );
  }
}
