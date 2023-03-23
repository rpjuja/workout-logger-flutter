import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workout_logger_app/error_messages.dart';

class WorkoutNotes extends StatefulWidget {
  const WorkoutNotes(
      {Key? key, required this.userId, required this.selectedDate})
      : super(key: key);

  final String userId;
  final DateTime selectedDate;

  @override
  State<WorkoutNotes> createState() => _WorkoutNotesState();
}

class _WorkoutNotesState extends State<WorkoutNotes> {
  final TextEditingController _notesController = TextEditingController();
  late FocusNode _notesFocusNode;

  final DatabaseReference _workoutRef =
      FirebaseDatabase.instance.ref("/workouts/");
  late StreamSubscription<DatabaseEvent> _workoutSubscription;

  @override
  void initState() {
    super.initState();
    _notesFocusNode = FocusNode();
    _getNotesAndListen();
  }

  // Call getNotesAndListen again if user changes the date
  // to change the subscription date
  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _workoutSubscription.cancel();
      _getNotesAndListen();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _notesFocusNode.dispose();
    _notesController.dispose();
    _workoutSubscription.cancel();
  }

  Future<void> _getNotesAndListen() async {
    final queryDate = DateFormat("dd,MM,yyyy").format(widget.selectedDate);

    _workoutSubscription =
        _workoutRef.child("${widget.userId}/$queryDate").onValue.listen(
      (event) {
        if (event.snapshot.exists) {
          Map<String, dynamic> notes =
              Map<String, dynamic>.from(event.snapshot.value as Map);
          setState(() {
            _notesController.text = notes['notes'];
          });
        } else {
          setState(() {
            _notesController.text = '';
          });
        }
      },
      onError: (Object o) {
        final e = o as FirebaseException;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error retrieving notes:/n${getErrorMessage(e)}')));
      },
    );
  }

  Future<void> _setWorkoutData() async {
    final queryDate = DateFormat("dd,MM,yyyy").format(widget.selectedDate);
    try {
      await _workoutRef
          .child("${widget.userId}/$queryDate")
          .update({'notes': _notesController.text}).then((value) =>
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Notes saved'))));
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error saving notes:/n${getErrorMessage(e)}')));
    }
  }

  void _requestFocus() {
    setState(() {
      FocusScope.of(context).requestFocus(_notesFocusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          _notesFocusNode.hasFocus
              ? BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                )
              : BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: const Offset(0, 3), // changes position of shadow
                )
        ],
      ),
      child: TextFormField(
        controller: _notesController,
        focusNode: _notesFocusNode,
        onTap: _requestFocus,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: _notesController.text.isEmpty ? 'Add notes' : 'Notes',
          labelStyle: TextStyle(
              fontSize: 20,
              color: _notesFocusNode.hasFocus
                  ? Colors.deepPurple
                  : Colors.deepPurple[300]),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple[300]!),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.deepPurple, width: 2),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          suffixIcon: IconButton(
            onPressed: () => _setWorkoutData(),
            icon: const Icon(Icons.save_alt),
            iconSize: 30,
            splashRadius: 20,
            splashColor: Colors.deepPurple,
            color: _notesFocusNode.hasFocus
                ? Colors.deepPurple
                : Colors.deepPurple[300],
          ),
        ),
      ),
    );
  }
}
