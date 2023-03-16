import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../error_messages.dart';
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

  final _nameController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isNumeric(string) => num.tryParse(string) != null;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.exercise.name;
    _setsController.text = widget.exercise.sets;
    _repsController.text = widget.exercise.reps;
    _weightController.text = widget.exercise.weight;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _modifyExercise() async {
    final queryDate = DateFormat("dd,MM,yyyy").format(widget.selectedDate);

    try {
      await _workoutRef
          .child("${widget.userId}/$queryDate/${widget.exercise.id}")
          .set({
            'name': _nameController.text,
            'sets': _setsController.text,
            'reps': _repsController.text,
            'weight': _weightController.text,
          })
          .then((value) => Navigator.of(context).pop())
          .then((value) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${_nameController.text} modified'))));
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error editing exercise:/n${getErrorMessage(e)}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AlertDialog(
        title: const Text('Modify Exercise'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(
            controller: _nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Exercise Name',
              suffixIcon: IconButton(
                onPressed: _nameController.clear,
                icon: const Icon(Icons.clear),
              ),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Expanded(
              child: TextFormField(
                controller: _setsController,
                validator: (value) {
                  if (value == null || !_isNumeric(value)) {
                    return 'Please enter a number';
                  }
                  return null;
                },
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'Sets',
                  errorMaxLines: 3,
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: TextFormField(
                controller: _repsController,
                validator: (value) {
                  if (value == null || !_isNumeric(value)) {
                    return 'Please enter a number';
                  }
                  return null;
                },
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'Reps',
                  errorMaxLines: 3,
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: TextFormField(
                controller: _weightController,
                validator: (value) {
                  if (value == null || !_isNumeric(value)) {
                    return 'Please enter a number';
                  }
                  return null;
                },
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'Weight',
                  errorMaxLines: 3,
                ),
              ),
            ),
          ]),
        ]),
        actions: [
          TextButton(
            onPressed: () => {
              Navigator.of(context).pop(),
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _modifyExercise();
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
