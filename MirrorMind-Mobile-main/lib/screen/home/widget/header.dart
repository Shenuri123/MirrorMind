import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mirrormind/config/theme/theme.dart';

class HomeHeader extends StatelessWidget {
  HomeHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: _getYouOrderText(),
          ),
        ],
      ),
    );
  }

  Widget _getYouOrderText() {
    final user = FirebaseAuth.instance.currentUser!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hi ' + user.displayName!,
          style: TextStyle(
              color: AppColors.colorPrimary,
              fontSize: 35.sp,
              fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        Text(
          'How are you feeling today?',
          style: TextStyle(
              color: AppColors.colorPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}
