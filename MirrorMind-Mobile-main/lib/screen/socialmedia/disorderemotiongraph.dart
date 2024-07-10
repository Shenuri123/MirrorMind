import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';

class DepressionData {
  final String date;
  final String mood;
  final Map<String, num> emotionsPercentages;

  DepressionData(this.date, this.mood, this.emotionsPercentages);

  num get depressionValue {
    switch (mood) {
      case 'mild':
        return 1.0;
      case 'minimal':
        return 0.5;
      case 'moderate':
        return 2.0;
      case 'severe':
        return 3.0;
      default:
        return 0.0;
    }
  }
}

class EmotionData {
  final String emotion;
  final num percentage;

  EmotionData(this.emotion, this.percentage);
}

enum TimePeriod { Week, Month }

class DisorderEmotionAnalysis extends StatefulWidget {
  @override
  _SocialMediaGraphState createState() => _SocialMediaGraphState();
}

class _SocialMediaGraphState extends State<DisorderEmotionAnalysis> {
  TimePeriod selectedTimePeriod = TimePeriod.Month;
  List<DepressionData> depressionData = [];
  ScreenshotController screenshotController = ScreenshotController();
  List<EmotionData> fetchedData = [];

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
        Timestamp? timestampTimestamp = data['timestamp'];
        DateTime? timestamp = timestampTimestamp?.toDate();
        String textResult = data['text_result'] ?? '';
        Map<String, num> emotionsPercentages =
            (data['emotions_percentages'] as Map?)?.cast<String, num>() ?? {};

        if (timestamp != null && textResult.isNotEmpty) {
          depressionData.add(DepressionData(
            DateFormat(selectedTimePeriod == TimePeriod.Week ? 'E' : 'MMMM d')
                .format(timestamp),
            textResult,
            emotionsPercentages,
          ));
          print(
              'Date: ${DateFormat(selectedTimePeriod == TimePeriod.Week ? 'E' : 'MMMM d').format(timestamp)}, Depression Level: $textResult');
        }
      }

      setState(() {});
    } catch (e) {
      print("Error fetching data from Firestore: $e");
    }
  }


  List<EmotionData> getEmotionsData() {
    Map<String, num> aggregatedEmotions = {};

    for (var depressionDatum in depressionData) {
      Map<String, num> emotions = depressionDatum.emotionsPercentages;
      for (var entry in emotions.entries) {
        if (aggregatedEmotions.containsKey(entry.key)) {
          aggregatedEmotions[entry.key] =
              aggregatedEmotions[entry.key]! + entry.value;
        } else {
          aggregatedEmotions[entry.key] = entry.value;
        }
      }
    }

    // Calculate average and round to nearest whole number
    aggregatedEmotions
        .updateAll((key, value) => (value / depressionData.length).round());

    return aggregatedEmotions.entries
        .map((e) => EmotionData(e.key, e.value))
        .toList();
  }



  void shareReport() async {
    await generateSocialMediaPDF();
    final directory = await getExternalStorageDirectory();
    final filePath = '${directory!.path}/Voice Recognition Report.pdf';

    final file = File(filePath);
    if (await file.exists()) {
      Share.shareFiles([filePath], text: 'Voice Recognition Report');
    } else {
      print('Error: File does not exist at $filePath');
      // Consider showing an error message to the user
    }
  }


    Future<void> generateSocialMediaPDF() async {
    final pdf = pw.Document();

    final tableHeaders = ['Date', 'Emotions with precentages'];

    final tableData = depressionData
        .map((data) => [data.date, data.emotionsPercentages.toString()])
        .toList();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Center(
                child: pw.Text(
                  'Voice Recognition Report',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: tableHeaders,
                data: tableData,
                cellAlignment: pw.Alignment.centerLeft,
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final file = File('${directory.path}/Voice Recognition Report.pdf');
        await file.writeAsBytes(await pdf.save());
        print('PDF saved at ${file.path}');

        // Let's also check if the file exists after saving
        if (await file.exists()) {
        } else {}
      } else {}
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      height: 500,
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
                        'Voice Analysis',
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
            // Expanded(
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.circular(16),
            //     child: Container(
            //       child: SfCartesianChart(
            //         plotAreaBorderWidth: 0,
            //         primaryXAxis: CategoryAxis(
            //           majorGridLines: MajorGridLines(width: 0),
            //           edgeLabelPlacement: EdgeLabelPlacement.shift,
            //         ),
            //         primaryYAxis: NumericAxis(
            //           minimum: 0,
            //           maximum: 3,
            //           interval: 1,
            //           majorGridLines: MajorGridLines(width: 0),
            //           axisLine: AxisLine(width: 0),
            //         ),
            //         legend: Legend(isVisible: false),
            //         series: <LineSeries<DepressionData, String>>[
            //           LineSeries<DepressionData, String>(
            //             dataSource: depressionData,
            //             xValueMapper: (DepressionData data, _) => data.date,
            //             yValueMapper: (DepressionData data, _) =>
            //                 data.depressionValue,
            //             color: Colors.pink[100],
            //             markerSettings: MarkerSettings(
            //               isVisible: true,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.0), // Adjust the padding as needed
                child: SfCartesianChart(
                  title: ChartTitle(
                    text: 'Emotions Analysis',
                    textStyle: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF424242),
                    ),
                  ),
                  plotAreaBorderWidth: 0,
                  primaryXAxis: CategoryAxis(
                    majorGridLines: MajorGridLines(width: 0),
                    labelStyle: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      color: Color(0xFF424242),
                    ),
                  ),
                  primaryYAxis: NumericAxis(
                    minimum: 0,
                    maximum: 100,
                    interval: 20,
                    majorGridLines: MajorGridLines(width: 0),
                    axisLine: AxisLine(width: 0),
                    labelFormat: '{value}%',
                    labelStyle: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      color: Color(0xFF424242),
                    ),
                  ),
                  legend: Legend(
                    isVisible: false,
                    textStyle: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      color: Color(0xFF424242),
                    ),
                  ),
                  series: <ChartSeries>[
                    BarSeries<EmotionData, String>(
                      dataSource: getEmotionsData(),
                      xValueMapper: (EmotionData data, _) => data.emotion,
                      yValueMapper: (EmotionData data, _) => data.percentage,
                      dataLabelSettings: DataLabelSettings(isVisible: true),
                    ),
                  ],
                ),
              ),
            ),
            TextButton.icon(
              onPressed: shareReport,
              label: Text('Share'),
              icon: Icon(Icons.share),
            ),
          ],
        ),
      ),
    );
  }
}
