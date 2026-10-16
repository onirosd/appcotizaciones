import 'package:appcotizaciones/src/preferences/sharedpreferencestest.dart';
import 'package:appcotizaciones/src/providers/authentication_provider.dart';
import 'package:appcotizaciones/src/providers/changes.notifier.dart';
import 'package:appcotizaciones/src/providers/customer_provider.dart';
import 'package:appcotizaciones/src/routes/routes.dart';
import 'package:appcotizaciones/src/screens/login_screen.dart';
import 'package:appcotizaciones/src/services/permissions_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:appcotizaciones/src/providers/logo_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Solicita permisos al inicio
  final PermissionService permissionService = PermissionService();
  await permissionService.requestPermissionsOnFirstInstall();

  runApp(AppState());
}

class AppState extends StatelessWidget {
  final MyConnectivity _connectivity = MyConnectivity.instance;
  final SharedPreferencesTest sh = SharedPreferencesTest();

  @override
  Widget build(BuildContext context) {
    bool conectividad = false;

    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      switch (source.keys.toList()[0]) {
        case ConnectivityResult.mobile:
        case ConnectivityResult.wifi:
          conectividad = true;
          break;
        case ConnectivityResult.none:
        default:
          conectividad = false;
      }
      sh.setInternet(conectividad);
    });

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (_) => LogoProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider(), lazy: false),
      ],
      child: MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  final SharedPreferencesTest sh = SharedPreferencesTest();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: EasyLoading.init(),
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      initialRoute: 'login',
      routes: getApplicationRoutes(),
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: (BuildContext context) => LoginScreen(),
        );
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('es', 'ES'),
      ],
      locale: Locale('es'),
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
