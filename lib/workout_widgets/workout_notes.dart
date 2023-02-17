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
  late FocusNode _notesFocusNode;

  final DatabaseReference _workoutRef =
      FirebaseDatabase.instance.ref("/workouts/");
  late StreamSubscription<DatabaseEvent> _workoutSubscription;

  FirebaseException? _error;

  @override
  void initState() {
    super.initState();
    _notesFocusNode = FocusNode();

    _getWorkoutData();
    _listenForChanges();
  }

  // Fetch the notes again if user changes the date
  // also call listenForChanges again to change the subscription date
  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _getWorkoutData();
      _workoutSubscription.cancel();
      _listenForChanges();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _notesFocusNode.dispose();

    _workoutSubscription.cancel();
  }

  void _listenForChanges() async {
    final queryDate = DateFormat("dd,MM,yyyy").format(widget.selectedDate);

    _workoutSubscription =
        _workoutRef.child("${widget.userId}/$queryDate").onValue.listen(
      (event) {
        if (event.snapshot.exists) {
          Map<String, dynamic> notes =
              Map<String, dynamic>.from(event.snapshot.value as Map);
          setState(() {
            _notesController.text = notes['notes'];
            _error = null;
          });
        } else {
          setState(() {
            _notesController.text = '';
          });
        }
      },
      onError: (Object o) {
        final error = o as FirebaseException;
        setState(() {
          _error = error;
        });
      },
    );
  }

  void _getWorkoutData() async {
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
    } on FirebaseException catch (err) {
      setState(() {
        _error = err;
      });
    }
  }

  void _setWorkoutData() async {
    final queryDate = DateFormat("dd,MM,yyyy").format(widget.selectedDate);
    try {
      await _workoutRef
          .child("${widget.userId}/$queryDate")
          .update({'notes': _notesController.text});
      print('Connected to the database and wrote data');
    } on FirebaseException catch (err) {
      setState(() {
        _error = err;
      });
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
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.1),
      child: TextFormField(
        controller: _error == null
            ? _notesController
            : TextEditingController(
                text: 'Error retrieving notes:\n${_error!.message}'),
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
