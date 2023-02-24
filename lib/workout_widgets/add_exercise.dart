import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddExercise extends StatefulWidget {
  const AddExercise(
      {Key? key, required this.userId, required this.selectedDate})
      : super(key: key);

  final String userId;
  final DateTime selectedDate;

  @override
  State<AddExercise> createState() => _AddExerciseState();
}

class _AddExerciseState extends State<AddExercise> {
  final DatabaseReference _workoutRef =
      FirebaseDatabase.instance.ref("/exercises/");

  FirebaseException? _error;

  final _name = TextEditingController();
  final _sets = TextEditingController();
  final _reps = TextEditingController();
  final _weight = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isNumeric(string) => num.tryParse(string) != null;

  void _clearTextFields() {
    _name.clear();
    _sets.clear();
    _reps.clear();
    _weight.clear();
  }

  void _addExercise() async {
    final queryDate = DateFormat("dd,MM,yyyy").format(widget.selectedDate);

    var exerciseId =
        _workoutRef.child('/${widget.userId}/$queryDate/').push().key;
    try {
      await _workoutRef.child("${widget.userId}/$queryDate/$exerciseId").set({
        'name': _name.text,
        'sets': _sets.text,
        'reps': _reps.text,
        'weight': _weight.text,
      });
      print('Connected to the database and wrote data');
      _clearTextFields();
      Navigator.of(context).pop();
    } on FirebaseException catch (err) {
      setState(() {
        _error = err;
      });
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
          style: ElevatedButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
            elevation: 10,
            shadowColor: Colors.deepPurple[300],
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
                                  controller: _reps,
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
                                  controller: _weight,
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
                          _error != null
                              ? Container(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Text(
                                      "Error when adding exercise:\n${_error!.message}}}"),
                                )
                              : Container(),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => {
                            _clearTextFields(),
                            Navigator.of(context).pop(),
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
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
