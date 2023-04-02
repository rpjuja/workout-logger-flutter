import 'package:flutter/material.dart';
import 'package:workout_logger_app/muscle_group.dart';
import 'package:workout_logger_app/progression_widgets/dropdown_selection.dart';

import 'chart_info.dart';
import 'month_scroll.dart';
import 'progression_chart.dart';

class ProgressionPage extends StatefulWidget {
  const ProgressionPage({
    Key? key,
    required this.selectedDate,
  }) : super(key: key);

  final DateTime selectedDate;

  @override
  State<ProgressionPage> createState() => _ProgressionPageState();
}

class _ProgressionPageState extends State<ProgressionPage> {
  late DateTime _date;
  late MuscleGroup _selectedGroup = MuscleGroup.abs;

  @override
  void initState() {
    super.initState();
    _date = widget.selectedDate;
  }

  void _nextMonth() {
    setState(() {
      _date = DateTime(_date.year, _date.month + 1);
    });
  }

  void _previousMonth() {
    setState(() {
      _date = DateTime(_date.year, _date.month - 1);
    });
  }

  void _muscleGroupChanged(MuscleGroup muscleGroup) {
    setState(() {
      _selectedGroup = muscleGroup;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MonthScroll(selectedDate: _date, nextMonth: _nextMonth, previousMonth: _previousMonth),
        DropdownSelection(selectedGroup: _selectedGroup, muscleGroupChanged: _muscleGroupChanged),
        ProgressionChart(selectedDate: _date, selectedGroup: _selectedGroup),
        const ChartInfo(),
      ],
    );
  }
}
