import 'package:flutter/material.dart';
import 'package:mirrormind/config/theme/theme.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;

  const MyButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: AppColors.colorPrimary,
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Center(
          child: Text("Sign In",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14)),
        ),
      ),
    );
  }
}
