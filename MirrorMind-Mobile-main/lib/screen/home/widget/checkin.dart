import 'package:flutter/material.dart';
import 'package:mirrormind/config/theme/theme.dart';

class Checkin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Use InkWell for tap detection
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.colorPrimary,
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Center(
          child: Text(
            "Check-In",
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
