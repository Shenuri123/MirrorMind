import 'package:mirrormind/screen/explore/util/app_helper.dart';

class AppAssets {
  static String getChartIcon(ChartType type) {
    switch (type) {
      case ChartType.bar:
        return 'assets/icons/ic_bar_chart.svg';
    }
  }

  static const flChartLogoIcon = 'assets/icons/fl_chart_logo_icon.png';
  static const flChartLogoText = 'assets/icons/fl_chart_logo_text.svg';
}
