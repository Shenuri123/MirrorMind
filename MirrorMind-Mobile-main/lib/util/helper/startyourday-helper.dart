import 'package:mirrormind/model/model.dart';

class StartyourdaysHelper {
  static Future<List<Startyourday>> getStartyourday() async {
    List<Startyourday> startyourdays = [];
    startyourdays.add(Startyourday(
        name: 'Listening To Music',
        description: "30 min",
        iconPath: 'assets/images/music.png',
        isSelected: false));

    startyourdays.add(Startyourday(
        name: 'Playing Games',
        description: "30 min",
        iconPath: 'assets/images/music2.jpg',
        isSelected: false));
    return startyourdays;
  }
}
