import 'package:flutter/material.dart';
import 'package:workout_logger_app/exercise_entry.dart';

class AddExercise extends StatefulWidget {
  final Function(ExerciseEntry) notifyParent;
  const AddExercise({Key? key, required this.notifyParent}) : super(key: key);

  @override
  State<AddExercise> createState() => _AddExerciseState();
}

class _AddExerciseState extends State<AddExercise> {
  final _name = TextEditingController();
  final _sets = TextEditingController();
  final _reps = TextEditingController();
  final _weight = TextEditingController();

  isNumeric(string) => num.tryParse(string) != null;

  clearTextFields() {
    _name.clear();
    _sets.clear();
    _reps.clear();
    _weight.clear();
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return ButtonBar(
      alignment: MainAxisAlignment.center,
      buttonPadding: const EdgeInsets.all(30.0),
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
          ),
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
                              controller: _name,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a name';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'Exercise Name',
                                suffixIcon: IconButton(
                                  onPressed: _name.clear,
                                  icon: const Icon(Icons.clear),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _sets,
                                    validator: (value) {
                                      if (value == null || !isNumeric(value)) {
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
                                    controller: _reps,
                                    validator: (value) {
                                      if (value == null || !isNumeric(value)) {
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
                                    controller: _weight,
                                    validator: (value) {
                                      if (value == null || !isNumeric(value)) {
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
                            onPressed: () => {
                              clearTextFields(),
                              Navigator.of(context).pop(),
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                widget.notifyParent(ExerciseEntry(
                                    name: _name.text,
                                    sets: _sets.text,
                                    reps: _reps.text,
                                    weight: _weight.text));
                                clearTextFields();
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      ));
                }));
          },
          child: const Text('Add Exercise'),
        ),
      ],
    );
  }
}
