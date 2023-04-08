import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:workout_logger_app/muscle_group.dart';
import 'package:workout_logger_app/workout_widgets/exercise_form.dart';

import '../error_messages.dart';
import '../styles.dart';

class AddExercise extends StatefulWidget {
  const AddExercise(
      {Key? key, this.testDatabaseReference, required this.userId, required this.selectedDate})
      : super(key: key);

  final DatabaseReference? testDatabaseReference;
  final String userId;
  final DateTime selectedDate;

  @override
  State<AddExercise> createState() => _AddExerciseState();
}

class _AddExerciseState extends State<AddExercise> {
  late final DatabaseReference _workoutRef;

  @override
  void initState() {
    super.initState();
    // When testing, the widget will receive a testDatabaseReference, otherwise use the real database
    _workoutRef = widget.testDatabaseReference ?? FirebaseDatabase.instance.ref("exercises");
  }

  Future<void> _addExercise(
      String name, Map<dynamic, dynamic> sets, MuscleGroup primary, MuscleGroup secondary) async {
    final date = widget.selectedDate.toString().split(" ")[0];
    final String queryYear = date.split("-")[0],
        queryMonth = date.split("-")[1],
        queryDay = date.split("-")[2];

    var exerciseId =
        _workoutRef.child('${widget.userId}/$queryYear/$queryMonth/$queryDay').push().key;
    try {
      await _workoutRef
          .child("${widget.userId}/$queryYear/$queryMonth/$queryDay/$exerciseId")
          .set({
            'name': name,
            'sets': sets,
            'primaryMuscleGroup': primary.name.toString(),
            'secondaryMuscleGroup': secondary.name.toString(),
          })
          .then((value) => Navigator.of(context).pop(true))
          .then((value) =>
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name added'))));
    } on FirebaseException catch (err) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error adding exercise: ${getErrorMessage(err)}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ButtonBar(
        alignment: MainAxisAlignment.center,
        buttonPadding: const EdgeInsets.all(20.0),
        children: [
          ElevatedButton(
            key: const Key('addExerciseButton'),
            style: ButtonStyles.shadowPadding,
            onPressed: () {
              showDialog(
                  context: context,
                  builder: ((context) {
                    return ExerciseForm(parentName: "add", onConfirm: _addExercise);
                  }));
            },
            child: const Text('Add exercise'),
          ),
        ]);
  }
}
