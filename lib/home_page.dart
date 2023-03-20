import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workout_logger_app/error_messages.dart';
import 'package:workout_logger_app/top_bar.dart';

import 'workout_widgets/exercise_list.dart';
import 'workout_widgets/add_exercise.dart';
import 'workout_widgets/workout_notes.dart';
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
  late final User _user;

  final RestorableDateTime _selectedDate = RestorableDateTime(DateTime.now());

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      setState(() {
        _user = FirebaseAuth.instance.currentUser!;
      });
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(getAuthErrorMessage(e))));
    }
  }

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
      appBar: const TopBar(),
      body: Column(
        children: [
          DateScroll(
              date: _selectedDate.value,
              dateAdded: _dateAdded,
              dateSubtracted: _dateSubtracted),
          ExerciseList(userId: _user.uid, selectedDate: _selectedDate.value),
          WorkoutNotes(userId: _user.uid, selectedDate: _selectedDate.value),
          AddExercise(
            userId: _user.uid,
            selectedDate: _selectedDate.value,
          ),
        ],
      ),
      bottomNavigationBar:
          NavBar(date: _selectedDate.value, dateChanged: _dateChanged),
    );
  }
}
