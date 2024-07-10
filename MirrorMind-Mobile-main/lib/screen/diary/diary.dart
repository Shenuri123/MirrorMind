import 'package:flutter/material.dart';
import '../../config/theme/theme.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

class Diary extends StatefulWidget {
  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<Diary> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Store the user's answers
  Map<int, String> userAnswers = {};

  // Questions and options
  List<Map<String, dynamic>> questions = [
    {
      'question': 'How would you describe your overall outlook on the future?',
      'options': [
        'I am not particularly pessimistic or discouraged about the future.',
        'I feel discourage about the future.I feel I wont ever get over my troubles.',
        'I feel I have nothing to look forward to.',
        'I feel that the future is hopeless and that things cannot improve.'
      ],
      'type': QuestionType.MCQ,
    },
    {
      'question':
          'What level of self-worth do you believe you currently possess?',
      'options': [
        'I dont feel particularly guilty.',
        'I feel bad or unworthy a good part of the time.',
        'I feel quite guilty.I feel bad or unworthy practically all the time now.',
        'I feel as though I am very bad or worthless.'
      ],
      'type': QuestionType.MCQ,
    },
    {
      'question':
          'How do you feel about yourself when you make mistakes or fail?',
      'options': [
        'I dont feel disappointed in myself.',
        'I am disappointed in myself.I dont like myself.',
        'I am disgusted with myself.',
        'I hate myself.'
      ],
      'type': QuestionType.MCQ,
    },
    {
      'question':
          'The extent of your current thoughts about self-harm or suicide?',
      'options': [
        'I dont have any thoughts of harming myself.',
        'I have thoughts of harming myself, but I would not carry them out.',
        'I feel I would be better of dead.I feel my family would be better off if I were dead.',
        'I have definite plans about committing suicide.I would kill myself if I could.'
      ],
      'type': QuestionType.MCQ,
    },
    {
      'question':
          'What best describes your current level of irritation or annoyance?',
      'options': [
        'I am no more irritated now than I ever am.',
        'I get annoyed or irritated more easily than I used to.',
        'I feel irritated all the time now.',
        'I dont get irritated at all at the things that used to irritate me.'
      ],
      'type': QuestionType.MCQ,
    },
    {
      'question':
          'how would you rate your ability and approach to making decisions?',
      'options': [
        'I make decisions about as well as ever.',
        'I try to put off making decisions.',
        'I have great difficulty in making decisions.',
        'I cant make any decisions at all any more.'
      ],
      'type': QuestionType.MCQ,
    },
    {
      'question':
          'How would you describe your current level of motivation and ability to perform tasks?',
      'options': [
        'I can work about as well as before.',
        'It takes extra effort to get started at doing something.I dont work as well as I used to.',
        'I have to push myself very hard to do anything.',
        'I cant do any work at all.'
      ],
      'type': QuestionType.MCQ,
    },
    {
      'question':
          'What is your current level of satisfaction with various aspects of your life?',
      'options': [
        'I am not particularly dissatisfied.',
        'I feel bored most of the time.I dont enjoy things the way I used to.',
        'I dont get satisfaction out of anything any more.',
        'I am dissatisfied with everything.'
      ],
      'type': QuestionType.MCQ,
    },
    {
      'question':
          'What is your overall perception of your accomplishments and failures in life?',
      'type': QuestionType.Descriptive,
    },
    {
      'question': 'How would you describe your emotional state?',
      'type': QuestionType.Descriptive,
    },
    {
      'question':
          'How do you feel about your current appearance and any changes you might have noticed over time?',
      'type': QuestionType.Descriptive,
    },
    {
      'question':
          'How would you describe your emotions when considering the possibility of something bad happening to you?',
      'type': QuestionType.Descriptive,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Questionnaire',
          style: TextStyle(
            color: AppColors.colorPrimary, // Change to your desired text color
            fontSize: 20, // Adjust font size as needed
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center, // Align text in the center
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(4),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          return QuestionCard(
            question: question['question'],
            options: question['options'] ?? [],
            type: question['type'],
            onAnswerSelected: (answer) {
              userAnswers[index] = answer;
            },
          );
        },
      ),
      
      floatingActionButton: Builder(
        // Use a Builder widget to access the right context
        builder: (BuildContext context) {
          return FloatingActionButton(
            onPressed: () async {
              // Send user responses to the API
              final success = await sendUserResponses(userAnswers);

              if (success) {
                // Show a Snackbar with the success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Response received successfully'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            backgroundColor: AppColors.colorPrimary,
            child: const Icon(Icons.check),
          );
        },
      ),
    );
  }

Future<bool> sendUserResponses(Map<int, String> responses) async {
  final String serverUrl = 'http://10.0.2.2:8000/funone';
  print(responses);
  try {
    final response = await http.post(
      Uri.parse('$serverUrl?text=${responses}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Handle the API response here
      final responseData = json.decode(response.body);
      if (responseData is List && responseData.isNotEmpty) {
        final result = responseData[0];
        print('API Response: $result');
        
        // Show the result as a toast message
        Fluttertoast.showToast(
          msg: result,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.green, // Customize background color
          textColor: Colors.white,      // Customize text color
        );
        
        return true; // Indicate success
      } else {
        print('Invalid API Response Format');
        return false; // Indicate failure
      }
    } else {
      // Handle errors if any
      print('API Error: ${response.statusCode}');
      return false; // Indicate failure
    }
  } catch (e) {
    print('Error sending request: $e');
    return false; // Indicate failure
  }
}




  // ... (rest of the code remains the same)
}

enum QuestionType {
  MCQ,
  Descriptive,
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
  TextEditingController descriptiveAnswerController = TextEditingController();

  @override
  void dispose() {
    descriptiveAnswerController.dispose();
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
                    activeColor:
                        AppColors.colorPrimary, // Set active radio button color
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value;
                        widget.onAnswerSelected(value!);
                      });
                    },
                  );
                }).toList(),
              ),
            if (widget.type == QuestionType.Descriptive)
              TextField(
                controller: descriptiveAnswerController,
                decoration: const InputDecoration(
                  hintText: 'Enter your answer here',
                  hintStyle: TextStyle(
                    color: AppColors.colorPrimaryLight,
                    fontWeight: FontWeight.w400,
                  ), // Set hint text color
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(
                  color: AppColors.colorPrimaryLight,
                  fontWeight: FontWeight.w400,
                ),
                onChanged: widget.onAnswerSelected,
              ),
          ],
        ),
      ),
    );
  }
}
