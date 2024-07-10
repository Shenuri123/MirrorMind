import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mirrormind/model/model.dart';

class DateHelper {
  static Future<Map<DateTime, String>> getUserMoodData() async {
    Map<DateTime, String> moodData = {};

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User is not logged in");
        return moodData;
      }

      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      DateTime startPeriod = DateTime.now().subtract(Duration(days: 7));
      Timestamp startTimestamp = Timestamp.fromDate(startPeriod);

      print("User ID: ${user.uid}");
      print("Start Period: $startPeriod");

      QuerySnapshot snapshot = await users
          .doc(user.uid)
          .collection('disorderanalysis')
          .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
          .get();

      print("Query results: ${snapshot.docs.length} documents found");

      if (snapshot.docs.isEmpty) {
        print("No data found for the given query");
      }

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        print("Fetched data: $data");
        DateTime timestamp = (data['timestamp'] as Timestamp).toDate();
        DateTime dateWithoutTime =
            DateTime(timestamp.year, timestamp.month, timestamp.day);
        print("Fetched timestamp: $timestamp");

        String mood = _getMoodFromEmotions(data['emotions_percentages']);
        moodData[dateWithoutTime] = mood; // Use dateWithoutTime as the key
      }
    } catch (e) {
      print("Error fetching user mood data: $e");
    }

    return moodData;
  }

  static String _getMoodFromEmotions(Map<String, dynamic>? emotions) {
    if (emotions == null) return 'neutral';

    double angry = (emotions['angry'] ?? 0).toDouble();
    double happy = (emotions['happy'] ?? 0).toDouble();
    double sad = (emotions['sad'] ?? 0).toDouble();
    double disgust = (emotions['disgust'] ?? 0).toDouble();

    print("Emotions: angry: $angry, happy: $happy, sad: $sad");

    if (angry > 0.5) return 'angry';
    if (happy > 0.5) return 'happy';
    if (sad > 0.5) return 'sad';
    if (disgust > 0.5) return 'disgust';
    return 'neutral';
  }

  static Future<List<Date>> getDates() async {
    Map<DateTime, String> userMoodData = await getUserMoodData();

    List<Date> dates = [];
    DateTime now = DateTime.now();
    // Calculate the number of days to subtract to get to the previous Monday
    int daysToMonday = now.weekday - 1;
    DateTime monday = now.subtract(Duration(days: daysToMonday));

    for (int i = 0; i < 7; i++) {
      DateTime date = monday.add(Duration(days: i));
      DateTime dateWithoutTime = DateTime(date.year, date.month, date.day);
      String mood = userMoodData[dateWithoutTime] ?? 'null';

      String iconPath = _getIconPathForMood(mood);
      dates.add(Date(
          name: _getDayAbbreviation(date),
          iconPath: iconPath,
          isSelected:
              dateWithoutTime == DateTime(now.year, now.month, now.day)));

      print("Date: $date, Mood: $mood");
    }

    return dates;
  }

  static String _getDayAbbreviation(DateTime date) {
    List<String> dayAbbreviations = ['M', 'T', 'W', 'T', 'F', 'Sa', 'Su'];
    return dayAbbreviations[date.weekday - 1];
  }

  static String _getIconPathForMood(String mood) {
    switch (mood) {
      case 'happy':
        return 'assets/faces/happy.png';
      case 'sad':
        return 'assets/faces/sad.png';
      case 'angry':
        return 'assets/faces/angry.png';
      case 'disgust':
        return 'assets/faces/neutral.png';
      default:
        return 'assets/faces/null.png';
    }
  }
}
