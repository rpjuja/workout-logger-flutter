import 'package:flutter/material.dart';

import 'exercise_entry.dart';

class ExerciseList extends StatefulWidget {
  const ExerciseList({Key? key}) : super(key: key);

  @override
  State<ExerciseList> createState() => _ExerciseListState();
}

class _ExerciseListState extends State<ExerciseList> {
  List<ExerciseEntry> exercises = [
    ExerciseEntry(name: 'Bench press', sets: '4', reps: '8', weight: '100'),
    ExerciseEntry(name: 'Barbell Row', sets: '3', reps: '10', weight: '120'),
    ExerciseEntry(name: 'Overhead Press', sets: '3', reps: '8', weight: '75'),
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView.builder(
      itemCount: exercises.length,
      itemBuilder: (BuildContext context, int index) {
        return Dismissible(
          key: Key(exercises[index].name),
          direction: DismissDirection.endToStart,
          onDismissed: (diretion) {
            setState(() {
              exercises.removeAt(index);
            });
          },
          dismissThresholds: const <DismissDirection, double>{
            DismissDirection.endToStart: 0.5,
          },
          // Ask user for confirmation before deleting
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Confirm"),
                  content: Text(
                      'Are you sure you wish to delete ${exercises[index].name}?'),
                  actions: <Widget>[
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent),
                        onPressed: () => {
                              Navigator.of(context).pop(true),
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          '${exercises[index].name} removed')))
                            },
                        child: const Text("DELETE")),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("CANCEL"),
                    ),
                  ],
                );
              },
            );
          },
          background: Container(
            color: Colors.redAccent,
            child: const Icon(Icons.delete),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 10.0),
            margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.1,
                0, MediaQuery.of(context).size.width * 0.1, 10),
          ),
          child: exercises[index].buildCard(context),
        );
      },
    ));
  }
}
