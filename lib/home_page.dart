import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'workout_widgets/exercise_list.dart';
import 'workout_widgets/add_exercise.dart';
import 'workout_widgets/workout_notes.dart';
import 'date_scroll.dart';
import 'nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RestorationMixin {
  @override
  String? get restorationId => "home_page";
  final String _userId = '1';

  late final DatabaseReference _userRef;

  final RestorableDateTime _selectedDate = RestorableDateTime(DateTime.now());

  @override
  void initState() {
    super.initState();
    _userRef = FirebaseDatabase.instance.ref("/users/");
    _getUserData();
  }

  void _getUserData() async {
    try {
      final snapshot =
          await _userRef.child(_userId).once(DatabaseEventType.value);
      if (snapshot.snapshot.value != null) {
        print('Connected to the database and read ${snapshot.snapshot.value}');
      } else {
        print('Connected to the database but no data found');
      }
    } catch (e) {
      print(e);
    }
  }

  void _dateAdded() {
    setState(() {
      _selectedDate.value = _selectedDate.value.add(const Duration(days: 1));
    });
  }

  void _dateSubtracted() {
    setState(() {
      _selectedDate.value =
          _selectedDate.value.subtract(const Duration(days: 1));
    });
  }

  void _dateChanged(DateTime date) {
    setState(() {
      _selectedDate.value = date;
    });
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus() /* hide keyboard */,
      child: Scaffold(
          appBar: AppBar(
            elevation: 10,
            shadowColor: Colors.deepPurple[300],
            title: const Text("Workout Tracker"),
          ),
          body: Column(
            children: [
              DateScroll(
                  date: _selectedDate.value,
                  dateAdded: _dateAdded,
                  dateSubtracted: _dateSubtracted),
              ExerciseList(userId: _userId, selectedDate: _selectedDate.value),
              WorkoutNotes(userId: _userId, selectedDate: _selectedDate.value),
              AddExercise(
                userId: _userId,
                selectedDate: _selectedDate.value,
              ),
            ],
          ),
          bottomNavigationBar:
              NavBar(date: _selectedDate.value, dateChanged: _dateChanged)),
    );
  }
}
