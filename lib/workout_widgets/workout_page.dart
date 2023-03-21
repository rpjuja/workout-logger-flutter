import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'date_scroll.dart';
import '../error_messages.dart';
import 'add_exercise.dart';
import 'exercise_list.dart';
import 'workout_notes.dart';

class WorkoutPage extends StatefulWidget {
  final Function() dateAdded;
  final Function() dateSubtracted;

  const WorkoutPage({
    Key? key,
    required this.selectedDate,
    required this.dateAdded,
    required this.dateSubtracted,
  }) : super(key: key);

  final DateTime selectedDate;

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  late final User _user;

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DateScroll(
            date: widget.selectedDate,
            dateAdded: widget.dateAdded,
            dateSubtracted: widget.dateSubtracted),
        ExerciseList(selectedDate: widget.selectedDate, userId: _user.uid),
        WorkoutNotes(selectedDate: widget.selectedDate, userId: _user.uid),
        AddExercise(selectedDate: widget.selectedDate, userId: _user.uid),
      ],
    );
  }
}
