import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workout_logger_app/workout_widgets/copy_workout.dart';

import '../error_messages.dart';
import 'exercise_entry.dart';

import 'modify_exercise.dart';
import 'delete_exercise.dart';

class ExerciseList extends StatefulWidget {
  const ExerciseList(
      {Key? key,
      this.testDatabaseReference,
      required this.userId,
      required this.selectedDate})
      : super(key: key);

  final DatabaseReference? testDatabaseReference;
  final String userId;
  final DateTime selectedDate;

  @override
  State<ExerciseList> createState() => _ExerciseListState();
}

class _ExerciseListState extends State<ExerciseList> {
  late final DatabaseReference _workoutRef;
  late StreamSubscription<DatabaseEvent> _workoutSubscription;

  final List<ExerciseEntry> _exerciseList = <ExerciseEntry>[];

  @override
  void initState() {
    super.initState();
    // When testing, the widget will receive a testDatabaseReference, otherwise use the real database
    _workoutRef = widget.testDatabaseReference ??
        FirebaseDatabase.instance.ref("exercises");
    _getExercisesAndListen();
  }

  // Call getExercisesAndListen again if user changes the date
  // to change the subscription date
  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _workoutSubscription.cancel();
      _getExercisesAndListen();
    }
  }

  @override
  void dispose() {
    _workoutSubscription.cancel();
    super.dispose();
  }

  Future<void> _getExercisesAndListen() async {
    final queryDate = DateFormat("dd,MM,yyyy").format(widget.selectedDate);
    _workoutSubscription =
        _workoutRef.child("${widget.userId}/$queryDate").onValue.listen(
      (event) {
        if (event.snapshot.exists) {
          Map<String, dynamic> exercises =
              Map<String, dynamic>.from(event.snapshot.value as Map);
          _printExercises(exercises);
        } else {
          setState(() {
            _exerciseList.clear();
          });
        }
      },
      onError: (Object o) {
        final e = o as FirebaseException;
        setState(() {
          _exerciseList.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Error retrieving exercises: ${getErrorMessage(e)}}')));
      },
    );
  }

  void _printExercises(Map<String, dynamic> exercises) {
    _exerciseList.clear();
    setState(() {
      exercises.forEach((key, value) {
        _exerciseList.add(ExerciseEntry(
          id: key,
          name: value['name'],
          sets: value['sets'],
          reps: value['reps'],
          weight: value['weight'],
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      child: _exerciseList.isNotEmpty
          ? ListView.builder(
              itemCount: _exerciseList.length,
              itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                    key: Key(_exerciseList[index].id),
                    direction: DismissDirection.horizontal,
                    dismissThresholds: const <DismissDirection, double>{
                      DismissDirection.endToStart: 0.5,
                    },
                    background: Container(
                      decoration: const BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 10.0),
                      margin: EdgeInsets.fromLTRB(
                          MediaQuery.of(context).size.width * 0.1,
                          0,
                          MediaQuery.of(context).size.width * 0.1,
                          10),
                      child: const Icon(Icons.edit),
                    ),
                    secondaryBackground: Container(
                      decoration: const BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 10.0),
                      margin: EdgeInsets.fromLTRB(
                          MediaQuery.of(context).size.width * 0.1,
                          0,
                          MediaQuery.of(context).size.width * 0.1,
                          10),
                      child: const Icon(Icons.delete),
                    ),
                    // Ask user for confirmation before deleting
                    confirmDismiss: (direction) async {
                      return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return direction == DismissDirection.endToStart
                                ? DeleteExercise(
                                    userId: widget.userId,
                                    selectedDate: widget.selectedDate,
                                    exerciseId: _exerciseList[index].id,
                                    exerciseName: _exerciseList[index].name,
                                  )
                                : ModifyExercise(
                                    userId: widget.userId,
                                    selectedDate: widget.selectedDate,
                                    exercise: _exerciseList[index]);
                          });
                    },
                    child: _exerciseList[index].build(context));
              })
          : CopyWorkout(
              databaseReference: _workoutRef,
              userId: widget.userId,
              selectedDate: widget.selectedDate),
    );
  }
}
