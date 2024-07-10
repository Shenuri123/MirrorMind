import 'package:flutter/material.dart';
import '../../theme.dart';
import 'presentation/router/app_router.dart';

class Explore extends StatelessWidget {
  static String routeName = '/explore';

  const Explore({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
    debugShowCheckedModeBanner: false,
      theme: theme(),
      routerConfig: appRouterConfig,
    );
  }
}
