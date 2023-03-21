import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workout_logger_app/styles.dart';

class DateScroll extends StatefulWidget {
  final Function() dateAdded;
  final Function() dateSubtracted;
  const DateScroll(
      {Key? key,
      this.date,
      required this.dateAdded,
      required this.dateSubtracted})
      : super(key: key);

  final DateTime? date;

  @override
  State<DateScroll> createState() => _DateScrollState();
}

class _DateScrollState extends State<DateScroll> {
  int _calculateDifference(DateTime date) {
    DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      width: double.infinity,
      margin: EdgeInsets.symmetric(
          vertical: 20.0, horizontal: MediaQuery.of(context).size.width * 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            style: ButtonStyles.shadowPadding,
            onPressed: () {
              widget.dateSubtracted();
            },
            child: const Icon(Icons.arrow_back),
          ),
          // Terinary operator to display "Today", "Yesterday", "Tomorrow" or the date
          widget.date == null || _calculateDifference(widget.date!) == 0
              ? const Text("Today")
              : _calculateDifference(widget.date!) == -1
                  ? const Text("Yesterday")
                  : _calculateDifference(widget.date!) == 1
                      ? const Text("Tomorrow")
                      : Text(DateFormat('d.M.yyyy').format(widget.date!)),
          ElevatedButton(
            style: ButtonStyles.shadowPadding,
            onPressed: () {
              setState(() {
                widget.dateAdded();
              });
            },
            child: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}
