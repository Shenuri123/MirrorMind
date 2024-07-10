import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initializeNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('drawable/logo');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

Future<void> showNotification(int id, String title, String body, DateTime scheduledTime) async {
  tz.initializeTimeZones();

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    id.toString(),
    'Go To Bed',
    importance: Importance.max,
    priority: Priority.max,
    icon: 'drawable/logo'
  );
  var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

  // Convert the scheduledTime to a TZDateTime
  tz.TZDateTime scheduledTZTime = tz.TZDateTime.from(
    scheduledTime.subtract(Duration(seconds: 0)), // Schedule 10 seconds earlier
    tz.local,
  );

  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    title,
    body,
    scheduledTZTime,
    platformChannelSpecifics,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    androidAllowWhileIdle: true,
    matchDateTimeComponents: DateTimeComponents.time,
    payload: 'Your notification payload',
  );
}


}