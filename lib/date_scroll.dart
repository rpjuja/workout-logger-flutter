import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      width: double.infinity,
      margin: EdgeInsets.symmetric(
          vertical: 10.0, horizontal: MediaQuery.of(context).size.width * 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              widget.dateSubtracted();
            },
            child: const Icon(Icons.arrow_back),
          ),
          // Terinary operator to display "Today", "Yesterday", "Tomorrow" or the date
          widget.date == null || widget.date?.day == DateTime.now().day
              ? const Text("Today")
              : widget.date?.day == DateTime.now().day - 1
                  ? const Text("Yesterday")
                  : widget.date?.day == DateTime.now().day + 1
                      ? const Text("Tomorrow")
                      : Text(DateFormat('d.M.yyyy').format(widget.date!)),
          ElevatedButton(
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
