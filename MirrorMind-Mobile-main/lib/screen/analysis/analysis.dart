import 'package:flutter/material.dart';
import 'package:mirrormind/quiz_screen/quiz/components/puzzlegameanalysis.dart';
import 'package:mirrormind/quiz_screen/quiz/components/quizgameanalysis.dart';

class Chart extends StatefulWidget {
  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(20), // Add padding for top
                child: DepressionAnalysis(),
              ),
              Padding(
                padding: EdgeInsets.all(20), // Add padding between widgets
                child: PuzzleGameAnalysis(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
