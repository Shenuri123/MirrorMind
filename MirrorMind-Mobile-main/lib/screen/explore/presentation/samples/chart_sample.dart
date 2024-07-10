import 'package:mirrormind/screen/explore/util/app_helper.dart';
import 'package:flutter/cupertino.dart';

abstract class ChartSample {
  final String number;
  final WidgetBuilder builder;
  ChartType get type;
  String get name => '$number';
  //String get url => Urls.getChartSourceCodeUrl(type, number);
  ChartSample(this.number, this.builder);
}

class BarChartSample extends ChartSample {
  BarChartSample(super.number, super.builder);
  @override
  ChartType get type => ChartType.bar;
}
