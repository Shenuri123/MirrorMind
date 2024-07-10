import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class DepressionData {
  final String date;
  final String depressionLevel;
  final Map<String, num> emotions;

  DepressionData(this.date, this.depressionLevel, this.emotions);

  num? get depressionValue {
    switch (depressionLevel) {
      case 'mild':
        return 1.0;
      case 'minimal':
        return 0.5;
      case 'moderate':
        return 2.0;
      case 'severe':
        return 3.0;
      default:
        return null; // Return null for other cases (handle this as needed)
    }
  }
}

enum TimePeriod { Week, Month }

class DisorderAnalysis extends StatefulWidget {
  @override
  _SocialMediaGraphState createState() => _SocialMediaGraphState();
}

class _SocialMediaGraphState extends State<DisorderAnalysis> {
  TimePeriod selectedTimePeriod = TimePeriod.Month;
  List<DepressionData> depressionData = [];

  @override
  void initState() {
    super.initState();
    getDataFromFirebase();
  }

void getDataFromFirebase() async {
  final user = FirebaseAuth.instance.currentUser;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  DateTime now = DateTime.now();
  DateTime startPeriod = selectedTimePeriod == TimePeriod.Week
      ? now.subtract(Duration(days: 7))
      : now.subtract(Duration(days: 30));

  try {
    QuerySnapshot snapshot = await users
        .doc(user?.uid)
        .collection('disorderanalysis')
        .where('timestamp', isGreaterThanOrEqualTo: startPeriod)
        .get();

    depressionData.clear();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Correctly handle the Timestamp field
      Timestamp timestampTimestamp = data['timestamp'];
      DateTime timestamp = timestampTimestamp.toDate();
      String textResult = data['text_result'] ?? '';
      Map<String, num> emotionsPercentages = Map<String, num>.from(data['emotions_percentages'] ?? {});

      if (textResult.isNotEmpty) {
        depressionData.add(DepressionData(
          DateFormat(selectedTimePeriod == TimePeriod.Week ? 'E' : 'MMMM d').format(timestamp),
          textResult,
          emotionsPercentages,
        ));
        print('Date: ${DateFormat(selectedTimePeriod == TimePeriod.Week ? 'E' : 'MMMM d').format(timestamp)}, Depression Level: $textResult');
      }
    }

    setState(() {});
  } catch (e) {
    print("Error fetching data from Firestore: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      height: 400,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: Color.fromARGB(255, 245, 239, 254),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: 200,
                      child: Text(
                        'Quiz Game Analysis',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF424242),
                        ),
                      ),
                    ),
                  ),
                  DropdownButton<TimePeriod?>(
                    value: selectedTimePeriod,
                    items: [
                      DropdownMenuItem<TimePeriod?>(
                        value: TimePeriod.Week,
                        child: Text('Weekly'),
                      ),
                      DropdownMenuItem<TimePeriod?>(
                        value: TimePeriod.Month,
                        child: Text('Monthly'),
                      ),
                    ],
                    onChanged: (TimePeriod? newValue) {
                      setState(() {
                        selectedTimePeriod = newValue ??
                            TimePeriod
                                .Week; // Use a default value if newValue is null
                        getDataFromFirebase();
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  child: SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    primaryXAxis: CategoryAxis(
                      majorGridLines: MajorGridLines(width: 0),
                      edgeLabelPlacement: EdgeLabelPlacement.shift,
                    ),
                    primaryYAxis: NumericAxis(
                      minimum: 0,
                      maximum: 3,
                      interval: 1,
                      majorGridLines: MajorGridLines(width: 0),
                      axisLine: AxisLine(width: 0),
                    ),
                    legend: Legend(isVisible: false),
                    series: <LineSeries<DepressionData, String>>[
                      LineSeries<DepressionData, String>(
                        dataSource: depressionData,
                        xValueMapper: (DepressionData data, _) => data.date,
                        yValueMapper: (DepressionData data, _) =>
                            data.depressionValue,
                        color: Colors.pink[100],
                        markerSettings: MarkerSettings(
                          isVisible: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
