import 'package:flutter/material.dart';
import 'package:mirrormind/config/theme/theme.dart';
import '../../../quiz_screen/welcome/welcome_screen.dart';

class quizgame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Use InkWell for tap detection
      onTap: () {
        // Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp())); // Replace Myapp with your actual screen
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.colorPrimary,
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Center(
          child: Text(
            "Word Quizzes",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
