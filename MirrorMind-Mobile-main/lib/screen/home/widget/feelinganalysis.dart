import 'package:flutter/material.dart';
import 'package:mirrormind/config/theme/theme.dart';
import 'package:mirrormind/screen/socialmedia/socialmedia.dart';

class feelinganalysis extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SocialMediaScreen()));
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.colorPrimary,
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Center(
          child: Text(
            "Analys From Social Media ",
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
