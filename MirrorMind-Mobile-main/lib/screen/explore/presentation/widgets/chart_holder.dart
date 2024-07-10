import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mirrormind/screen/explore/presentation/resources/app_resources.dart';
import 'package:mirrormind/screen/explore/presentation/samples/chart_sample.dart';
import 'package:flutter/material.dart';

class ChartHolder extends StatelessWidget {
  final ChartSample chartSample;

  const ChartHolder({
    Key? key,
    required this.chartSample,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const SizedBox(width: 6),
            Text(
              chartSample.name,
              style: TextStyle(
                  color: AppColors.contentColorCyan,
                  fontWeight: FontWeight.w500,
                  fontSize: 20.sp),
            ),
            Expanded(child: Container()),
            IconButton(
              onPressed: () async {},
              icon: const Icon(
                Icons.code,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Container(
          decoration: const BoxDecoration(
            color: AppColors.itemsBackground,
            borderRadius:
                BorderRadius.all(Radius.circular(AppDimens.defaultRadius)),
          ),
          child: chartSample.builder(context),
        ),
      ],
    );
  }
}
