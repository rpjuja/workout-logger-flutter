import 'package:flutter/material.dart';
import 'package:workout_logger_app/top_bar.dart';
import 'package:workout_logger_app/workout_widgets/workout_page.dart';

import 'nav_bar.dart';
import 'progression_widgets/progression_page.dart';

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
  bool _showWorkoutPage = true;

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

  void _pageChanged(bool showWorkoutPage) {
    setState(() {
      _showWorkoutPage = showWorkoutPage;
    });
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(),
      body: _showWorkoutPage
          ? WorkoutPage(
              selectedDate: _selectedDate.value,
              dateAdded: _dateAdded,
              dateSubtracted: _dateSubtracted)
          : ProgressionPage(selectedDate: _selectedDate.value),
      bottomNavigationBar: NavBar(
        date: _selectedDate.value,
        dateChanged: _dateChanged,
        pageChanged: _pageChanged,
      ),
    );
  }
}
