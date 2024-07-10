import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:mirrormind/config/theme/theme.dart';
import 'package:mirrormind/provider/sign_in_provider.dart';
import 'package:mirrormind/quiz_screen/quiz/components/quizgameanalysis.dart';
import 'package:mirrormind/screen/socialmedia/socialmediaanalysis.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SocialMediaScreen extends StatefulWidget {
  static const String routeName = '/nlp_prediction';

  @override
  _NlpPredictionScreenState createState() => _NlpPredictionScreenState();
}

Future<void> shareReport(String text, String score, String prediction) async {
  final String report =
      'Post Caption: $text\nScore: $score\nPrediction: $prediction';
  await Share.share(report, subject: 'Feelings Analysis Report');
}

// ... [Your other code remains unchanged] ...

enum FilterOption { Weekly, Monthly }

class _NlpPredictionScreenState extends State<SocialMediaScreen> {
  FilterOption _selectedOption = FilterOption.Weekly;

  void _checkSocialMediaConnections() {
    final signInProvider = Provider.of<SignInProvider>(context, listen: false);

    if (!signInProvider.isSignedInWithFacebook &&
        !signInProvider.isSignedInWithTwitter) {
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('No Social Media Connected'),
        content:
            Text('Please connect to Facebook or Twitter to use this feature.'),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Add post frame callback to ensure the widget build is complete before checking
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _checkSocialMediaConnections();
      _loadCaptionFromPreferences();
    });
  }

  final TextEditingController textEditingController = TextEditingController();
  String result = '';
  String resultScore = '';
  String resultPrediction = '';

  Future<void> _loadCaptionFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('twitterUsername');

    if (username != null && username.isNotEmpty) {
      final caption = await _fetchLastTweet(username);
      if (caption != null) {
        textEditingController.text = caption;
      }
    }
  }

  Future<String?> _fetchLastTweet(String username) async {
    print(username);
    String url =
        "https://api.twitter.com/1.1/users/lookup.json?screen_name=$username&tweet_mode=extended";
    final response = await http.get(Uri.parse(url), headers: {
      // Add your Twitter API Bearer Token here
      'Authorization':
          'Bearer AAAAAAAAAAAAAAAAAAAAADu9qQEAAAAABloIPg2uVECNPysed%2F0IEpIRfxE%3D9tg0dhNBRhD8he4kXmT7ockN6db0REzbEQq4L8qqZjuNNn657I',
    });

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      String lastTweetText = data[0]['status']['full_text'];
      print('Last Tweet|: $lastTweetText');
      return lastTweetText;
    } else {
      print("Error fetching tweet");
      return null;
    }
  }

  Future<void> sendTextForPrediction(String text) async {
    final String serverUrl =
        'http://10.0.2.2:8000/funthree'; // Update with your endpoint URL

    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );
      print('Raw API Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        double rawScore = 0.0;
        // Try to parse the score from the string
        try {
          String scoreStr = responseData['score'];
          scoreStr = scoreStr.replaceAll("[", "").replaceAll("]", "").trim();
          rawScore = double.parse(scoreStr);
        } catch (e) {
          print('Error parsing the score: $e');
        }

        final predictionResult = responseData['result'];

        setState(() {
          resultScore =
              '${(rawScore * 100).toStringAsFixed(2)}%'; // Convert to percentage
          resultPrediction = '$predictionResult';
        });

        print('Score: $resultScore');
        print('Prediction Result: $resultPrediction');
        saveAndSendReport(text, predictionResult);
      } else {
        setState(() {
          result = 'API Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        result = 'Error sending request: $e';
      });
    }
  }

  Future<void> saveAndSendReport(String text, String predictionResult) async {
    final user = FirebaseAuth.instance.currentUser;
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    try {
      await users.doc(user?.uid).collection('socialmediaanalysis').doc().set({
        'timestamp': FieldValue.serverTimestamp(),
        'resultScore': resultScore,
        'resultPrediction': predictionResult,
      });

      // Call the shareReport function after saving the data
      // shareReport(text, resultScore, resultPrediction);
    } catch (e) {
      print("Error writing to Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Feelings Analysis by Social Media',
          style: TextStyle(
            color: AppColors.colorPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back button action here
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .center, // Centering Row items horizontally
                children: [
                  Image.asset('assets/icons/fb.png',
                      width: 30,
                      height: 30), // Set your desired width and height
                  SizedBox(width: 20), // For spacing
                  Image.asset('assets/icons/twitter.png',
                      width: 30, height: 30),
                  SizedBox(width: 20),
                  Image.asset('assets/icons/insta.png', width: 30, height: 30),
                ],
              ),
              const SizedBox(height: 30),
              const Text('Enter your feelings today as a text!'),
              TextField(
                controller: textEditingController,
                decoration: InputDecoration(
                  labelText:
                      'Already your twitter last tweet automatically added.',
                  labelStyle: TextStyle(
                      color: AppColors.colorPrimary), // Change text color here
                ),
                minLines: 1, //Minimum lines
                maxLines: null, //Allows for infinite expansion
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  final String? username = prefs.getString('twitterUsername');
                  if (username != null && username.isNotEmpty) {
                    final caption = await _fetchLastTweet(username);
                    if (caption != null) {
                      textEditingController.text = caption;
                    }
                  }
                },
                child: const Text('Fetch Latest Twitter Post'),
                style: ElevatedButton.styleFrom(
                  primary: AppColors.colorPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final text = textEditingController.text;
                  if (text.isNotEmpty) {
                    sendTextForPrediction(text);
                  }
                },
                child: const Text('Analyze My Feelings'),
                style: ElevatedButton.styleFrom(
                  primary: AppColors
                      .colorPrimary, // Set the button background color here
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        20.0), // Adjust the radius as needed
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4, // You can adjust the elevation as needed
                margin:
                    EdgeInsets.all(16), // You can adjust the margin as needed
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center vertically
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Center horizontally
                    children: [
                      Text(
                        'Feelings Analysis Report',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color:
                              AppColors.colorPrimary, // Set the text color here
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Score: ${resultScore}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color:
                              AppColors.colorPrimary, // Set the text color here
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${resultPrediction}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color:
                              AppColors.colorPrimary, // Set the text color here
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              socialmediaanalysis(),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
