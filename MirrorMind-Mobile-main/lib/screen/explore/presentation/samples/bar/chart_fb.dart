import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mirrormind/screen/explore/presentation/resources/app_resources.dart';
import 'package:mirrormind/screen/explore/util/extensions/color_extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class _BarChart extends StatelessWidget {
  final List<double> weeklyData;

  const _BarChart(this.weeklyData);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barTouchData: barTouchData,
        titlesData: titlesData,
        borderData: borderData,
        barGroups: barGroups,
        gridData: const FlGridData(show: false),
        alignment: BarChartAlignment.spaceAround,
        maxY: 20,
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
                rod.toY.round().toString(),
                const TextStyle(
                    color: AppColors.contentColorBlue,
                    fontWeight: FontWeight.w500,
                    fontSize: 14));
          },
        ),
      );

  Widget getTitles(double value, TitleMeta meta) {
    final style = TextStyle(
        color: AppColors.contentColorBlue,
        fontWeight: FontWeight.w500,
        fontSize: 14);
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Mn';
        break;
      case 1:
        text = 'Te';
        break;
      case 2:
        text = 'Wd';
        break;
      case 3:
        text = 'Tu';
        break;
      case 4:
        text = 'Fr';
        break;
      case 5:
        text = 'St';
        break;
      case 6:
        text = 'Sn';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: getTitles,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  LinearGradient get _barsGradient => LinearGradient(
        colors: [
          AppColors.contentColorBlue.darken(20),
          Color(0xFF50E4FF),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );
  List<BarChartGroupData> get barGroups {
    List<BarChartGroupData> data = [];
    for (int i = 0; i < weeklyData.length; i++) {
      data.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: weeklyData[i],
              gradient: _barsGradient,
            )
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }
    return data;
  }
}

class Facebook extends StatefulWidget {
  const Facebook();

  @override
  State<StatefulWidget> createState() => FacebookState();
}

class FacebookState extends State<Facebook> {
  late Stream<List<double>> weeklyFacebookDataStream;

  @override
  void initState() {
    super.initState();
    weeklyFacebookDataStream = getFacebookDataAsStream();
  }

Stream<List<double>> getFacebookDataAsStream() async* {
  final user = FirebaseAuth.instance.currentUser;

  while (true) {
    List<double> values = List<double>.filled(7, 0);

    for (int i = 0; i < 7; i++) {
      final currentDay = DateTime.now().subtract(Duration(days: i));
      final dayOfWeek = currentDay.weekday; // 1 (Monday) to 7 (Sunday)
      final yearMonthDay = '${currentDay.year}-${currentDay.month.toString().padLeft(2, '0')}-${currentDay.day.toString().padLeft(2, '0')}';

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('social_media')
          .doc('facebook') // Fetch data from Facebook collection
          .collection(yearMonthDay)
          .get();

      double totalHours = 0.0;
      for (var doc in querySnapshot.docs) {
        totalHours += (doc.data()?['usage_in_hours'] ?? 0).toDouble();
      }
      
      values[dayOfWeek - 1] = totalHours; // Subtract 1 to convert to 0-based index

    }

    yield values;

    await Future.delayed(Duration(minutes: 5));
  }
}


  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.6,
      child: StreamBuilder<List<double>>(
        stream: weeklyFacebookDataStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _BarChart(snapshot.data ?? []);
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data'));
          }
          return Center(
              child: CircularProgressIndicator()); // Loading indicator until data is fetched.
        },
      ),
    );
  }
}
