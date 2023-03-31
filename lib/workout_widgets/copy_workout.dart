import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workout_logger_app/styles.dart';

class CopyWorkout extends StatefulWidget {
  const CopyWorkout(
      {Key? key,
      required this.selectedDate,
      required this.userId,
      required this.databaseReference})
      : super(key: key);

  final DateTime selectedDate;
  final String userId;
  final DatabaseReference databaseReference;

  @override
  State<CopyWorkout> createState() => _CopyWorkoutState();
}

class _CopyWorkoutState extends State<CopyWorkout> with RestorationMixin {
  @override
  String? get restorationId => "copy_workout";
  late final DatabaseReference _workoutRef;

  @override
  void initState() {
    super.initState();
    // Take databaseReference from the parent widget for testing purposes
    _workoutRef = widget.databaseReference;
  }

  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
      RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: widget.selectedDate.millisecondsSinceEpoch,
      );
    },
  );

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _copyPreviousWorkout(newSelectedDate);
      });
    }
  }

  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog_for_copy_workout',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          helpText: 'SELECT DATE TO COPY FROM',
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime(2022),
          lastDate: DateTime(2030),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_restorableDatePickerRouteFuture,
        'date_picker_route_future_for_copy_workout');
  }

  Future<void> _copyPreviousWorkout(date) async {
    final previousQueryDate = DateFormat("dd,MM,yyyy").format(date);
    final previousWorkout =
        await _workoutRef.child("${widget.userId}/$previousQueryDate").once();
    final currentqueryDate =
        DateFormat("dd,MM,yyyy").format(widget.selectedDate);
    if (previousWorkout.snapshot.exists) {
      await _workoutRef
          .child("${widget.userId}/$currentqueryDate")
          .set(previousWorkout.snapshot.value)
          .then((value) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Workout copied from $date'))));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No workout to copy on that date')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      buttonPadding: const EdgeInsets.all(20),
      children: [
        ElevatedButton(
            onPressed: () => _restorableDatePickerRouteFuture.present(),
            style: ButtonStyles.shadowPadding,
            child: const Text('Copy workout from previous date')),
      ],
    );
  }
}
