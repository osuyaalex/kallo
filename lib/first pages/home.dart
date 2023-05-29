import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:job/screens/home.dart';
import 'package:job/screens/idealo.dart';
import 'package:job/screens/products.dart';
import 'dart:ui';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }
  int _selectedItem = 1;
  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      MyHome(),
      Products(),
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

