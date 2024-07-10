import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;

class DepressionData {
  final String date;
  final String mood;

  DepressionData(this.date, this.mood);

  num? get moodValue {
    if (mood == 'Depression decreasing') {
      return 1.0;
    } else if (mood == 'Depression increasing') {
      return 2.0;
    }
    return null; // Return null for other cases (handle this as needed)
  }
}

enum TimePeriod { Week, Month }

class PuzzleGameAnalysis extends StatefulWidget {
  @override
  _SocialMediaGraphState createState() => _SocialMediaGraphState();
}

class _SocialMediaGraphState extends State<PuzzleGameAnalysis> {
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
          .collection('puzzlegameanalysis')
          .where('timestamp', isGreaterThanOrEqualTo: startPeriod)
          .get();

      depressionData.clear();

      for (var doc in snapshot.docs) {
        // Correctly handle the Timestamp field
        Timestamp timestampTimestamp = doc['timestamp'];
        DateTime timestamp = timestampTimestamp.toDate();
        String result = doc['result'] ?? '';

        if (result.isNotEmpty) {
          depressionData.add(DepressionData(
            DateFormat(selectedTimePeriod == TimePeriod.Week ? 'E' : 'MMMM d')
                .format(timestamp),
            result,
          ));
          print(
              'Date: ${DateFormat(selectedTimePeriod == TimePeriod.Week ? 'E' : 'MMMM d').format(timestamp)}, Mood: $result');
        }
      }

      setState(() {});
    } catch (e) {
      print("Error fetching data from Firestore: $e");
    }
  }

  void shareReport() async {
    await generateSocialMediaPDF();
    final directory = await getExternalStorageDirectory();
    final filePath = '${directory!.path}/Puzzle Game Report.pdf';

    final file = File(filePath);
    if (await file.exists()) {
      Share.shareFiles([filePath], text: 'Puzzle Game Report');
    } else {
      print('Error: File does not exist at $filePath');
      // Consider showing an error message to the user
    }
  }

  Future<void> generateSocialMediaPDF() async {
    final pdf = pw.Document();

    final tableHeaders = ['Depression Status', 'Date'];

    final tableData = depressionData
        .map((data) => [data.date, data.mood.toString()])
        .toList();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Center(
                child: pw.Text(
                  'Puzzle Game Report',
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
        final file = File('${directory.path}/Puzzle Game Report.pdf');
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
                        'Puzzle Game Analysis',
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
                            data.moodValue,
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
