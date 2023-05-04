import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AtlitudeChart extends StatelessWidget {
  final List<double> data;
  final double distance;
  AtlitudeChart({super.key, required this.data, required this.distance});

  final TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true);

  @override
  Widget build(BuildContext context) {
    List<dynamic> list = [];
    if (data.length > 50) {
      for (var i = 0; i < data.length; i++) {
        if (i % (5 * (data.length / 50).floor()) == 0) {
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
    return Container(
        color: Colors.lightBlue[25],
        child: SfCartesianChart(
          margin: const EdgeInsets.all(10),
          tooltipBehavior: _tooltipBehavior,
          series: <ChartSeries>[
            AreaSeries(
                name: 'высота',
                enableTooltip: true,
                dataSource: list,
                markerSettings:
                    const MarkerSettings(isVisible: true, height: 5, width: 5),
                xValueMapper: (element, index) => element[1],
                yValueMapper: (element, index) => element[0])
          ],
        ));
  }
}
