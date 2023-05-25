import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:job/screens/home.dart';
import 'package:job/screens/idealo.dart';
import 'package:job/screens/products.dart';
import 'dart:ui';

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
      MyHome(),
      Products(),
      Earn()
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: 'Earn',
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
