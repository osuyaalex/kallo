import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:job/home.dart';

void main() {
  runApp(
      const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor:Colors.transparent));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        navigationBarTheme: const NavigationBarThemeData(
          indicatorColor: Color(0xff7F78D8),
          labelTextStyle: MaterialStatePropertyAll(TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500
          ))
        ),
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

