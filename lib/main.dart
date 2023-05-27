import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:job/first%20pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'L10n/l10n.dart';
import 'first pages/get_started.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
  runApp( MyApp(isFirstLaunch: isFirstLaunch,));
}

class MyApp extends StatelessWidget {
  final bool isFirstLaunch;
  const MyApp({super.key, required this.isFirstLaunch});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor:Colors.transparent,));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedLabelStyle:TextStyle(
            color: Color(0xff7F78D8),
            fontWeight: FontWeight.w500,
            fontSize: 20
          )
        ),
        primarySwatch: Colors.blue,
      ),
            supportedLocales: L10n.all,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate
            ],

            home: isFirstLaunch?const GetStarted():const Home(),

    );
  }

}

