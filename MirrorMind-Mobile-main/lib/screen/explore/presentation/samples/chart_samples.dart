import 'package:mirrormind/screen/explore/util/app_helper.dart';
import 'bar/bar_chart_sample2.dart';
import 'bar/chart_fb.dart';
import 'bar/chart_ig.dart';
import 'bar/chart_tw.dart';
import 'chart_sample.dart';

class ChartSamples {
  static final Map<ChartType, List<ChartSample>> samples = {
    ChartType.bar: [
      BarChartSample("Overall", (context) => BarChartSample2()),
      BarChartSample("Facebook", (context) => const Facebook()),
      BarChartSample("Instagram", (context) => const Instagram()),
      BarChartSample("Twitter", (context) => const Twitter()),
    ],
  };
}
