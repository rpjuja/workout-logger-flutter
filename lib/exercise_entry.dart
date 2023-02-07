import 'package:flutter/material.dart';

class ExerciseEntry {
  final String name;
  final String sets;
  final String reps;
  final String weight;

  ExerciseEntry(
      {required this.name,
      required this.sets,
      required this.reps,
      required this.weight});

  Widget buildCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.1, 0,
          MediaQuery.of(context).size.width * 0.1, 10),
      child: Row(children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(name),
              )),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.1,
          child: Container(
            alignment: Alignment.center,
            child: Text(sets),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.1,
          child: Container(
            alignment: Alignment.center,
            child: Text(reps),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.1,
          child: Container(
            alignment: Alignment.center,
            child: Text(weight),
          ),
        ),
      ]),
    );
  }
}
