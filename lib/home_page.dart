import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_widgets/auth_service.dart';
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
  late final User _user;

  final RestorableDateTime _selectedDate = RestorableDateTime(DateTime.now());

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void _getUserData() async {
    try {
      setState(() {
        _user = FirebaseAuth.instance.currentUser!;
      });
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
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => AuthService().signOut(context),
              ),
            ],
          ),
          body: Column(
            children: [
              DateScroll(
                  date: _selectedDate.value,
                  dateAdded: _dateAdded,
                  dateSubtracted: _dateSubtracted),
              ExerciseList(
                  userId: _user.uid, selectedDate: _selectedDate.value),
              WorkoutNotes(
                  userId: _user.uid, selectedDate: _selectedDate.value),
              AddExercise(
                userId: _user.uid,
                selectedDate: _selectedDate.value,
              ),
            ],
          ),
          bottomNavigationBar:
              NavBar(date: _selectedDate.value, dateChanged: _dateChanged)),
    );
  }
}
