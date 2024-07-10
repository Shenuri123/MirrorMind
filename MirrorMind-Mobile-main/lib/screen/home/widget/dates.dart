import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mirrormind/model/model.dart';
import 'package:mirrormind/screen/home/widget/date-tile.dart';
import 'package:mirrormind/util/helper/date-helper.dart';

class Dates extends StatefulWidget {
  const Dates({Key? key}) : super(key: key);

  @override
  State<Dates> createState() => _DatesState();
}

class _DatesState extends State<Dates> {
  List<Date> _dates = [];

  @override
  void didChangeDependencies() {
    _getDates();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108.h,
      child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _dates.length,
          clipBehavior: Clip.none,
          separatorBuilder: (BuildContext context, int index) => SizedBox(
                width: 10.w,
              ),
          itemBuilder: (context, index) {
            return GestureDetector(
                onTap: () {
                  setState(() {
                    for (var element in _dates) {
                      element.isSelected = false;
                    }
                    _dates[index].isSelected = true;
                  });
                },
                child: DateTile(
                  date: _dates[index],
                ));
          }),
    );
  }

  Future<void> _getDates() async {
    _dates = await DateHelper.getDates();
    setState(() {});
  }
}
