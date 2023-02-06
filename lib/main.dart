import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';

import 'home_page.dart';

FirebaseDatabase database = FirebaseDatabase.instance;

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final Future<FirebaseApp> _fbApp = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout logger',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
              .copyWith(secondary: Colors.purple[300])),
      // Show the app once firebase has finished initializing
      home: FutureBuilder(
          future: _fbApp,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              // ignore: avoid_print
              print('You have an error! ${snapshot.error.toString()}');
              return const Text('Something went wrong');
            } else if (snapshot.hasData) {
              return const HomePage(title: 'Workout logger');
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
      // routes: {}
    );
  }
}
