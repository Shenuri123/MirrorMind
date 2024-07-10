import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mirrormind/screen/profile/components/notification_service.dart';
import 'package:mirrormind/screen/screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mirrormind/theme.dart';
import 'package:mirrormind/provider/internet_provider.dart';
import 'package:mirrormind/provider/sign_in_provider.dart';
import 'package:provider/provider.dart';
import 'package:mirrormind/screen/src/inject_dependencies.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initializeNotification();
  await Firebase.initializeApp();
  await initializeDateFormatting(); // Initialize date formatting data
  setPathUrlStrategy();
  await injectDependencies();
  // Workmanager().initialize(callbackDispatcher);
  runApp(MyApp());
}

// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     // This would be the function that checks app usage and updates Firestore
//     final tracker = ScreenTimeTracker();
//     tracker.startFetchingAppUsage();
//     return Future.value(true);
//   });
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => SignInProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => InternetProvider(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) {
          return GetMaterialApp(
            theme: theme(),
            debugShowCheckedModeBanner: false,
            initialRoute: SplashScreen.routeName,
            getPages: [
              // Convert your routes map to GetPage objects
              GetPage(
                name: SplashScreen.routeName,
                page: () => SplashScreen(),
              ),
              GetPage(
                name: HomeScreen.routeName,
                page: () => HomeScreen(),
              ),
              // Add more GetPage entries for other routes
            ],
          );
        },
      ),
    );
  }
}
