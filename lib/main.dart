import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:job/first%20pages/home.dart';
import 'package:job/providers/country_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:country_code_picker/country_code_picker.dart';

import 'L10n/l10n.dart';
import 'first pages/get_started.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  User? user = FirebaseAuth.instance.currentUser;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
  runApp( MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_){
        return CountryProvider();
      })
    ],
      child: MyApp(isFirstLaunch: isFirstLaunch, user:  user,)
  ));
}

class MyApp extends StatelessWidget {
  final bool isFirstLaunch;
  final User? user;
  const MyApp({super.key, required this.isFirstLaunch, required this.user});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor:Colors.transparent,));
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: CupertinoThemeData(
        scaffoldBackgroundColor: CupertinoColors.systemBackground,
        primaryColor: CupertinoColors.activeBlue,
        textTheme: CupertinoTextThemeData(
          tabLabelTextStyle: TextStyle(
            color: Color(0xff7F78D8),
            fontWeight: FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        CountryLocalizations.delegate,
      ],
      home: user == null ? (isFirstLaunch ? const GetStarted() : const Home()) : Home(),
      builder: EasyLoading.init(),
    );

  }

}

