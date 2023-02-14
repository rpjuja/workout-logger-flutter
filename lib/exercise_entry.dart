import 'package:flutter/material.dart';

class ExerciseEntry extends StatelessWidget {
  final String name;
  final String sets;
  final String reps;
  final String weight;

  const ExerciseEntry(
      {Key? key,
      required this.name,
      required this.sets,
      required this.reps,
      required this.weight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        Container(
          width: MediaQuery.of(context).size.width * 0.1,
          alignment: Alignment.center,
          child: Text(sets),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.1,
          alignment: Alignment.center,
          child: Text(reps),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.1,
          alignment: Alignment.center,
          child: Text(weight),
        ),
      ]),
    );
  }
}
