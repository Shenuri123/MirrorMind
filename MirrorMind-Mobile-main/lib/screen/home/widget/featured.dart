import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mirrormind/config/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Featured extends StatefulWidget {
  @override
  _FeaturedState createState() => _FeaturedState();
}

class _FeaturedState extends State<Featured> {
  double totalSocialMediaUsage = 0;
  double sleepHours = 0;

  @override
  void initState() {
    super.initState();
    sleepHoursStream();
    fetchDataFromFirebase().then((data) {
      double totalUsage = 0;
      for (var app in ['twitter', 'facebook', 'instagram']) {
        for (var day in data[app]!.values) {
          totalUsage += day;
        }
      }
      setState(() {
        totalSocialMediaUsage = totalUsage;
      });
    });
  }

  Stream<double> sleepHoursStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((snapshot) {
        return double.tryParse(snapshot.data()?['hos'] ?? '0') ?? 0;
      });
    } else {
      return Stream.value(0);
    }
  }

  Stream<double> socialMediaUsageStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('social_media_usage')
          .snapshots()
          .map((snapshot) {
        double totalUsage = 0;
        for (var document in snapshot.docs) {
          totalUsage += document.data()?['usage_in_hours'] ?? 0;
        }
        return totalUsage;
      });
    } else {
      return Stream.value(0);
    }
  }

  Future<Map<String, Map<String, double>>> fetchDataFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    DateTime today = DateTime.now();
    DateTime oneWeekAgo = today.subtract(Duration(days: 7));

    Map<String, Map<String, double>> weekData = {
      'twitter': {},
      'facebook': {},
      'instagram': {},
    };

    for (int i = 0; i < 7; i++) {
      DateTime day = oneWeekAgo.add(Duration(days: i));
      String yearMonthDay =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

      for (String app in ['twitter', 'facebook', 'instagram']) {
        var doc = await users
            .doc(user?.uid)
            .collection('social_media')
            .doc(app)
            .collection(yearMonthDay)
            .get();
        double totalHours = 0;
        for (var item in doc.docs) {
          totalHours += (item.data()?['usage_in_hours'] ?? 0);
        }
        weekData[app]![day.weekday.toString()] = totalHours;
      }
    }
    return weekData;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _viewAll(),
        SizedBox(height: 20.h),
        Row(
          children: [
            _food(context),
            SizedBox(width: 10.w),
            _socialmedia(context),
          ],
        )
      ],
    );
  }

  Widget _food(BuildContext context) {
    return StreamBuilder<double>(
      stream: sleepHoursStream(),
      builder: (context, snapshot) {
        double sleepHours = snapshot.data ?? 0;
        return GestureDetector(
          child: Stack(
            children: [
              Container(
                height: 132.h,
                width: 162.w,
                decoration: BoxDecoration(
                  color: AppColors.colorsleep,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 20.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Sleep Time',
                              style: TextStyle(
                                  color: AppColors.colorPrimary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 19.sp),
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                            Text(
                              '${sleepHours.toStringAsFixed(1)}hr',
                              style: TextStyle(
                                  color: AppColors.colorPrimary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 30.sp),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _socialmedia(BuildContext context) {
    return GestureDetector(
      //onTap: () => Navigator.pushNamed(context,OrderScreen.routeName) ,
      child: Stack(
        children: [
          Container(
            height: 132.h,
            width: 162.w,
            //margin: EdgeInsets.only(top: 20. h),
            //padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(253, 236, 226, 1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 20.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Social Media',
                          style: TextStyle(
                              color: AppColors.colorPrimary,
                              fontWeight: FontWeight.w500,
                              fontSize: 19.sp),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Text(
                          '${totalSocialMediaUsage.toStringAsFixed(1)}hr',
                          style: TextStyle(
                              color: AppColors.colorPrimary,
                              fontWeight: FontWeight.w500,
                              fontSize: 30.sp),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewAll() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Featured',
          style: TextStyle(
              color: AppColors.colorPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 19.sp),
        )
      ],
    );
  }
}
