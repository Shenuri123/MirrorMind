import 'package:mirrormind/screen/explore/presentation/resources/app_resources.dart';

enum ChartType { bar }

extension ChartTypeExtension on ChartType {
  String getDisplayName() => '${getSimpleName()} Chart';

  String getSimpleName() {
    switch (this) {
      case ChartType.bar:
        return 'Bar';
    }
  }

  String get assetIcon => AppAssets.getChartIcon(this);
}
