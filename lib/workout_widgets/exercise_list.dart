import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workout_logger_app/workout_widgets/workout_notes.dart';

import 'exercise_entry.dart';
import 'add_exercise.dart';
import 'modify_exercise.dart';

class ExerciseList extends StatefulWidget {
  const ExerciseList(
      {Key? key, required this.userId, required this.selectedDate})
      : super(key: key);

  final String userId;
  final DateTime selectedDate;

  @override
  State<ExerciseList> createState() => _ExerciseListState();
}

class _ExerciseListState extends State<ExerciseList> {
  final DatabaseReference _workoutRef =
      FirebaseDatabase.instance.ref("/exercises/");
  late StreamSubscription<DatabaseEvent> _workoutSubscription;

  FirebaseException? _error;

  final List<ExerciseEntry> _exerciseList = <ExerciseEntry>[];

  @override
  void initState() {
    super.initState();
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

  void _getExercisesAndListen() async {
    final queryDate = DateFormat("dd,MM,yyyy").format(widget.selectedDate);
    _workoutSubscription =
        _workoutRef.child("${widget.userId}/$queryDate").onValue.listen(
      (event) {
        if (event.snapshot.exists) {
          print('Connected to the database and read ${event.snapshot.value}');
          Map<String, dynamic> exercises =
              Map<String, dynamic>.from(event.snapshot.value as Map);
          _printExercises(exercises);
          setState(() {
            _error = null;
          });
        } else {
          print('Connected to the database but no data found');
          setState(() {
            _exerciseList.clear();
          });
        }
      },
      onError: (Object o) {
        final error = o as FirebaseException;
        setState(() {
          _exerciseList.clear();
          _error = error;
        });
      },
    );
  }

  void _deleteExercise(String exerciseId, String exerciseName) async {
    final queryDate = DateFormat("dd,MM,yyyy").format(widget.selectedDate);
    try {
      await _workoutRef
          .child("${widget.userId}/$queryDate/$exerciseId")
          .remove();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$exerciseName removed')));
      print('Deleted data from the database');
    } on FirebaseException catch (err) {
      setState(() {
        print('Connected to the database but no data found');
        _error = err;
      });
    }
  }

  void _printExercises(Map<String, dynamic> exercises) {
    _exerciseList.clear();
    setState(() {
      exercises.forEach((key, value) {
        print(key);
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
    return Expanded(
        child: Column(
      children: [
        Flexible(
            fit: FlexFit.loose,
            child: _error == null
                ? ListView.builder(
                    itemCount: _exerciseList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Dismissible(
                          key: Key(_exerciseList[index].id),
                          child: _exerciseList[index].build(context),
                          direction: DismissDirection.horizontal,
                          dismissThresholds: const <DismissDirection, double>{
                            DismissDirection.endToStart: 0.5,
                          },
                          background: Container(
                            child: const Icon(Icons.edit),
                            decoration: const BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 10.0),
                            margin: EdgeInsets.fromLTRB(
                                MediaQuery.of(context).size.width * 0.1,
                                0,
                                MediaQuery.of(context).size.width * 0.1,
                                10),
                          ),
                          secondaryBackground: Container(
                            child: const Icon(Icons.delete),
                            decoration: const BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 10.0),
                            margin: EdgeInsets.fromLTRB(
                                MediaQuery.of(context).size.width * 0.1,
                                0,
                                MediaQuery.of(context).size.width * 0.1,
                                10),
                          ),
                          // Ask user for confirmation before deleting
                          confirmDismiss: (direction) async {
                            return await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return direction ==
                                          DismissDirection.endToStart
                                      ? AlertDialog(
                                          title: const Text("Confirm"),
                                          content: Text(
                                              'Are you sure you wish to delete ${_exerciseList[index].name}?'),
                                          actions: <Widget>[
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.deepPurple),
                                                onPressed: () => {
                                                      _deleteExercise(
                                                          _exerciseList[index]
                                                              .id,
                                                          _exerciseList[index]
                                                              .name),
                                                      Navigator.of(context)
                                                          .pop(true),
                                                    },
                                                child: const Text("DELETE")),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text("CANCEL"),
                                            ),
                                          ],
                                        )
                                      : ModifyExercise(
                                          userId: widget.userId,
                                          selectedDate: widget.selectedDate,
                                          exercise: _exerciseList[index]);
                                });
                          });
                    })
                : Container(
                    alignment: Alignment.topCenter,
                    margin: const EdgeInsets.only(top: 30),
                    child: Text(
                        'Error retrieving exercises:\n${_error!.message}'))),
        WorkoutNotes(userId: widget.userId, selectedDate: widget.selectedDate),
        AddExercise(userId: widget.userId, selectedDate: widget.selectedDate)
      ],
    ));
  }
}
