import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class AtlitudeChart extends StatelessWidget {
  final List<double> data;
  const AtlitudeChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.lightBlue[25],
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.only(top: 5),
        child: SfSparkAreaChart(
          data: data,
          axisLineWidth: 0,
          trackball: const SparkChartTrackball(
              borderWidth: 2,
              borderColor: Colors.black,
              activationMode: SparkChartActivationMode.longPress),
        ));
  }
}
