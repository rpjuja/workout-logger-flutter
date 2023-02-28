import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  final Function(DateTime) dateChanged;

  const NavBar({Key? key, this.date, required this.dateChanged})
      : super(key: key);

  final DateTime? date;

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with RestorationMixin {
  int _navBarIndex = 0;
  @override
  String? get restorationId => "calendar";
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
      RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: widget.date?.millisecondsSinceEpoch,
      );
    },
  );

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        widget.dateChanged(newSelectedDate);
      });
    }
  }

  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog_for_calendar',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime(2022),
          lastDate: DateTime(2030),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_restorableDatePickerRouteFuture,
        'date_picker_route_future_for_calendar');
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_graph),
          label: 'Progression',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Calendar',
        ),
      ],
      currentIndex: _navBarIndex,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.deepPurple[300],
      onTap: (int index) {
        setState(() {
          _navBarIndex = index;
        });
        if (index == 0) {
          // Navigator.pushNamed(context, '/');
        } else if (index == 1) {
          // Navigator.pushNamed(context, '/progression');
        } else if (index == 2) {
          _restorableDatePickerRouteFuture.present();
        }
      },
    );
  }
}
