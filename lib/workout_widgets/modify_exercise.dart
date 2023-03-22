import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../error_messages.dart';
import '../muscle_group.dart';
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
  MuscleGroup _selectedPrimaryMuscleGroup = MuscleGroup.none;
  MuscleGroup _selectedSecondaryMuscleGroup = MuscleGroup.none;
  final _formKey = GlobalKey<FormState>();

  bool _isNumeric(string) => num.tryParse(string) != null;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.exercise.name;
    _setsController.text = widget.exercise.sets;
    _repsController.text = widget.exercise.reps;
    _weightController.text = widget.exercise.weight;
    _selectedPrimaryMuscleGroup =
        widget.exercise.primaryMuscleGroup ?? MuscleGroup.none;
    _selectedSecondaryMuscleGroup =
        widget.exercise.secondaryMuscleGroup ?? MuscleGroup.none;
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
                .map((muscleGroup) => DropdownMenuItem<MuscleGroup>(
                      value: muscleGroup,
                      child: muscleGroup == MuscleGroup.none
                          ? const Text("Not selected")
                          : Text(muscleGroup.name.toString().capitalize()),
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
                .map((muscleGroup) => DropdownMenuItem<MuscleGroup>(
                      value: muscleGroup,
                      child: muscleGroup == MuscleGroup.none
                          ? const Text("Not selected")
                          : Text(muscleGroup.name.toString().capitalize()),
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
        ]),
        actions: [
          Tooltip(
            message:
                'Primary muscle group is the muscle group that is the main focus of the exercise. Secondary muscle group is a muscle group that is also worked out by the exercise. Both of these fields are optional, but recommended for keeping track of total sets done.',
            preferBelow: false,
            margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.1,
                0, MediaQuery.of(context).size.width * 0.1, 0),
            child: IconButton(
              onPressed: () => {},
              icon: const Icon(Icons.info),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
          ),
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
