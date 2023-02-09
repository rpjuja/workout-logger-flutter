import 'package:flutter/material.dart';

import 'exercise_list.dart';
import 'date_scroll.dart';
import 'nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RestorationMixin {
  @override
  String? get restorationId => "home_page";
  final RestorableDateTime _selectedDate = RestorableDateTime(DateTime.now());

  void _dateAdded() {
    setState(() {
      _selectedDate.value = _selectedDate.value.add(const Duration(days: 1));
    });
  }

  void _dateSubtracted() {
    setState(() {
      _selectedDate.value =
          _selectedDate.value.subtract(const Duration(days: 1));
    });
  }

  void _dateChanged(DateTime date) {
    setState(() {
      _selectedDate.value = date;
    });
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Workout Tracker"),
        ),
        body: Column(children: [
          DateScroll(
              date: _selectedDate.value,
              dateAdded: _dateAdded,
              dateSubtracted: _dateSubtracted),
          const ExerciseList(),
        ]),
        bottomNavigationBar:
            NavBar(date: _selectedDate.value, dateChanged: _dateChanged));
  }
}
