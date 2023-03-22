import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workout_logger_app/muscle_group.dart';

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
  MuscleGroup _selectedPrimaryMuscleGroup = MuscleGroup.none;
  MuscleGroup _selectedSecondaryMuscleGroup = MuscleGroup.none;
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
    _selectedPrimaryMuscleGroup = MuscleGroup.none;
    _selectedSecondaryMuscleGroup = MuscleGroup.none;
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
            'primaryMuscleGroup': _selectedPrimaryMuscleGroup.name.toString(),
            'secondaryMuscleGroup':
                _selectedSecondaryMuscleGroup.name.toString(),
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
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: ElevatedButton(
              key: const Key('addExerciseButton'),
              style: ButtonStyles.shadowPadding,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: ((context) {
                      return Form(
                        key: _formKey,
                        child: AlertDialog(
                          title: const Text('Add exercise'),
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
                                  hintText: 'Exercise name',
                                  suffixIcon: IconButton(
                                    onPressed: _nameController.clear,
                                    icon: const Icon(Icons.clear),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      key: const Key('exerciseSetsField'),
                                      controller: _setsController,
                                      validator: (value) {
                                        if (value == null ||
                                            !_isNumeric(value)) {
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
                                        if (value == null ||
                                            !_isNumeric(value)) {
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
                                        if (value == null ||
                                            !_isNumeric(value)) {
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
                              const SizedBox(
                                height: 20,
                              ),
                              const Text("Primary muscle group"),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<MuscleGroup>(
                                isDense: true,
                                focusColor: Colors.white,
                                value: _selectedPrimaryMuscleGroup,
                                items: MuscleGroup.values
                                    .map((muscleGroup) =>
                                        DropdownMenuItem<MuscleGroup>(
                                          value: muscleGroup,
                                          child: muscleGroup == MuscleGroup.none
                                              ? const Text("Not selected")
                                              : Text(muscleGroup.name
                                                  .toString()
                                                  .capitalize()),
                                        ))
                                    .toList(),
                                onChanged: (value) => {
                                  setState(() {
                                    _selectedPrimaryMuscleGroup = value!;
                                  })
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Text("Secondary muscle group"),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<MuscleGroup>(
                                isDense: true,
                                focusColor: Colors.white,
                                value: _selectedSecondaryMuscleGroup,
                                items: MuscleGroup.values
                                    .map((muscleGroup) =>
                                        DropdownMenuItem<MuscleGroup>(
                                          value: muscleGroup,
                                          child: muscleGroup == MuscleGroup.none
                                              ? const Text("Not selected")
                                              : Text(muscleGroup.name
                                                  .toString()
                                                  .capitalize()),
                                        ))
                                    .toList(),
                                onChanged: (value) => {
                                  setState(() {
                                    _selectedSecondaryMuscleGroup = value!;
                                  })
                                },
                                validator: (value) {
                                  if (value != MuscleGroup.none &&
                                      value == _selectedPrimaryMuscleGroup) {
                                    return "Primary and secondary muscle groups can't be the same";
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  errorMaxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            Tooltip(
                              message:
                                  'Primary muscle group is the muscle group that is the main focus of the exercise. Secondary muscle group is a muscle group that is also worked out by the exercise. Both of these fields are optional, but recommended for keeping track of total sets done.',
                              preferBelow: false,
                              margin: EdgeInsets.fromLTRB(
                                  MediaQuery.of(context).size.width * 0.1,
                                  0,
                                  MediaQuery.of(context).size.width * 0.1,
                                  0),
                              child: IconButton(
                                onPressed: () => {},
                                icon: const Icon(Icons.info),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.2,
                            ),
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
              child: const Text('Add exercise'),
            ),
          ),
        ]);
  }
}
