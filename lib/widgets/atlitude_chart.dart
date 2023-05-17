import 'package:diplom/logic/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;

class AtlitudeChart extends StatelessWidget {
  final List<double> data;
  final double distance;
  AtlitudeChart({super.key, required this.data, required this.distance});

  final charts.TooltipBehavior _tooltipBehavior =
      charts.TooltipBehavior(enable: true);

  @override
  Widget build(BuildContext context) {
    List<dynamic> list = [];
    if (data.length > 30) {
      for (var i = 0; i < data.length; i++) {
        if (i % (5 * (data.length / 30).floor()) == 0) {
          list.add([data[i], (distance / data.length * i).round()]);
        }
      }
      if (list.last != data.last) {
        list.add([
          data.last,
          (distance / (data.length - 1) * (data.length)).round()
        ]);
      }
    } else {
      for (var i = 0; i < data.length; i++) {
        list.add([data[i], (distance / data.length * i).round()]);
      }
    }
    return Consumer<ThemeProvider>(builder: (context, value, child) {
      return charts.SfCartesianChart(
        margin: const EdgeInsets.all(10),
        tooltipBehavior: _tooltipBehavior,
        series: <charts.ChartSeries>[
          charts.AreaSeries(
              borderDrawMode: charts.BorderDrawMode.all,
              borderWidth: 5,
              color: value.curTheme
                  ? value.theme.primaryColor
                  : const Color.fromARGB(255, 255, 191, 43),
              name: 'высота',
              enableTooltip: true,
              dataSource: list,
              markerSettings: const charts.MarkerSettings(
                  isVisible: true, height: 5, width: 5),
              xValueMapper: (element, index) => element[1],
              yValueMapper: (element, index) => element[0])
        ],
      );
    });
  }
}
