// import 'package:mirrormind/screen/explore/presentation/resources/app_resources.dart';
import 'package:mirrormind/screen/explore/util/app_helper.dart';
import 'package:flutter/material.dart';

import 'chart_samples_page.dart';

class HomePage extends StatelessWidget {
  HomePage({
    Key? key,
    required this.showingChartType,
  }) : super(key: key) {
    _initMenuItems();
  }

  void _initMenuItems() {
    // _menuItems = ChartType.values.mapIndexed(
    //   (int index, ChartType type) {
    //     _menuItemsIndices[type] = index;
    //     // return ChartMenuItem(
    //     //   type,
    //     //   type.getSimpleName(),
    //     //   type.assetIcon,
    //     // );
    //   },
    // ).toList();
  }

  final ChartType showingChartType;
  //late final List<ChartMenuItem> _menuItems;

@override
Widget build(BuildContext context) {
  // ...

  final samplesSectionWidget = ChartSamplesPage(chartType: showingChartType);
  final body = Column( // Change to Column to stack the buttons and samples
    children: [      
      SizedBox(height: 16), // Add spacing between buttons and samples
      Expanded(child: samplesSectionWidget),
    ],
  );

  return Scaffold(
    body: body,
  );
}

}
