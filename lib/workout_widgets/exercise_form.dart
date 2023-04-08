import 'package:flutter/material.dart';

import '../muscle_group.dart';
import 'exercise_entry.dart';

class ExerciseForm extends StatefulWidget {
  final Function(String, Map<dynamic, dynamic>, MuscleGroup, MuscleGroup) onConfirm;

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
  int _setAmount = 1;
  final List<TextEditingController> _repsControllers = <TextEditingController>[];
  final List<TextEditingController> _weightControllers = <TextEditingController>[];
  MuscleGroup _selectedPrimaryMuscleGroup = MuscleGroup.none;
  MuscleGroup _selectedSecondaryMuscleGroup = MuscleGroup.none;
  final _formKey = GlobalKey<FormState>();

  bool _isNumeric(string) => num.tryParse(string) != null;

  @override
  void initState() {
    super.initState();
    if (widget.exercise != null) {
      _nameController.text = widget.exercise!.name;
      _setAmount = widget.exercise!.sets.length;
      for (int i = 0; i < widget.exercise!.sets.length; i++) {
        _repsControllers.add(TextEditingController());
        _weightControllers.add(TextEditingController());
        _repsControllers[i].text = widget.exercise!.sets[i]['reps'].toString();
        _weightControllers[i].text = widget.exercise!.sets[i]['weight'].toString();
      }
      _selectedPrimaryMuscleGroup = widget.exercise!.primaryMuscleGroup;
      _selectedSecondaryMuscleGroup = widget.exercise!.secondaryMuscleGroup;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (TextEditingController controller in _repsControllers) {
      controller.dispose();
    }
    for (TextEditingController controller in _weightControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    for (TextEditingController controller in _repsControllers) {
      controller.clear();
    }
    for (TextEditingController controller in _weightControllers) {
      controller.clear();
    }
    setState(() {
      _setAmount = 1;
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
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    flex: 1,
                    // Dropdown button for sets
                    child: DropdownButtonFormField<String>(
                      key: const Key('exerciseSetsDropdown'),
                      isDense: true,
                      menuMaxHeight: MediaQuery.of(context).size.height * 0.3,
                      alignment: Alignment.center,
                      focusColor: Colors.white,
                      value: _setAmount.toString(),
                      items: List.generate(10, (index) => index + 1)
                          .map((sets) => DropdownMenuItem<String>(
                                value: sets.toString(),
                                child: Text(sets.toString()),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _setAmount = int.parse(value!);
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    flex: 2,
                    child: SizedBox(
                      // Make the listview scrollable if there are too many sets to show on the screen
                      height: MediaQuery.of(context).size.height * 0.06 * _setAmount >
                              MediaQuery.of(context).size.height * 0.24
                          ? MediaQuery.of(context).size.height * 0.24
                          : MediaQuery.of(context).size.height * 0.06 * _setAmount,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                          itemCount: _setAmount,
                          itemBuilder: (BuildContext context, int index) {
                            // Check that there are controllers shown for the amount of sets specified
                            // filter out the empty controllers later
                            if (index >= _repsControllers.length) {
                              _repsControllers.add(TextEditingController());
                              _weightControllers.add(TextEditingController());
                            }
                            return Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    key: Key('exerciseRepsField$index'),
                                    controller: _repsControllers[index],
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
                                    key: Key('exerciseWeightField$index'),
                                    controller: _weightControllers[index],
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
                            );
                          }),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
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
                  // Create a map of sets that filters out the empty controllers
                  // and is the length of the amount of sets specified
                  Map<dynamic, dynamic> sets = {};
                  for (int i = 0; i < _setAmount; i++) {
                    if (_repsControllers[i].text != "") {
                      sets[i] = {
                        "reps": _repsControllers[i].text,
                        "weight": _weightControllers[i].text
                      };
                    }
                  }
                  widget
                      .onConfirm(_nameController.text, sets, _selectedPrimaryMuscleGroup,
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
