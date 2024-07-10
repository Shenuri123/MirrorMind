import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mirrormind/model/screen_time_tracker.dart';
import 'package:mirrormind/screen/home/widget/disorder.dart';
import 'package:mirrormind/screen/home/widget/quizgame.dart';
import 'package:mirrormind/screen/home/widget/feelinganalysis.dart';
import 'package:mirrormind/screen/home/widget/progressiontrack.dart';
import 'package:mirrormind/screen/home/widget/puzzlegame.dart';
import 'package:mirrormind/screen/home/widget/quotes.dart';
import 'widget/dates.dart';
import 'widget/header.dart';
import 'widget/featured.dart';
import 'widget/checkin.dart';
import 'widget/startyourday.dart';
import 'widget/profile.dart';
import 'package:mirrormind/config/theme/theme.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = '/home';

  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final tracker = ScreenTimeTracker();

  @override
  void initState() {
    super.initState();

    tracker.onDataChanged = () {
      setState(() {});
    };

    tracker.startRealTimeTracking();
  }

  @override
  void dispose() {
    tracker.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homebg,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              const Profile(),
              SizedBox(height: 10.h),
              HomeHeader(),
              SizedBox(height: 30.h),
              const Quotes(),
              SizedBox(height: 30.h),
              const Dates(),
              SizedBox(height: 30.h),
              Row(
                children: [
                  puzzlegame(),
                  SizedBox(width: 30.h),
                  quizgame(),
                ],
              ),
              SizedBox(height: 30.h),
              // Checkin(),
              // Text(
              //     'Twitter screen time: ${tracker.twitterScreenTime.inMinutes} minutes'),
              // Text(
              //     'Facebook screen time: ${tracker.facebookScreenTime.inMinutes} minutes'),
              // Text(
              //     'Instagram screen time: ${tracker.instagramScreenTime.inMinutes} minutes'),
              // SizedBox(height: 30.h),
              Featured(),
              SizedBox(height: 30.h),
              progressiontrack(),
              SizedBox(height: 30.h),
              feelinganalysis(),
              SizedBox(height: 30.h),
              Disorder(),
              SizedBox(height: 30.h),
              const StartYourDay(),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
