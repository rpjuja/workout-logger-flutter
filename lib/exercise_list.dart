import 'package:flutter/material.dart';

import 'exercise_entry.dart';
import 'add_exercise.dart';

class ExerciseList extends StatefulWidget {
  const ExerciseList({Key? key}) : super(key: key);

  @override
  State<ExerciseList> createState() => _ExerciseListState();
}

class _ExerciseListState extends State<ExerciseList> {
  List<ExerciseEntry> exerciseList = [
    ExerciseEntry(name: 'Bench press', sets: '4', reps: '8', weight: '100'),
    ExerciseEntry(name: 'Barbell Row', sets: '3', reps: '10', weight: '120'),
    ExerciseEntry(name: 'Overhead Press', sets: '3', reps: '8', weight: '75'),
  ];

  addExercise(ExerciseEntry exercise) {
    setState(() {
      exerciseList.add(exercise);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: ListView.builder(
            itemCount: exerciseList.length,
            itemBuilder: (BuildContext context, int index) {
              return Dismissible(
                key: Key(exerciseList[index].name),
                direction: DismissDirection.endToStart,
                onDismissed: (diretion) {
                  setState(() {
                    exerciseList.removeAt(index);
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
                            'Are you sure you wish to delete ${exerciseList[index].name}?'),
                        actions: <Widget>[
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple),
                              onPressed: () => {
                                    Navigator.of(context).pop(true),
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                '${exerciseList[index].name} removed')))
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
                  child: const Icon(Icons.delete),
                  decoration: const BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 10.0),
                  margin: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width * 0.1,
                      0,
                      MediaQuery.of(context).size.width * 0.1,
                      10),
                ),
                child: exerciseList[index].buildCard(context),
              );
            },
          ),
        ),
        AddExercise(notifyParent: addExercise)
      ],
    ));
  }
}
