import 'package:flutter/widgets.dart';
import 'package:mirrormind/screen/screen.dart';

final Map<String, WidgetBuilder> routes = {
  LoginScreen.routeName: (context) => LoginScreen(),
  Explore.routeName: (context) => Explore(),
  SplashScreen.routeName: (context) => SplashScreen(),
  // SleepScreen.routeName: (context) => SleepScreen(),
  ProfileScreen.routeName: (context) => ProfileScreen(),
};
