import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mirrormind/config/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mirrormind/screen/questionnaire/questionnairegraph.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class SleepScreen extends StatefulWidget {
  @override
  _SleepScreenState createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ImagePicker _picker = ImagePicker();
  List<File?> capturedImages = [null, null, null, null];
  String? _output;

  Interpreter? _interpreter;
  bool _isProcessingImage = false;

  String resultImg1 = "neutral";
  String resultImg2 = "neutral";
  String resultImg3 = "neutral";
  String resultImg4 = "neutral";

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      final interpreter =
          await Interpreter.fromAsset('assets/emotion_detection_model.tflite');
      setState(() => _interpreter = interpreter);
    } catch (e) {
      print("Error loading model: $e");
      Fluttertoast.showToast(
        msg: "Error loading model",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  // Store the user's answers
  Map<int, String> userAnswers = {};

  // Questions and options
  List<Map<String, dynamic>> questions = [
    {
      'question':
          'Have you noticed any differences in how you express your emotions through your facial expressions lately?',
      'options': [
        'Ive noticed that I hardly express anything anymore. My face feels numb most of the time.',
        'I think I still express my emotions like I used to, although maybe less frequently.'
      ],
      'type': QuestionType.MCQ,
    },
    {
      'question':
          'Do you feel like your facial expressions match how youre feeling inside?',
      'options': [
        'Not really. Even when Im sad, I cant seem to show it on my face.',
        'Yes, I believe my facial expressions usually reflect how Im feeling.'
      ],
      'type': QuestionType.MCQ,
    },
    {
      'question':
          'How often do you find yourself genuinely smiling or laughing?',
      'options': [
        'I cant remember the last time I genuinely smiled or laughed.',
        'I still smile and laugh quite often, especially when something amuses me.'
      ],
      'type': QuestionType.MCQ,
    },
    {
      'question':
          'Have you noticed any changes in how you smile or laugh compared to before?',
      'options': [
        'When I do try to smile, it feels forced and empty',
        'I think my smiles and laughs are pretty much the same as before'
      ],
      'type': QuestionType.MCQ,
    },
  ];

  Future<String> _runModel(String imagePath) async {
    if (_interpreter == null) {
      try {
        _interpreter = await Interpreter.fromAsset(
            'assets/emotion_detection_model.tflite');
        print("Model loaded successfully");
      } catch (e) {
        print("Error loading model: $e");
        Fluttertoast.showToast(
          msg: "Error loading model",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        throw "Error loading model";
      }
    }

    try {
      final img.Image image =
          img.decodeImage(File(imagePath).readAsBytesSync())!;
      print("Image loaded and decoded");

      // Resize the image to 224x224
      final img.Image resizedImage =
          img.copyResize(image, width: 224, height: 224);
      print("Image resized to 224x224");

      // Normalize the image to range [0, 1]
      final Float32List normalizedImg = Float32List(224 * 224 * 1);
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final img.Pixel pixel = resizedImage.getPixelSafe(x, y);
          final int red = pixel.r.toInt();
          final int green = pixel.g.toInt();
          final int blue = pixel.b.toInt();

          final double grayValue =
              (0.299 * red + 0.587 * green + 0.114 * blue) / 255.0;
          normalizedImg[y * 224 + x] = grayValue;
        }
      }
      print("Image normalized");

      // Reshape the image to [1, 224, 224, 1]
      final input = normalizedImg.reshape([1, 224, 224, 1]);

      // Run the model
      final output = List.filled(8, 0.0).reshape([1, 8]); // Assuming 8 classes
      _interpreter!.run(input, output);
      print("Model inference completed");

      // Print the raw output from the model
      print("Raw model output: $output");

      // Find the predicted label
      var maxVal = output[0][0];
      var predictedLabel = 0;
      for (var i = 1; i < output[0].length; i++) {
        if (output[0][i] > maxVal) {
          predictedLabel = i;
          maxVal = output[0][i];
        }
      }
      print("Predicted label index: $predictedLabel");

      // Convert label to emotion
      var emotions = [
        'anger',
        'contempt',
        'disgust',
        'fear',
        'happiness',
        'neutrality',
        'sadness',
        'surprise'
      ];
      String emotion = emotions[predictedLabel];
      print("Predicted emotion: $emotion");

      // Map emotions to categories
      var emotionCategories = {
        'anger': 'sad',
        'contempt': 'sad',
        'disgust': 'sad',
        'fear': 'sad',
        'happiness': 'happy',
        'neutrality': 'neutral',
        'sadness': 'sad',
        'surprise': 'happy'
      };

      // Get the final category
      String finalCategory = emotionCategories[emotion] ?? 'Unknown';
      print("Final category: $finalCategory");

      return finalCategory;
    } catch (e) {
      print("Error running model: $e");
      Fluttertoast.showToast(
        msg: "Error analyzing image",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      throw "Error analyzing image";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Questionnaire',
          style: TextStyle(
            color: AppColors.colorPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        leading: BackButton(),
      ),
      key: _scaffoldKey,
      body: ListView.builder(
        padding: const EdgeInsets.all(4),
        itemCount: questions.length + 1, // Add 1 for the camera buttons
        itemBuilder: (context, index) {
          if (index < questions.length) {
            final question = questions[index];
            return QuestionCard(
              question: question['question'],
              options: question['options'] ?? [],
              type: question['type'],
              onAnswerSelected: (answer) {
                userAnswers[index] = answer;
              },
            );
          } else {
            return buildCameraButtons();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Map<String, dynamic> requestBody = {
            "img1": "neutral",
            "img2": "neutral",
            "img3": "neutral",
            "img4": "neutral",
          };
          sendUserResponses(requestBody);
        },
        backgroundColor: AppColors.colorPrimary,
        child: const Icon(Icons.check),
      ),
    );
  }

  Widget buildCameraButtons() {
    return Column(
      children: [
        Text("Default all cameras status is neutral: 0"),
        const SizedBox(height: 10),
        buildCameraButton(0),
        const SizedBox(height: 10),
        buildCapturedImage(0),
        const SizedBox(height: 10),
        buildCameraButton(1),
        const SizedBox(height: 10),
        buildCapturedImage(1),
        const SizedBox(height: 10),
        buildCameraButton(2),
        const SizedBox(height: 10),
        buildCapturedImage(2),
        const SizedBox(height: 10),
        buildCameraButton(3),
        const SizedBox(height: 10),
        buildCapturedImage(3),
        const SizedBox(height: 30),
        // ElevatedButton(
        //   onPressed: () {},
        //   child: const Text('First Tap To Analys Your Facial Expresions'),
        //   style: ElevatedButton.styleFrom(
        //     primary:
        //         AppColors.colorPrimary, // Set the button background color here
        //     shape: RoundedRectangleBorder(
        //       borderRadius:
        //           BorderRadius.circular(20.0), // Adjust the radius as needed
        //     ),
        //   ),
        // ),
        const SizedBox(height: 40),
        QuestionnaireAnalysis(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget buildCapturedImage(int index) {
    final capturedImage = capturedImages[index];
    return capturedImage != null
        ? Image.file(
            capturedImage,
            width: 100,
            height: 100,
          )
        : const SizedBox();
  }

  Widget buildCameraButton(int index) {
    Future<void> _pickImage(int index) async {
      setState(() => _isProcessingImage = true);
      try {
        final XFile? image =
            await _picker.pickImage(source: ImageSource.camera);
        if (image != null) {
          final output = await _runModel(image.path);
          setState(() {
            capturedImages[index] = File(image.path);
            if (index == 0)
              resultImg1 = output;
            else if (index == 1)
              resultImg2 = output;
            else if (index == 2)
              resultImg3 = output;
            else if (index == 3) resultImg4 = output;
          });
          Fluttertoast.showToast(
            msg: "Image processed successfully!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );
        } else {
          Fluttertoast.showToast(
            msg: "Image capture cancelled",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );
        }
      } catch (e) {
        print("Error picking or processing image: $e");
        Fluttertoast.showToast(
          msg: "Error picking or processing image",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      } finally {
        setState(() => _isProcessingImage = false);
      }
    }

     

    return ElevatedButton(
      onPressed: () async {
        await _pickImage(
            index); // Replace 0 with the correct index for this button
      },
      child:  Text('Capture Image $index'),
      style: ElevatedButton.styleFrom(
        primary: AppColors.colorPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }

  Future<void> sendUserResponses(Map<String, dynamic> data) async {
    final String serverUrl = 'http://10.0.2.2:8000/funtwo';

    data['text1'] =
        "Have you noticed any differences in how you express your emotions through your facial expressions lately?, ${userAnswers[0] ?? ""}";
    data['text2'] =
        "Do you feel like your facial expressions match how you're feeling inside?, ${userAnswers[1] ?? ""}";
    data['text3'] =
        "How often do you find yourself genuinely smiling or laughing?, ${userAnswers[2] ?? ""}";
    data['text4'] =
        "Have you noticed any changes in how you smile or laugh compared to before?, ${userAnswers[3] ?? ""}";
    data['img1'] = resultImg1;
    data['img2'] = resultImg2;
    data['img3'] = resultImg3;
    data['img4'] = resultImg4;

    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey("percentage")) {
          final result = responseData["percentage"];

          String userMood;

          if (double.parse(result) < 0) {
            userMood = 'happy';
          } else if (double.parse(result) > 0) {
            userMood = 'sad';
          } else {
            userMood = 'neutral';
          }
          String moodText;
          switch (userMood) {
            case 'happy':
              moodText = 'Happy 😃';
              break;
            case 'neutral':
              moodText = 'Neutral 😐';
              break;
            case 'sad':
              moodText = 'Sad ☹️';
              break;
            default:
              moodText = 'Unknown';
          }

          Fluttertoast.showToast(
            msg: 'User Mood: $moodText\nDepression Level: $result%',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 5,
            backgroundColor: userMood == 'happy'
                ? Colors.green
                : userMood == 'neutral'
                    ? Colors.blue
                    : Colors.red,
            textColor: Colors.white,
          );

          // Get the current user
          final user = FirebaseAuth.instance.currentUser;
          // Reference to Firestore collection
          CollectionReference users =
              FirebaseFirestore.instance.collection('users');

          if (user != null) {
            try {
              await users
                  .doc(user.uid)
                  .collection('questionnaireanalysis')
                  .doc()
                  .set({
                'timestamp': FieldValue.serverTimestamp(),
                'moodText': moodText,
                'result': result,
              });

              Fluttertoast.showToast(
                msg: 'Response saved successfully!',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 3,
              );
            } catch (e) {}
          } else {}
        } else {}
      } else {
        print("Server error: ${response.body}");
        Fluttertoast.showToast(
          msg: "Server error. Please try again later.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }
    } catch (e) {
      print("Network error: $e");
      Fluttertoast.showToast(
        msg: "Network error. Please try again later.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }
}

enum QuestionType {
  MCQ,
}

class QuestionCard extends StatefulWidget {
  final String question;
  final List<String> options;
  final QuestionType type;
  final void Function(String) onAnswerSelected;

  QuestionCard({
    required this.question,
    required this.options,
    required this.type,
    required this.onAnswerSelected,
  });

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  String? selectedOption;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.colorPrimary,
              ),
            ),
            const SizedBox(height: 10),
            if (widget.type == QuestionType.MCQ)
              Column(
                children: widget.options.map((option) {
                  return RadioListTile(
                    title: Text(
                      option,
                      style: const TextStyle(color: AppColors.colorPrimary),
                    ),
                    value: option,
                    groupValue: selectedOption,
                    activeColor: AppColors.colorPrimary,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value;
                        widget.onAnswerSelected(value!);
                      });
                    },
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
