import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:job/screens/home.dart';
import 'package:job/screens/idealo.dart';
import 'dart:ui';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      Profile()
    ];
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        height: MediaQuery.of(context).size.height*0.08,
        activeColor: const Color(0xff7F78D8),
        currentIndex: _selectedItem,
        onTap: (index) {
          setState(() {
            _selectedItem = index;
          });
        },
        items:   [
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.home),
            label: AppLocalizations.of(context)?.home,
            tooltip: AppLocalizations.of(context)?.home,
          ),
           BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.search),
            label: AppLocalizations.of(context)?.search,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.person),
            label:AppLocalizations.of(context)?.profile,
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            return _screens[index];
          },

        );
      },
    );
  }
}

