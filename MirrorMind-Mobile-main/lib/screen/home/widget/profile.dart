import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mirrormind/config/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:mirrormind/provider/sign_in_provider.dart'; // Import the SignInProvider

class Profile extends StatefulWidget {
  const Profile({key});

  @override
  State<Profile> createState() => _nameState();
}

class _nameState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final signInProvider = context
        .watch<SignInProvider>(); // Access the SignInProvider using Consumer

    return Container(
      color: AppColors.homebg,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: signInProvider.imageUrl != null
                ? NetworkImage(signInProvider
                    .imageUrl!) // Use the imageUrl from SignInProvider if not null
                : null, // If imageUrl is null, don't set the backgroundImage
          ),
          Container(
            height: 41.w,
            width: 41.w,
            margin: EdgeInsets.only(right: 15.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage('assets/logo.png'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
