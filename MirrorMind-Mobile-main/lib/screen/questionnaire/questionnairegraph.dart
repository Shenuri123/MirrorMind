import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;

class DepressionData {
  final DateTime date;
  final num result;
  final String moodText;

  DepressionData(this.date, this.result, this.moodText);

  num? get depressionValue {
    if (result is num) {
      return result as num;
    }
    return null;
  }
}

enum TimePeriod { Week, Month }

class QuestionnaireAnalysis extends StatefulWidget {
  @override
  _SocialMediaGraphState createState() => _SocialMediaGraphState();
}

class _SocialMediaGraphState extends State<QuestionnaireAnalysis> {
  TimePeriod selectedTimePeriod = TimePeriod.Month;
  List<DepressionData> depressionData = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    getDataFromFirebase();
  }

  void getDataFromFirebase() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
        error = 'User not signed in';
      });
      return;
    }

    print('User ID: ${user.uid}'); // Print user ID for debugging

    CollectionReference users = FirebaseFirestore.instance.collection('users');

    DateTime now = DateTime.now();
    DateTime startPeriod = selectedTimePeriod == TimePeriod.Week
        ? now.subtract(Duration(days: 7))
        : now.subtract(Duration(days: 30));

    print('Start Period: $startPeriod'); // Print start period for debugging

    try {
      QuerySnapshot snapshot = await users
          .doc(user.uid)
          .collection('questionnaireanalysis')
          //.where('timestamp', isGreaterThanOrEqualTo: startPeriod) // Commented out for debugging
          .orderBy('timestamp', descending: false)
          .get();

      print(
          'Documents Fetched: ${snapshot.docs.length}'); // Print number of documents fetched

      depressionData = snapshot.docs
          .map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            Timestamp timestampTimestamp = data['timestamp'];
            DateTime timestamp = timestampTimestamp.toDate();
            String resultString =
                data['result'].toString(); // Convert result to string
            num? result =
                num.tryParse(resultString); // Try to convert result to num
            if (result == null) {
              print('Error: Unable to parse result to number: $resultString');
              return null; // Return null if parsing fails
            }
            String moodText = data['moodText'] ?? '';
            return DepressionData(timestamp, result, moodText);
          })
          .where((data) => data != null)
          .cast<DepressionData>()
          .toList(); // Filter out null values

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data from Firestore: $e");
      setState(() {
        isLoading = false;
        error = 'Error fetching data';
      });
    }
  }

    void shareReport() async {
    await generateSocialMediaPDF();
    final directory = await getExternalStorageDirectory();
    final filePath = '${directory!.path}/Questionnaire Analysis Report.pdf';

    final file = File(filePath);
    if (await file.exists()) {
      Share.shareFiles([filePath], text: 'Questionnaire Analysis Report');
    } else {
      print('Error: File does not exist at $filePath');
      // Consider showing an error message to the user
    }
  }

  Future<void> generateSocialMediaPDF() async {
    final pdf = pw.Document();

    final tableHeaders = ['Date', 'Result'];

    final tableData = depressionData
        .map((data) => [data.date, data.result.toString()])
        .toList();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Center(
                child: pw.Text(
                  'Questionnaire Analysis Report',
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
        final file = File('${directory.path}/Questionnaire Analysis Report.pdf');
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
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: 200,
                      child: Text(
                        'Questionnaire Analysis',
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
                                interval: 0.02,
                                majorGridLines: MajorGridLines(width: 0),
                                axisLine: AxisLine(width: 0),
                              ),
                              legend: Legend(isVisible: true),
                              series: <ChartSeries>[
                                LineSeries<DepressionData, String>(
                                  dataSource: depressionData,
                                  xValueMapper: (DepressionData data, _) =>
                                      DateFormat(selectedTimePeriod ==
                                                  TimePeriod.Week
                                              ? 'E'
                                              : 'MMMM d')
                                          .format(data.date),
                                  yValueMapper: (DepressionData data, _) =>
                                      data.depressionValue,
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
