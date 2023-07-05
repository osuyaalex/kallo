import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:page_transition/page_transition.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Authentication/google_sign_in.dart';
import '../providers/animated.dart';
import '../screens/demo_two.dart';
import '../screens/home.dart';
import '../screens/idealo.dart';
import '../utilities/snackbar.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';



class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  late PersistentTabController _controller;

 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = PersistentTabController(initialIndex: 1);
  }

  List<Widget> _buildScreens() {
    return [
      MyHome(
        onProductPressed: () async{
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLaunch', true);
          Navigator.of(context).pushReplacement(PageTransition(
            child: const Dems(),
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

          Navigator.of(context).pushReplacement(PageTransition(
            child: const Dems(),
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
          Navigator.of(context).pushReplacement(PageTransition(
            child: const Dems(),
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
              return Dems();
            }));

          }
        },
      )
    ];
  }
  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        title: (AppLocalizations.of(context)?.home),
        activeColorPrimary:  const Color(0xff7F78D8),
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.search),
        title: (AppLocalizations.of(context)?.search),
        activeColorPrimary: const Color(0xff7F78D8),
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        title: (AppLocalizations.of(context)?.profile),
        activeColorPrimary:  const Color(0xff7F78D8),
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }
  @override
  Widget build(BuildContext context) {
    final animatedProvider = Provider.of<AnimatedProvider>(context);
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      hideNavigationBar: animatedProvider.myVariable ? false : true,
      confineInSafeArea: true,
      backgroundColor: Colors.white, // Default is Colors.white.
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset: true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardShows: true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
      decoration: NavBarDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300
          ),

        ),
        colorBehindNavBar: Colors.white,
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: ItemAnimationProperties( // Navigation Bar's items animation properties.
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: ScreenTransitionAnimation( // Screen transition animation on change of selected tab.
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle: NavBarStyle.simple, // Choose the nav bar style with this property.
    );
  }
}
