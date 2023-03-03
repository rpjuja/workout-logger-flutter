import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';

import 'home_page.dart';

FirebaseDatabase database = FirebaseDatabase.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final FirebaseDatabase _database;
  bool _initialized = false;

  final Future<FirebaseApp> _fbApp = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable disk persistence on mobile devices
  void setPersistence() async {
    _database = FirebaseDatabase.instance;

    if (!kIsWeb) {
      _database.setPersistenceEnabled(true);
      _database.setPersistenceCacheSizeBytes(10000000);
    }
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout logger',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple)
              .copyWith(secondary: Colors.deepPurple[300]),
          textTheme: const TextTheme(
            titleLarge: TextStyle(fontSize: 24.0),
            bodyLarge: TextStyle(fontSize: 20.0),
            bodyMedium: TextStyle(fontSize: 18.0),
            labelLarge: TextStyle(fontSize: 16.0, letterSpacing: 0.25),
          )).copyWith(
        dividerColor: Colors.deepPurple[200],
      ),
      // Show the app once firebase has finished initializing
      home: FutureBuilder(
          future: _fbApp,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              // ignore: avoid_print
              print('You have an error! ${snapshot.error.toString()}');
              return const Text('Something went wrong');
            } else if (snapshot.hasData) {
              setPersistence();
              return !_initialized
                  ? const Center(child: CircularProgressIndicator())
                  : const HomePage();
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
