import 'package:flutter/material.dart';

import '../muscle_group.dart';
import 'exercise_entry.dart';

class ExerciseForm extends StatefulWidget {
  final Function(String, String, String, String, MuscleGroup, MuscleGroup) onConfirm;

  const ExerciseForm({
    Key? key,
    required this.parentName,
    required this.onConfirm,
    this.exercise,
  }) : super(key: key);

  final String parentName;
  final ExerciseEntry? exercise;

  @override
  State<ExerciseForm> createState() => _ExerciseFormState();
}

class _ExerciseFormState extends State<ExerciseForm> {
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
    if (widget.exercise != null) {
      _nameController.text = widget.exercise!.name;
      _setsController.text = widget.exercise!.sets;
      _repsController.text = widget.exercise!.reps;
      _weightController.text = widget.exercise!.weight;
      _selectedPrimaryMuscleGroup = widget.exercise!.primaryMuscleGroup;
      _selectedSecondaryMuscleGroup = widget.exercise!.secondaryMuscleGroup;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _setsController.clear();
    _repsController.clear();
    _weightController.clear();
    setState(() {
      _selectedPrimaryMuscleGroup = MuscleGroup.none;
      _selectedSecondaryMuscleGroup = MuscleGroup.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AlertDialog(
        title: widget.parentName == "add"
            ? const Text('Add exercise')
            : widget.parentName == "modify"
                ? const Text('Modify exercise')
                : const Text(''),
        content: SingleChildScrollView(
          child: Column(
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextFormField(
                      key: const Key('exerciseSetsField'),
                      controller: _setsController,
                      validator: (value) {
                        if (value == null || !_isNumeric(value)) {
                          return 'Please enter a number';
                        } else if (int.parse(value) <= 0 || int.parse(value) > 10) {
                          return 'Please enter a number between 1 and 10';
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
                  if (value != MuscleGroup.none && value == _selectedPrimaryMuscleGroup) {
                    return "Primary and secondary muscle groups can't be the same";
                  } else if (value != MuscleGroup.none &&
                      _selectedPrimaryMuscleGroup == MuscleGroup.none) {
                    return "Cant't have a secondary muscle group without a primary muscle group";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  errorMaxLines: 2,
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Tooltip(
              message:
                  'Primary muscle group is the muscle group that is the main focus of the exercise. Secondary muscle group is a muscle group that is also worked out by the exercise. Both of these fields are optional, but recommended for keeping track of total sets done.',
              preferBelow: false,
              triggerMode: TooltipTriggerMode.tap,
              showDuration: const Duration(seconds: 10),
              margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.1, 0,
                  MediaQuery.of(context).size.width * 0.1, 0),
              child: const Icon(
                Icons.info,
              ),
            ),
            const Spacer(),
            TextButton(
              key: const Key('cancelButton'),
              onPressed: () => {
                _clearForm(),
                Navigator.of(context).pop(),
              },
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              key: const Key('confirmButton'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget
                      .onConfirm(
                          _nameController.text,
                          _setsController.text,
                          _repsController.text,
                          _weightController.text,
                          _selectedPrimaryMuscleGroup,
                          _selectedSecondaryMuscleGroup)
                      .then((value) => _clearForm());
                }
              },
              child: widget.parentName == "add"
                  ? const Text('Add')
                  : widget.parentName == "modify"
                      ? const Text('Confirm')
                      : const Text(''),
            ),
          ])
        ],
      ),
    );
  }
}
