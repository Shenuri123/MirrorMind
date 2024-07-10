import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mirrormind/model/model.dart';
import 'package:mirrormind/screen/home/widget/startyourday-tile.dart';
import 'package:mirrormind/util/helper/startyourday-helper.dart';
import 'package:mirrormind/config/theme/theme.dart';

class StartYourDay extends StatefulWidget {
  const StartYourDay({Key? key}) : super(key: key);

  @override
  State<StartYourDay> createState() => _StartyourdayState();
}

class _StartyourdayState extends State<StartYourDay> {
  List<Startyourday> _startyourdays = [];

  @override
  void didChangeDependencies() {
    _getStartyourday();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_viewAll(), SizedBox(height: 20.h), _card(context)],
    );
  }

  Widget _card(BuildContext context) {
    return SizedBox(
      height: 240.h,
      child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _startyourdays.length,
          clipBehavior: Clip.none,
          separatorBuilder: (BuildContext context, int index) => SizedBox(
                width: 25.w,
              ),
          itemBuilder: (context, index) {
            return GestureDetector(
                // onTap: () {
                //   setState(() {
                //     for (var element in _startyourdays) {
                //       element.isSelected = false;
                //     }
                //     _startyourdays[index].isSelected = true;
                //   });
                // },
                child: StartyourdaysTile(
              startyourday: _startyourdays[index],
            ));
          }),
    );
  }

  Future<void> _getStartyourday() async {
    _startyourdays = await StartyourdaysHelper.getStartyourday();
    setState(() {});
  }

  Widget _viewAll() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Start Your Day',
          style: TextStyle(
              color: AppColors.colorPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 19.sp),
        ),
      ],
    );
  }
}
