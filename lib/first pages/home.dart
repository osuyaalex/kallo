import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:job/screens/home.dart';
import 'package:job/screens/idealo.dart';
import 'dart:ui';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import 'package:job/utilities/snackbar.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Authentication/google_sign_in.dart';
import '../providers/animated.dart';
import '../screens/demo_two.dart';



class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedItem = 1;


  @override
  Widget build(BuildContext context) {
    final animatedProvider = Provider.of<AnimatedProvider>(context);

    final List<Widget> _screens = [
      MyHome(
        onProductPressed: () async{
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLaunch', true);
          setState(() {
            _selectedItem = 1;
          });
          Navigator.of(context).pushReplacement(PageTransition(
            child: const Home(),
            type: PageTransitionType.fade,
            childCurrent: widget,
            duration: const Duration(milliseconds: 100),
            reverseDuration: const Duration(milliseconds: 100),
          )
          );
        },
        onCameraPressed: ()async{
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLaunchCamera', true);
          setState(() {
            _selectedItem = 1;
          });
          Navigator.of(context).pushReplacement(PageTransition(
            child: const Home(),
            type: PageTransitionType.fade,
            childCurrent: widget,
            duration: const Duration(milliseconds: 100),
            reverseDuration: const Duration(milliseconds: 100),
          )
          );
        },
        onSearchPressed: ()async{
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isSearchBar', true);
          setState(() {
            _selectedItem = 1;
          });
          Navigator.of(context).pushReplacement(PageTransition(
            child: const Home(),
            type: PageTransitionType.fade,
            childCurrent: widget,
            duration: const Duration(milliseconds: 100),
            reverseDuration: const Duration(milliseconds: 100),
          )
          );
        },
      ),
      Dems(),
      Profile(
        onGoogleSignPressed: ()async{
          EasyLoading.show();
          User? user = await GoogleAuthentication.signInWithGoogle(context);
          EasyLoading.dismiss();
          if(user != null){
            snack(context, AppLocalizations.of(context)!.successfullySignedIn);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
              return Home();
            }));

          }
        },
      )
    ];
    return Scaffold(
      bottomNavigationBar: AnimatedContainer(
        curve: Curves.fastOutSlowIn,
        duration: Duration(milliseconds: 400),
        height: animatedProvider.myVariable ? 70 : 0,
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xff7F78D8),
          currentIndex: _selectedItem,
          onTap: (index) {
            setState(() {
              _selectedItem = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: AppLocalizations.of(context)?.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.search),
              label: AppLocalizations.of(context)?.search,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: AppLocalizations.of(context)?.profile,
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedItem,
        children: _screens,
      ),
    );
  }
}

