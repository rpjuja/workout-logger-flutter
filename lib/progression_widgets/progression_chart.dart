import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:workout_logger_app/error_messages.dart';
import 'package:workout_logger_app/muscle_group.dart';

import 'chart_points.dart';

class ProgressionChart extends StatefulWidget {
  const ProgressionChart({
    Key? key,
    required this.selectedDate,
    required this.selectedGroup,
  }) : super(key: key);

  final DateTime selectedDate;
  final MuscleGroup selectedGroup;

  @override
  State createState() => _ProgressionChartState();
}

class _ProgressionChartState extends State<ProgressionChart> {
  late final List<ChartPoints> _totalSets = [];
  late String _userId;

  late final DatabaseReference _workoutRef;
  late var _dataFetched = false;

  @override
  void initState() {
    super.initState();
    _workoutRef = FirebaseDatabase.instance.ref("exercises");
    _getUserData().then((value) => _getChartData());
  }

  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate ||
        widget.selectedGroup != oldWidget.selectedGroup) {
      setState(() {
        _dataFetched = false;
      });
      _getChartData();
    }
  }

  Future<void> _getUserData() async {
    try {
      setState(() {
        _userId = FirebaseAuth.instance.currentUser!.uid;
      });
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(getAuthErrorMessage(e))));
    }
  }

  Future<void> _getChartData() async {
    final date = widget.selectedDate.toString().split(" ")[0];
    final String queryYear = date.split("-")[0], queryMonth = date.split("-")[1];

    final firstOfJanuary = DateTime(DateTime.now().year, 1, 1);
    late DateTime exerciseDate;
    late int weekOfYear;
    late double exerciseSets;
    late String primaryMuscle;
    late String secondaryMuscle;

    _totalSets.clear();

    try {
      _workoutRef.child("$_userId/$queryYear/$queryMonth/").get().then((days) => {
            if (days.value != null)
              {
                for (final day in days.children)
                  {
                    for (final exercise in day.children)
                      {
                        primaryMuscle = exercise.child("primaryMuscleGroup").value.toString(),
                        secondaryMuscle = exercise.child("secondaryMuscleGroup").value.toString(),
                        if (primaryMuscle == widget.selectedGroup.name ||
                            secondaryMuscle == widget.selectedGroup.name)
                          {
                            exerciseSets = exercise.child("sets").children.length.toDouble(),
                            exerciseDate = DateTime(
                                int.parse(queryYear), int.parse(queryMonth), int.parse(day.key!)),
                            weekOfYear = weeksBetween(firstOfJanuary, exerciseDate),
                            if (_totalSets.where((element) => element.x == weekOfYear).isEmpty)
                              {
                                if (primaryMuscle == widget.selectedGroup.name)
                                  {
                                    setState(() {
                                      _totalSets.add(ChartPoints(
                                          x: weekOfYear,
                                          primarySets: exerciseSets,
                                          secondarySets: 0));
                                    }),
                                  }
                                else
                                  {
                                    setState(() {
                                      _totalSets.add(ChartPoints(
                                          x: weekOfYear,
                                          primarySets: 0,
                                          secondarySets: exerciseSets));
                                    }),
                                  },
                              }
                            else
                              {
                                setState(() {
                                  _totalSets
                                      .where((element) => element.x == weekOfYear)
                                      .forEach((element) {
                                    primaryMuscle == widget.selectedGroup.name
                                        ? element.primarySets += exerciseSets
                                        : element.secondarySets += exerciseSets;
                                  });
                                })
                              }
                          }
                      }
                  },
              },
            setState(() {
              _dataFetched = true;
            })
          });
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error retrieving chart data: ${getErrorMessage(e)}")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred. Please try again later.")));
    }
  }

  int weeksBetween(DateTime from, DateTime to) {
    from = DateTime.utc(from.year, from.month, from.day);
    to = DateTime.utc(to.year, to.month, to.day);
    return (to.difference(from).inDays / 7).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: _dataFetched
          ? Container(
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
                    // Determine max y value based on total sets for the week rounded to the next multiple of 5
                    maxY: _totalSets.isNotEmpty
                        ? (_totalSets.map((e) => e.primarySets + e.secondarySets).reduce(
                                        (value, element) => value > element ? value : element) /
                                    5)
                                .ceilToDouble() *
                            5
                        : 20,
                    barGroups: _totalSets
                        .map((point) => BarChartGroupData(
                              x: point.x,
                              barRods: [
                                BarChartRodData(
                                  // Determine y value based on total sets for the week
                                  toY: point.primarySets + point.secondarySets,
                                  // Draw rodStackItem if _secondaryMuscleGroup contains sets for the same week
                                  rodStackItems: [
                                    BarChartRodStackItem(
                                      point.primarySets,
                                      point.primarySets + point.secondarySets,
                                      Colors.deepPurple[300]!,
                                    ),
                                  ],
                                  color: Colors.deepPurple,
                                  width: 20,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(2),
                                    bottom: Radius.circular(0),
                                  ),
                                ),
                              ],
                            ))
                        .toList(),
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 250),
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
