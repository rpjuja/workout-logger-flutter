import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'chart_points.dart';

class ProgressionChart extends StatefulWidget {
  const ProgressionChart({
    Key? key,
  }) : super(key: key);

  @override
  State createState() => _ProgressionChartState();
}

class _ProgressionChartState extends State<ProgressionChart> {
  late final List<ChartPoints> _points = chartPoints;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width * 0.9,
        child: AspectRatio(
          aspectRatio: 1.5,
          child: BarChart(
            BarChartData(
              gridData: FlGridData(
                show: false,
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.deepPurple[300]!, width: 1),
              ),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.deepPurple[300],
                  tooltipPadding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      rod.toY.round().toString(),
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    );
                  },
                ),
                // handleBuiltInTouches:
              ),
              titlesData: FlTitlesData(
                rightTitles: AxisTitles(
                    axisNameSize: 30,
                    axisNameWidget: const Text("Sets"),
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(
                    axisNameSize: 30,
                    axisNameWidget: const Text("Week"),
                    sideTitles: SideTitles(showTitles: false)),
              ),
              minY: 0,
              maxY: 30,
              barGroups: _points
                  .map((point) => BarChartGroupData(
                        x: point.x,
                        barRods: [
                          BarChartRodData(
                              toY: point.y,
                              color: Colors.deepPurple,
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(2),
                                bottom: Radius.circular(0),
                              )),
                        ],
                      ))
                  .toList(),
            ),
            swapAnimationDuration: const Duration(milliseconds: 250),
          ),
        ),
      ),
    );
  }
}
