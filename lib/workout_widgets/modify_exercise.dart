import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workout_logger_app/workout_widgets/exercise_form.dart';

import '../error_messages.dart';
import '../muscle_group.dart';
import 'exercise_entry.dart';

class ModifyExercise extends StatefulWidget {
  const ModifyExercise(
      {Key? key,
      required this.userId,
      required this.selectedDate,
      required this.exercise})
      : super(key: key);

  final String userId;
  final DateTime selectedDate;
  final ExerciseEntry exercise;

  @override
  State<ModifyExercise> createState() => _ModifyExerciseState();
}

class _ModifyExerciseState extends State<ModifyExercise> {
  final DatabaseReference _workoutRef =
      FirebaseDatabase.instance.ref("exercises");

  Future<void> _modifyExercise(String name, String sets, String reps,
      String weight, MuscleGroup primary, MuscleGroup secondary) async {
    final queryDate = DateFormat("dd,MM,yyyy").format(widget.selectedDate);

    try {
      await _workoutRef
          .child("${widget.userId}/$queryDate/${widget.exercise.id}")
          .set({
            'name': name,
            'sets': sets,
            'reps': reps,
            'weight': weight,
            'primaryMuscleGroup': primary.name.toString(),
            'secondaryMuscleGroup': secondary.name.toString(),
          })
          .then((value) => Navigator.of(context).pop())
          .then((value) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('$name modified'))));
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error editing exercise: ${getErrorMessage(e)}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExerciseForm(
        parentName: "modify",
        onConfirm: _modifyExercise,
        exercise: widget.exercise);
  }
}
