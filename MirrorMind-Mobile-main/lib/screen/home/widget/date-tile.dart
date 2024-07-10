import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mirrormind/config/theme/theme.dart';
import 'package:mirrormind/model/model.dart';

class DateTile extends StatelessWidget {
  final Date date;
  const DateTile({required this.date, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0.h,
      width: 62.0.w,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(31),
        border: Border.all(
          color:
              date.isSelected ? AppColors.colorPrimary : AppColors.colorborder,
          width: 2.0,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 45.0.w,
            width: 45.0.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(image: AssetImage(date.iconPath)),
            ),
          ),
          Text(
            date.name,
            style: TextStyle(
              color: date.isSelected
                  ? AppColors.colorPrimary
                  : AppColors.colorPrimaryLight,
              fontWeight: FontWeight.w500,
              fontSize: 15.sp,
            ),
          ),
        ],
      ),
    );
  }
}
