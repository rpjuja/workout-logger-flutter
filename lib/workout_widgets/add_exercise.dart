import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../error_messages.dart';
import '../styles.dart';

class AddExercise extends StatefulWidget {
  const AddExercise(
      {Key? key,
      this.testDatabaseReference,
      required this.userId,
      required this.selectedDate})
      : super(key: key);

  final DatabaseReference? testDatabaseReference;
  final String userId;
  final DateTime selectedDate;

  @override
  State<AddExercise> createState() => _AddExerciseState();
}

class _AddExerciseState extends State<AddExercise> {
  late final DatabaseReference _workoutRef;

  final _nameController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isNumeric(string) => num.tryParse(string) != null;

  @override
  void initState() {
    super.initState();
    // When testing, the widget will receive a testDatabaseReference, otherwise use the real database
    _workoutRef = widget.testDatabaseReference ??
        FirebaseDatabase.instance.ref("exercises");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _clearTextFields() {
    _nameController.clear();
    _setsController.clear();
    _repsController.clear();
    _weightController.clear();
  }

  Future<void> _addExercise() async {
    final queryDate = DateFormat("dd,MM,yyyy").format(widget.selectedDate);

    var exerciseId =
        _workoutRef.child('${widget.userId}/$queryDate').push().key;
    try {
      await _workoutRef
          .child("${widget.userId}/$queryDate/$exerciseId")
          .set({
            'name': _nameController.text,
            'sets': _setsController.text,
            'reps': _repsController.text,
            'weight': _weightController.text,
          })
          .then((value) => Navigator.of(context).pop(true))
          .then((value) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${_nameController.text} added'))))
          .then((value) => _clearTextFields());
    } on FirebaseException catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error adding exercise:/n${getErrorMessage(err)}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      buttonPadding: const EdgeInsets.all(30.0),
      children: [
        ElevatedButton(
          key: const Key('addExerciseButton'),
          style: ButtonStyles.shadowPadding,
          onPressed: () {
            showDialog(
                context: context,
                builder: ((context) {
                  return Form(
                    key: _formKey,
                    child: AlertDialog(
                      title: const Text('Add Exercise'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            key: const Key('exerciseNameField'),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  key: const Key('exerciseSetsField'),
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
                                  key: const Key('exerciseRepsField'),
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
                                  key: const Key('exerciseWeightField'),
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
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          key: const Key('cancelButton'),
                          onPressed: () => {
                            _clearTextFields(),
                            Navigator.of(context).pop(),
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          key: const Key('addButton'),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _addExercise();
                            }
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  );
                }));
          },
          child: const Text('Add Exercise'),
        ),
      ],
    );
  }
}
