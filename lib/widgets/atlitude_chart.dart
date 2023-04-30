import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AtlitudeChart extends StatelessWidget {
  final List<double> data;
  final double distance;
  AtlitudeChart({super.key, required this.data, required this.distance});

  final TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.lightBlue[25],
        child: SfCartesianChart(
          margin: const EdgeInsets.all(10),
          tooltipBehavior: _tooltipBehavior,
          series: <ChartSeries>[
            AreaSeries(
                name: 'высота',
                enableTooltip: true,
                dataSource: data,
                xValueMapper: (element, index) =>
                    distance / data.length * index,
                yValueMapper: (element, index) => element)
          ],
        ));
  }
}
