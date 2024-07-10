import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mirrormind/screen/generated/l10n.dart';
import 'package:mirrormind/screen/src/ui/global/widgets/up_to_down.dart';
import 'package:mirrormind/screen/src/ui/icons/puzzle_icons.dart';
import 'package:mirrormind/screen/src/ui/utils/colors.dart';
import 'package:mirrormind/screen/src/ui/utils/dark_mode_extension.dart';
import 'package:mirrormind/screen/src/ui/utils/time_parser.dart';
import 'package:mirrormind/provider/sign_in_provider.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:http/http.dart' as http;

Future<void> showWinnerDialog(
  BuildContext context, {
  required int moves,
  required int time,
}) {
  return showDialog(
    context: context,
    builder: (_) => WinnerDialog(
      moves: moves,
      time: time,
    ),
  );
}

class WinnerDialog extends StatelessWidget {
  final int moves;
  final int time;
  const WinnerDialog({
    Key? key,
    required this.moves,
    required this.time,
  }) : super(key: key);

  Future<void> storePuzzleGameDataInFirestore(BuildContext context) async {
    SignInProvider _signInProvider =
        Provider.of<SignInProvider>(context, listen: false);

    String formattedTime = parseTime(time);
    String movementsText = "${S.current.movements} $moves";
    DateTime playDate = DateTime.now(); // Get the current date and time

    await _signInProvider.updatePuzzleGameData(
        formattedTime, movementsText, playDate);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final texts = S.current;
    final isDarkMode = context.isDarkMode;
    return Center(
      child: UpToDown(
        child: Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: isDarkMode ? darkColor : lightColor,
          child: SizedBox(
            width: 340,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 1.2,
                  child: Stack(
                    children: [
                      const Center(
                        child: RiveAnimation.asset(
                          'assets/rive/winner.riv',
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                texts.great_job,
                                style: const TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                              Text(
                                texts.completed,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    PuzzleIcons.watch,
                                  ),
                                  Text(
                                    parseTime(time),
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.multiple_stop_rounded,
                                  ),
                                  Text(
                                    "${texts.movements} $moves",
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  height: 0.6,
                  color: isDarkMode ? Colors.white24 : Colors.black12,
                ),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () async {
                      // Call the sendUserResponses function with moves and time
                      bool success =
                          await sendUserResponses(context, moves, time);

                      if (success) {
                        // If the API call is successful, store game data in Firestore
                        storePuzzleGameDataInFirestore(context);
                      } else {
                        // Handle API call failure
                        // You can show an error message to the user here
                      }
                    },
                    child: Text(
                      texts.ok,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

Future<void> showResultDialog(
  BuildContext context, String resultMessage) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Depression Level'),
        content: Text(resultMessage),
        actions: <Widget>[
          ElevatedButton(
            child: Text('OK'),
            onPressed: () {
              // Delay closing the dialog for 10 seconds
              Future.delayed(Duration(seconds: 10), () {
                Navigator.of(context).pop(); // Close the dialog
              });
            },
          ),
        ],
      );
    },
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

          await users.doc(user?.uid).collection('puzzlegameanalysis').doc().set({
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
}
