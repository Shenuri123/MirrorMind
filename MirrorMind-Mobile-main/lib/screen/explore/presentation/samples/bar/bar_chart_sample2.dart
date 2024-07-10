import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mirrormind/screen/explore/presentation/resources/app_resources.dart';
import 'package:mirrormind/screen/explore/util/extensions/color_extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartSample2 extends StatefulWidget {
  BarChartSample2();
  final Color leftBarColor = AppColors.contentColorBlue;
  final Color rightBarColor = AppColors.contentColorRed;
  final Color right2arColor = AppColors.contentColorCyan;
  final Color avgColor =
      AppColors.contentColorOrange.avg(AppColors.contentColorRed);
  @override
  State<StatefulWidget> createState() => BarChartSample2State();
}

class BarChartSample2State extends State<BarChartSample2> {
  final double width = 7;
late List<BarChartGroupData> rawBarGroups = [];
late List<BarChartGroupData> showingBarGroups = [];


  int touchedGroupIndex = -1;

@override
void initState() {
  super.initState();
  fetchDataFromFirebase().then((weekData) {
    if (!mounted) return; // Add this line to check if the widget is still in the tree

    List<BarChartGroupData> items = [];
    for (int i = 1; i <= 7; i++) { // for each day of the week
      items.add(makeGroupData(
        i - 1,
        weekData['facebook']![i.toString()] ?? 0,
        weekData['instagram']![i.toString()] ?? 0,
        weekData['twitter']![i.toString()] ?? 0,
      ));
    }
    setState(() {
      rawBarGroups = items;
      showingBarGroups = rawBarGroups;
    });
  });
}



Future<Map<String, Map<String, double>>> fetchDataFromFirebase() async {
  final user = FirebaseAuth.instance.currentUser;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  DateTime today = DateTime.now();
  DateTime oneWeekAgo = today.subtract(Duration(days: 7));

  Map<String, Map<String, double>> weekData = {
    'twitter': {},
    'facebook': {},
    'instagram': {},
  };

  for (int i = 0; i < 7; i++) {
    DateTime day = oneWeekAgo.add(Duration(days: i));
    String yearMonthDay = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

    for (String app in ['twitter', 'facebook', 'instagram']) {
      var doc = await users.doc(user?.uid).collection('social_media').doc(app).collection(yearMonthDay).get();
      double totalHours = 0;
      for (var item in doc.docs) {
        totalHours += (item.data()?['usage_in_hours'] ?? 0);
      }
      weekData[app]![day.weekday.toString()] = totalHours;
    }
  }
  return weekData;
}


  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: showingBarGroups.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[

              ],
            ),
            const SizedBox(
              height: 38,
            ),
            Expanded(
              child: BarChart(
                BarChartData(
                  maxY: 20,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.grey,
                      getTooltipItem: (a, b, c, d) => null,
                    ),
                    touchCallback: (FlTouchEvent event, response) {
                      if (response == null || response.spot == null) {
                        setState(() {
                          touchedGroupIndex = -1;
                          showingBarGroups = List.of(rawBarGroups);
                        });
                        return;
                      }

                      touchedGroupIndex = response.spot!.touchedBarGroupIndex;

                      setState(() {
                        if (!event.isInterestedForInteractions) {
                          touchedGroupIndex = -1;
                          showingBarGroups = List.of(rawBarGroups);
                          return;
                        }
                        showingBarGroups = List.of(rawBarGroups);
                        if (touchedGroupIndex != -1) {
                          var sum = 0.0;
                          for (final rod
                              in showingBarGroups[touchedGroupIndex].barRods) {
                            sum += rod.toY;
                          }
                          final avg = sum /
                              showingBarGroups[touchedGroupIndex]
                                  .barRods
                                  .length;

                          showingBarGroups[touchedGroupIndex] =
                              showingBarGroups[touchedGroupIndex].copyWith(
                            barRods: showingBarGroups[touchedGroupIndex]
                                .barRods
                                .map((rod) {
                              return rod.copyWith(
                                  toY: avg, color: widget.avgColor);
                            }).toList(),
                          );
                        }
                      });
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: bottomTitles,
                        reservedSize: 42,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: leftTitles,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: showingBarGroups,
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
        color: AppColors.contentColorCyan,
        fontWeight: FontWeight.w500,
        fontSize: 14);
    String text;
    if (value == 0) {
      text = '1h';
    } else if (value == 10) {
      text = '5h';
    } else if (value == 19) {
      text = '10h';
    } else {
      return Container();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text(text, style: style),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final titles = <String>['Mn', 'Te', 'Wd', 'Tu', 'Fr', 'St', 'Su'];

    final Widget text = Text(titles[value.toInt()],
        style: const TextStyle(
            color: AppColors.contentColorCyan,
            fontWeight: FontWeight.w500,
            fontSize: 14));

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16, //margin top
      child: text,
    );
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2, double y3) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: widget.leftBarColor,
          width: width,
        ),
        BarChartRodData(
          toY: y2,
          color: widget.rightBarColor,
          width: width,
        ),
        BarChartRodData(
          toY: y3,
          color: widget.right2arColor,
          width: width,
        ),
      ],
    );
  }

}
