import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;

class SocialMediaData {
  final String timestamp;
  final double value;

  SocialMediaData(this.timestamp, this.value);
}

enum TimePeriod { Week, Month }

class ChartData {
  final String month;
  final double value;

  ChartData(this.month, this.value);
}

class socialmediaanalysis extends StatefulWidget {
  @override
  _SocialMediaGraphState createState() => _SocialMediaGraphState();
}

class _SocialMediaGraphState extends State<socialmediaanalysis> {
  Map<String, int> activityCounts = {};
  TimePeriod selectedTimePeriod = TimePeriod.Month;
  String selectedTimePeriodString = 'Week';
  double avgHumidity = 0.0;
  double avgLightIntensity = 0.0;
  double avgTemperature = 0.0;
  List<double> outlierTemperatures = [];
  bool isLoading = false;
  String? error;

  List<SocialMediaData> fetchedData = [];

  @override
  void initState() {
    super.initState();
    getDataFromFirebase(); // Add this
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
          .collection('socialmediaanalysis')
          .where('timestamp', isGreaterThanOrEqualTo: startPeriod)
          .get();

      for (var doc in snapshot.docs) {
        DateTime timestamp = (doc['timestamp'] as Timestamp).toDate();

        double value = 0.0; // Default value
        var resultScore = doc['resultScore'];
        if (resultScore is String) {
          try {
            value = double.parse(resultScore);
          } catch (e) {}
        } else if (resultScore is num) {
          value = resultScore.toDouble();
        } else {}

        fetchedData.add(SocialMediaData(timestamp.toString(), value));
      }

      setState(() {});
    } catch (e) {}
  }

  void shareReport() async {
    await generateSocialMediaPDF();
    final directory = await getExternalStorageDirectory();
    Share.shareFiles(['${directory!.path}/Social Report.pdf'],
        text: 'Social Media Report');
  }

  Future<void> generateSocialMediaPDF() async {
    final pdf = pw.Document();

    final tableHeaders = ['Timestamp', 'Value'];

    final tableData = fetchedData
        .map((data) => [data.timestamp, data.value.toString()])
        .toList();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Center(
                child: pw.Text(
                  'Social Media Report',
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
        final file = File('${directory.path}/Social Report.pdf');
        await file.writeAsBytes(await pdf.save());
        // Log the file path for verification

        // Let's also check if the file exists after saving
        if (await file.exists()) {
        } else {}
      } else {}
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final chartData = fetchedData
        .map((data) => ChartData(data.timestamp, data.value))
        .toList();

    return Container(
      padding: EdgeInsets.all(8),
      height: 600,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: Color.fromARGB(255, 245, 239, 254),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: 200,
                      child: Text(
                        'Social Media Analysis',
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
                      if (newValue != null && newValue != selectedTimePeriod) {
                        setState(() {
                          selectedTimePeriod = newValue;
                        });
                        getDataFromFirebase();
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : error != null
                          ? Center(child: Text(error!))
                          : SfCartesianChart(
                              plotAreaBorderWidth: 0,
                              primaryXAxis: CategoryAxis(
                                labelRotation: 45,
                                labelAlignment: LabelAlignment.start,
                                majorGridLines: MajorGridLines(width: 0),
                                edgeLabelPlacement: EdgeLabelPlacement.shift,
                              ),
                              primaryYAxis: NumericAxis(
                                minimum: -0.3,
                                maximum: 0.3,
                                interval: 0.08,
                                majorGridLines: MajorGridLines(width: 0),
                                axisLine: AxisLine(width: 0),
                              ),
                              legend: Legend(isVisible: true),
                              series: <ChartSeries>[
                                LineSeries<ChartData, String>(
                                  dataSource: chartData,
                                  xValueMapper: (ChartData data, _) =>
                                      data.month,
                                  yValueMapper: (ChartData data, _) =>
                                      data.value,
                                  // name: 'Depression',
                                  color: Colors.purple,
                                  markerSettings: MarkerSettings(
                                    isVisible: true,
                                  ),
                                ),
                              ],
                            ),
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
