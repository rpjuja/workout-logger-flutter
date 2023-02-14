import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkoutNotes extends StatefulWidget {
  const WorkoutNotes(
      {Key? key, required this.userId, required this.selectedDate})
      : super(key: key);

  final int userId;
  final DateTime selectedDate;

  @override
  State<WorkoutNotes> createState() => _WorkoutNotesState();
}

class _WorkoutNotesState extends State<WorkoutNotes> {
  final TextEditingController _notesController = TextEditingController();

  final DatabaseReference _workoutRef =
      FirebaseDatabase.instance.ref("/workouts/");
  late StreamSubscription<DatabaseEvent> _workoutSubscription;
  FirebaseException? _error;

  @override
  void initState() {
    super.initState();

    getWorkoutData();
    listenForChanges();
  }

  // Update the notes if user changes the date
  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      getWorkoutData();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _workoutSubscription.cancel();
  }

  void listenForChanges() async {
    _workoutSubscription =
        _workoutRef.child("${widget.userId}/").onValue.listen(
      (event) {
        Map<String, dynamic> notes =
            Map<String, dynamic>.from(event.snapshot.value as Map);
        final queryDate = DateFormat("dd,MM,yyyy").format(widget.selectedDate);
        setState(() {
          _notesController.text = notes[queryDate]['notes'];
          _error = null;
        });
      },
      onError: (Object o) {
        final error = o as FirebaseException;
        setState(() {
          _error = error;
        });
      },
    );
  }

  void getWorkoutData() async {
    final queryDate = DateFormat("dd,MM,yyyy").format(widget.selectedDate);
    // Read data from database
    try {
      final snapshot =
          await _workoutRef.child("${widget.userId}/$queryDate").get();
      if (snapshot.exists) {
        print('Connected to the database and read ${snapshot.value}');
        Map<String, dynamic> notes =
            Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          _notesController.text = notes['notes'];
          _error = null;
        });
      } else {
        print('Connected to the database but no data found');
        setState(() {
          _notesController.text = '';
        });
      }
    } catch (err) {
      print(err);
    }
  }

  void setWorkoutData() async {
    final queryDate = DateFormat("dd,MM,yyyy").format(widget.selectedDate);
    try {
      await _workoutRef
          .child("${widget.userId}/$queryDate")
          .update({'notes': _notesController.text});
      print('Connected to the database and wrote data');
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        title: Center(
          child: _error == null
              ? Text(_notesController.text)
              : Text(
                  'Error retrieving notes:\n${_error!.message}',
                ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Edit notes',
              ),
              maxLines: 4,
            ),
          ),
          ElevatedButton(
              onPressed: () => setWorkoutData(), child: const Text("Save")),
          const SizedBox(
            height: 10.0,
          )
        ]);
  }
}
