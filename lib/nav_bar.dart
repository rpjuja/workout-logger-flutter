import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  final Function(DateTime) dateChanged;
  final Function(bool) pageChanged;

  const NavBar({Key? key, this.date, required this.dateChanged, required this.pageChanged})
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
    registerForRestoration(
        _restorableDatePickerRouteFuture, 'date_picker_route_future_for_calendar');
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
          icon: Icon(Icons.bar_chart),
          label: 'Progression',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Calendar',
        ),
      ],
      currentIndex: _navBarIndex,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontSize: 16),
      unselectedLabelStyle: const TextStyle(fontSize: 14),
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.deepPurple[300],
      onTap: (int index) {
        setState(() {
          _navBarIndex = index;
        });
        if (index == 0) {
          setState(() {
            widget.pageChanged(true);
          });
        } else if (index == 1) {
          setState(() {
            widget.pageChanged(false);
          });
        } else if (index == 2) {
          Navigator.pushNamed(context, '/profile');
        } else if (index == 3) {
          _restorableDatePickerRouteFuture.present();
        }
      },
    );
  }
}
