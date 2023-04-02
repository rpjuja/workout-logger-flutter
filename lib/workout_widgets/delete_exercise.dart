import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../error_messages.dart';

class DeleteExercise extends StatefulWidget {
  const DeleteExercise(
      {Key? key,
      required this.userId,
      required this.selectedDate,
      required this.exerciseId,
      required this.exerciseName})
      : super(key: key);

  final String userId;
  final DateTime selectedDate;
  final String exerciseId;
  final String exerciseName;

  @override
  State<DeleteExercise> createState() => _DeleteExerciseState();
}

class _DeleteExerciseState extends State<DeleteExercise> {
  final DatabaseReference _workoutRef =
      FirebaseDatabase.instance.ref("/exercises/");

  Future<void> _deleteExercise() async {
    final date = widget.selectedDate.toString().split(" ")[0];
    final String queryYear = date.split("-")[0],
        queryMonth = date.split("-")[1],
        queryDay = date.split("-")[2];
    try {
      await _workoutRef
          .child("${widget.userId}/$queryYear/$queryMonth/$queryDay/${widget.exerciseId}")
          .remove()
          .then((value) => Navigator.of(context).pop(true))
          .then((value) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${widget.exerciseName} removed'))));
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error deleting exercise:/n${getErrorMessage(e)}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirm"),
      content: Text('Are you sure you wish to delete ${widget.exerciseName}?'),
      actions: <Widget>[
        ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            onPressed: () => _deleteExercise(),
            child: const Text("Delete")),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
