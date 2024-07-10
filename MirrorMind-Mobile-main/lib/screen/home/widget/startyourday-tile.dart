import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mirrormind/config/theme/theme.dart';
import 'package:mirrormind/model/model.dart';

class StartyourdaysTile extends StatelessWidget {
  final Startyourday startyourday;

  const StartyourdaysTile({
    required this.startyourday,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 228.0.h,
      width: 275.0.w,
      //padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.colorstardyourdaycard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.colorstardyourdaycardborder,
          width: 2.0,
        ),
      ),

      child: Stack(
        children: [
          Container(
            height: 135.0.h,
            width: 275.0.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              image: DecorationImage(
                  image: AssetImage(startyourday.iconPath), fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 120.0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.0),
                Row(
                  children: [
                    SizedBox(width: 10.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          startyourday.name,
                          style: TextStyle(
                            color: AppColors.colorPrimary,
                            fontSize: 19.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          startyourday.description,
                          style: TextStyle(
                            color: AppColors.colorPrimary,
                            fontSize: 17.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
