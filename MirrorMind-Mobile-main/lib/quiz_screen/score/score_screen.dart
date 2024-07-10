import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mirrormind/provider/sign_in_provider.dart'; // Import the SignInProvider
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrormind/constants.dart';
import 'package:mirrormind/controllers/question_controller.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../welcome/welcome_screen.dart';
import 'package:http/http.dart' as http;

class ScoreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    QuestionController _qnController = Get.put(QuestionController());
    SignInProvider _signInProvider = Provider.of<SignInProvider>(context,
        listen: false); // Initialize the SignInProvider

    void updateFirestoreWithScore() async {
      int correctAnswers = _qnController.numOfCorrectAns;
      int totalQuestions = _qnController.questions.length;
      int score = correctAnswers * 10;
      int maxScore = totalQuestions * 10;

      // Get the current date and time
      DateTime now = DateTime.now();

      // Update Firestore with the quiz game information
      await _signInProvider.updateQuizGameInfo(score, maxScore, now);

      // You can also navigate to a new screen or perform any other actions after updating Firestore.
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SvgPicture.asset("assets/icons/bg.svg", fit: BoxFit.fill),
          Column(
            children: [
              Spacer(flex: 3),
              Text(
                "Score",
                style: Theme.of(context)
                    .textTheme
                    .headline3
                    ?.copyWith(color: kSecondaryColor),
              ),
              Spacer(),
              Text(
                "${_qnController.numOfCorrectAns * 10}/${_qnController.questions.length * 10}",
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    ?.copyWith(color: kSecondaryColor),
              ),
              Spacer(),
              Row(
                // This row contains the buttons
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Update Firestore with the score
                      int correctAnswers = _qnController.numOfCorrectAns;
                      int totalQuestions = _qnController.questions.length;
                      int score = correctAnswers * 10;
                      int maxScore = totalQuestions * 10;
                      updateFirestoreWithScore();

                      await sendUserResponses(context, score, maxScore);
                    },
                    child: const Text('Check your level!'),
                    // ...
                  ),
                ],
              ),
              Spacer(flex: 3),
            ],
          )
        ],
      ),
    );
  }

  Future<bool> sendUserResponses(
      BuildContext context, int score, int maxScore) async {
    final String serverUrl =
        'http://10.0.2.2:8000/funfour'; // Update the URL endpoint
    final Map<String, dynamic> data = {
      "x": [score], // Wrap moves in a list
      "y": [maxScore], // Wrap time in a list
    };

    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData.containsKey('level')) {
          final result = responseData['level'];
          print('API Response: $result');

          // Show the API response in a dialog
          showResultDialog(context, '$result');

          final user = FirebaseAuth.instance.currentUser;
          CollectionReference users =
              FirebaseFirestore.instance.collection('users');

          await users.doc(user?.uid).collection('quizgameanalysis').doc().set({
            'timestamp': FieldValue.serverTimestamp(),
            'result': result,
          });

          return true; // Indicate success
        } else {
          print('Invalid API Response Format');
          return false; // Indicate failure
        }
      } else {
        print('API Error: ${response.statusCode}');
        return false; // Indicate failure
      }
    } catch (e) {
      print('Error sending request: $e');
      return false; // Indicate failure
    }
  }

  Future<void> showResultDialog(
      BuildContext context, String resultMessage) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Your Depression Level:'),
          content: Text(resultMessage),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Go to Home'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomeScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
