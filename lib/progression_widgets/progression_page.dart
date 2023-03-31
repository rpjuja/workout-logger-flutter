import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MonthScroll(
            date: _date, nextMonth: _nextMonth, previousMonth: _previousMonth),
        const ProgressionChart()
      ],
    );
  }
}
