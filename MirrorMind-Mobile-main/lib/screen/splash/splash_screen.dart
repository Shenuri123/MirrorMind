import 'dart:async';
import 'package:mirrormind/provider/sign_in_provider.dart';
import 'package:mirrormind/screen/login/login_screen.dart';
import 'package:mirrormind/util/config.dart';
import 'package:mirrormind/util/next_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../nav/nav.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = '/splash';
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // init state
  @override
  void initState() {
    final spm = context.read<SignInProvider>();
    super.initState();
    // create a timer of 2 seconds
    Timer(const Duration(seconds: 2), () {
      spm.isSignedIn == false
          ? nextScreen(context, const LoginScreen())
          : nextScreen(context, const Nav());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: Image(
          image: AssetImage(Config.app_icon),
          height: 100,
          width: 100,
        )),
      ),
    );
  }
}
