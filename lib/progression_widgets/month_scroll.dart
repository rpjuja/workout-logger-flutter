import 'package:flutter/material.dart';

import '../styles.dart';

class DateScroll extends StatefulWidget {
  final Function() nextMonth;
  final Function() previousMonth;
  const DateScroll(
      {Key? key,
      required this.date,
      required this.nextMonth,
      required this.previousMonth})
      : super(key: key);

  final DateTime date;

  @override
  State<DateScroll> createState() => _DateScrollState();
}

class _DateScrollState extends State<DateScroll> {
  @override
  void initState() {
    super.initState();
  }

  String _printMonth(int month) {
    switch (month) {
      case 1:
        return "January";
      case 2:
        return "February";
      case 3:
        return "March";
      case 4:
        return "April";
      case 5:
        return "May";
      case 6:
        return "June";
      case 7:
        return "July";
      case 8:
        return "August";
      case 9:
        return "September";
      case 10:
        return "October";
      case 11:
        return "November";
      case 12:
        return "December";
      default:
        return "Error";
    }
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
              widget.previousMonth();
            },
            child: const Icon(Icons.arrow_back),
          ),
          Text("${_printMonth(widget.date.month)} ${widget.date.year}"),
          ElevatedButton(
            style: ButtonStyles.shadowPadding,
            onPressed: () {
              setState(() {
                widget.nextMonth();
              });
            },
            child: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}
