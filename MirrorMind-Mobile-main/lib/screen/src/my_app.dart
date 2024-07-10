import 'package:flutter/material.dart';
import 'package:mirrormind/screen/generated/l10n.dart';
import 'package:mirrormind/screen/src/ui/routes/app_routes.dart';
import 'package:mirrormind/screen/src/ui/routes/routes.dart';
import 'package:provider/provider.dart';

import 'ui/global/controllers/theme_controller.dart';
import 'ui/global/widgets/max_text_scale_factor.dart';

class Puzzle extends StatelessWidget {
  static String routeName = '/MyApp';
  const Puzzle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: Consumer<ThemeController>(
        builder: (_, controller, __) => MaterialApp(
          builder: (_, page) => MaxTextScaleFactor(
            child: page!,
          ),
          localizationsDelegates: const [
            S.delegate,
            // GlobalMaterialLocalizations.delegate,
            // GlobalWidgetsLocalizations.delegate,
            // GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
          ],
          debugShowCheckedModeBanner: false,
          themeMode: controller.themeMode,
          theme: controller.lightTheme,
          darkTheme: controller.darkTheme,
          initialRoute: Routes.splash,
          routes: appRoutes,
        ),
      ),
    );
  }
}
