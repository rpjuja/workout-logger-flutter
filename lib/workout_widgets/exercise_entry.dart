import 'package:flutter/material.dart';
import 'package:workout_logger_app/muscle_group.dart';

class ExerciseEntry extends StatelessWidget {
  final String id;
  final String name;
  final List sets;
  final MuscleGroup primaryMuscleGroup;
  final MuscleGroup secondaryMuscleGroup;

  const ExerciseEntry(
      {Key? key,
      required this.id,
      required this.name,
      required this.sets,
      required this.primaryMuscleGroup,
      required this.secondaryMuscleGroup})
      : super(key: key);

  String shortestHyphenLongestSet() {
    int shortest = 999, longest = 0;
    for (var set in sets) {
      int setLength = int.parse(set['reps']);
      if (setLength < shortest) shortest = setLength;
      if (setLength > longest) longest = setLength;
    }
    if (shortest == longest) {
      return shortest.toString();
    } else {
      return "$longest-$shortest";
    }
  }

  String leastHyphenMostWeight() {
    double least = 999, most = 0;
    for (var set in sets) {
      double setWeight = double.parse(set['weight']);
      if (setWeight < least) least = setWeight;
      if (setWeight > most) most = setWeight;
    }
    if (least == most) {
      return removeDecimalZeroFormat(least);
    } else {
      return "${removeDecimalZeroFormat(most)}-${removeDecimalZeroFormat(least)}";
    }
  }

  String removeDecimalZeroFormat(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(
          MediaQuery.of(context).size.width * 0.1, 0, MediaQuery.of(context).size.width * 0.1, 10),
      elevation: 10,
      shadowColor: Colors.deepPurple[300]?.withOpacity(0.5),
      child: Row(children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.325,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(name),
              )),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.05,
          alignment: Alignment.center,
          child: Text(sets.length.toString()),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.15,
          alignment: Alignment.center,
          child: Text(shortestHyphenLongestSet()),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.275,
          padding: const EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 10.0),
          alignment: Alignment.center,
          child: Text(leastHyphenMostWeight()),
        ),
      ]),
    );
  }
}
