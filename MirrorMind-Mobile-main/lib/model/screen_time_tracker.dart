import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:app_usage/app_usage.dart';

class ScreenTimeTracker {
  static final ScreenTimeTracker _singleton = ScreenTimeTracker._internal();

  factory ScreenTimeTracker() {
    return _singleton;
  }

  ScreenTimeTracker._internal();

  Duration twitterScreenTime = Duration();
  Duration facebookScreenTime = Duration();
  Duration instagramScreenTime = Duration();
  Function? onDataChanged;

  late Timer _timer;

void startRealTimeTracking() {
    print("Starting real-time tracking...");
    _fetchAppUsage(); // Initial fetch
_timer = Timer.periodic(Duration(hours: 1), (Timer t) => _fetchAppUsage());
}


  void stopTracking() {
    _timer.cancel();
  }

  void _fetchAppUsage() async {
     print("Fetching app usage...");
    
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day);
      List<AppUsageInfo> infoList =
          await AppUsage().getAppUsage(startDate, endDate);

      for (AppUsageInfo info in infoList) {
        switch (info.packageName) {
          case 'com.twitter.android':
            twitterScreenTime = info.usage;
            break;
          case 'com.facebook.katana':
            facebookScreenTime = info.usage;
            break;
          case 'com.instagram.android':
            instagramScreenTime = info.usage;
            break;
        }
      }

      // Update Firestore with hourly app usage
      await _saveDataToFirestore();

      // Notify listeners that data has changed.
      if (onDataChanged != null) onDataChanged!();
      
    } on AppUsageException catch (exception) {
      print(exception);
    }
  }
Future<void> _saveDataToFirestore() async {
  final user = FirebaseAuth.instance.currentUser;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  // Format the current date to get a 'year-month-day' structure
  String yearMonthDay = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';

  try {
    await users.doc(user?.uid).collection('social_media').doc('twitter').collection(yearMonthDay).doc().set({
      'timestamp': FieldValue.serverTimestamp(),
      'usage_in_hours': twitterScreenTime.inHours,
    });

    await users.doc(user?.uid).collection('social_media').doc('facebook').collection(yearMonthDay).doc().set({
      'timestamp': FieldValue.serverTimestamp(),
      'usage_in_hours': facebookScreenTime.inHours,
    });

    await users.doc(user?.uid).collection('social_media').doc('instagram').collection(yearMonthDay).doc().set({
      'timestamp': FieldValue.serverTimestamp(),
      'usage_in_hours': instagramScreenTime.inHours,
    });
  } catch (e) {
    print("Error writing to Firestore: $e");
  }
}

}