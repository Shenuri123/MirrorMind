import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mirrormind/config/theme/theme.dart';
import 'package:mirrormind/screen/socialmedia/disorderemotiongraph.dart';
import 'dart:io';

import 'package:mirrormind/screen/socialmedia/disordergraph.dart';

class PredictionResult {
  final String textResult;
  final Map<String, double> emotionsPercentages;

  PredictionResult(
      {required this.textResult, required this.emotionsPercentages});

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    Map<String, double> emotions = {};
    json['emotions_percentages'].forEach((key, value) {
      emotions[key] = value.toDouble();
    });
    return PredictionResult(
      textResult: json['text_result'],
      emotionsPercentages: emotions,
    );
  }
}

class DisorderScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<DisorderScreen> {
  TextEditingController textController = TextEditingController();
  String? selectedFilePath;
  bool isLoading = false;
  PredictionResult? predictionResult;

  Future<void> getPrediction() async {
    if (selectedFilePath == null || textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter text and select a file.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    var uri = Uri.parse('http://10.0.2.2:8000/funone')
        .replace(queryParameters: {'text': textController.text});
    var request = http.MultipartRequest('POST', uri)
      ..files.add(
          await http.MultipartFile.fromPath('audio_file', selectedFilePath!));

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        // Decode the response
        var responseBody = await response.stream.bytesToString();
        var decodedJson = jsonDecode(responseBody);
        var result = PredictionResult.fromJson(decodedJson);

        setState(() {
          predictionResult = result;
        });

        // Save the results to Firestore
        await saveAndSendReport(
            textController.text, result.textResult, result.emotionsPercentages);

        print('Prediction successful');
      } else {
        print('Prediction failed with status: ${response.statusCode}');
        response.stream.transform(utf8.decoder).listen((value) {
          print(value);
        });
      }
    } catch (error) {
      print('Failed to get prediction: $error');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveAndSendReport(String text, String textResult,
      Map<String, double> emotionsPercentages) async {
    final user = FirebaseAuth.instance.currentUser;
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    try {
      await users.doc(user?.uid).collection('disorderanalysis').doc().set({
        'timestamp': FieldValue.serverTimestamp(),
        'text': text,
        'text_result': textResult,
        'emotions_percentages': emotionsPercentages,
      });

      // Call the shareReport function after saving the data
      // shareReport(text, textResult, emotionsPercentages);
    } catch (e) {
      print("Error writing to Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Identification the disorder'),
          leading: BackButton(),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Input text and select a .wav file, and get predictions.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: textController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Enter data here',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['wav'],
                    );
                    if (result != null) {
                      setState(() {
                        selectedFilePath = result.files.single.path;
                      });
                    }
                  },
                  child: Text('Browse and Add .wav Audio File'),
                  style: ElevatedButton.styleFrom(
                    primary: AppColors.colorPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                if (selectedFilePath != null) ...[
                  SizedBox(height: 20),
                  Text('Selected File: $selectedFilePath'),
                ],
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : getPrediction,
                  child: isLoading
                      ? CircularProgressIndicator()
                      : Text('Get Prediction'),
                  style: ElevatedButton.styleFrom(
                    primary: AppColors.colorPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                if (predictionResult != null) ...[
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Depression Level: ${predictionResult!.textResult}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.colorPrimary,
                        // Set the text color here
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Emotions:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.colorPrimary,
                        // Set the text color here
                      ),
                    ),
                  ),
                  ...predictionResult!.emotionsPercentages.entries
                      .map((e) => Center(
                            child: Text('${e.key}: ${e.value}%'),
                          )),
                ],
                SizedBox(height: 20),
                DisorderEmotionAnalysis(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ));
  }
}
