import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mirrormind/model/model.dart';
import 'package:mirrormind/screen/home/widget/quote-tile.dart';
import 'package:mirrormind/util/helper/quotes-helper.dart';

class Quotes extends StatefulWidget {
  const Quotes({Key? key}) : super(key: key);

  @override
  State<Quotes> createState() => _QuotesState();
}

class _QuotesState extends State<Quotes> {
  List<Quote> _quotes = [];

  @override
  void didChangeDependencies() {
    _getQuotes();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130.h,
      child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _quotes.length,
          clipBehavior: Clip.none,
          separatorBuilder: (BuildContext context, int index) => SizedBox(
                width: 25.w,
              ),
          itemBuilder: (context, index) {
            return GestureDetector(
                // onTap: () {
                //   setState(() {
                //     for (var element in _quotes) {
                //       element.isSelected = false;
                //     }
                //     _quotes[index].isSelected = true;
                //   });
                // },
                child: QuotesTile(
              quote: _quotes[index],
            ));
          }),
    );
  }

  Future<void> _getQuotes() async {
    _quotes = await QuotesHelper.getQuotes();
    setState(() {});
  }
}
