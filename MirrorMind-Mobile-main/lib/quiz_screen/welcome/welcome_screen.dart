import 'package:flutter/material.dart';
import 'package:mirrormind/config/theme/theme.dart';
import 'package:mirrormind/constants.dart';
import 'package:mirrormind/quiz_screen/quiz/quiz_screen.dart';


class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // Set your desired background color here
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacer(flex: 2), //2/6
                Text(
                  "Let's Play Quiz,",
                  style: Theme.of(context).textTheme.headline4?.copyWith(
                      color: AppColors.colorPrimary,
                      fontWeight: FontWeight.w600),
                ),
                Text("Enter your informations below"),
                Spacer(), // 1/6
                // TextField(
                //   decoration: InputDecoration(
                //     filled: true,
                //     fillColor: AppColors.colorPrimaryLight,
                //     hintText: "Full Name",
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.all(Radius.circular(12)),
                //     ),
                //   ),
                // ),
                // Spacer(), // 1/6
                InkWell(
                  onTap: () {
                    // Navigate to the second screen
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => QuizScreen()));
                  },
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(20), // 15
                    decoration: BoxDecoration(
                      gradient: kPrimaryGradient,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Text(
                      "Lets Start Quiz",
                      style: TextStyle(
                        color:Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Spacer(flex: 2), 
                // ElevatedButton(
                //     onPressed: () {
                //     // Navigate to the second screen
                //     Navigator.push(context,
                //         MaterialPageRoute(builder: (context) => Explore()));
                //     },
                    
                //     style: ElevatedButton.styleFrom(
                //       primary: Colors.green, // Change button color here
                //     ),
                //     child: Text('Exit'),
                //   ),// it will take 2/6 spaces
              ],
            ),
          ),
        ),
      ),
    );
  }
}
