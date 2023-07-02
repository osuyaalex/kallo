import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class ColorChangeObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    if (route.settings.arguments != null &&
        route.settings.arguments is Color) {
      final color = route.settings.arguments as Color;
      changeNavigationBarColor(color); // Change the navigation bar color
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);

    if (previousRoute != null &&
        previousRoute.settings.arguments != null &&
        previousRoute.settings.arguments is Color) {
      final color = previousRoute.settings.arguments as Color;
      changeNavigationBarColor(color); // Change the navigation bar color
    }
  }

  void changeNavigationBarColor(Color color) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: color,
      ),
    );
  }
}