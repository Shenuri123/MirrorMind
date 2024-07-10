import 'package:flutter/material.dart';
import 'package:mirrormind/config/theme/theme.dart';
import 'package:mirrormind/screen/src/my_app.dart';

class puzzlegame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Puzzle()));
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.colorPrimary,
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Center(
          child: Text(
            "Image Puzzles",
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
