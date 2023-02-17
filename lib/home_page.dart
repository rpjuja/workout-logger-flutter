import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'workout_widgets/exercise_list.dart';
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
  final _userId = 1;
  late DatabaseReference _userRef;

  final RestorableDateTime _selectedDate = RestorableDateTime(DateTime.now());

  bool _initialized = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    final database = FirebaseDatabase.instance;
    _userRef = FirebaseDatabase.instance.ref("/users/");

    // Enable disk persistence on mobile devices
    if (!kIsWeb) {
      database.setPersistenceEnabled(true);
      database.setPersistenceCacheSizeBytes(10000000);
    }

    _getUserData();

    setState(() {
      _initialized = true;
    });
  }

  void _getUserData() async {
    try {
      final snapshot =
          await _userRef.child("$_userId").once(DatabaseEventType.value);
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
    return Scaffold(
        appBar: AppBar(
          title: const Text("Workout Tracker"),
        ),
        body: !_initialized
            ? const Center(child: CircularProgressIndicator())
            : Column(children: [
                DateScroll(
                    date: _selectedDate.value,
                    dateAdded: _dateAdded,
                    dateSubtracted: _dateSubtracted),
                ExerciseList(
                    userId: _userId, selectedDate: _selectedDate.value),
              ]),
        bottomNavigationBar:
            NavBar(date: _selectedDate.value, dateChanged: _dateChanged));
  }
}
