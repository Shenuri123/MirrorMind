import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mirrormind/config/theme/theme.dart';
import 'package:mirrormind/model/model.dart';

class QuotesTile extends StatelessWidget {
  final Quote quote;

  const QuotesTile({
    required this.quote,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0.h,
      width: 338.0.w,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage('assets/images/quotes.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 30.0.w,
                width: 30.0.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Image.asset(
                    'assets/images/message.png'), // Add the icon image asset path
              ),
              SizedBox(width: 20.0),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quote.name, // Add your date text here
                      style: TextStyle(
                          color: AppColors.colorPrimary,
                          fontSize: 19.0,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      quote.description, // Add your short daily quote here
                      style: TextStyle(
                          color: AppColors.colorPrimary,
                          fontSize: 17.0,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
