import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:workout_logger_app/firebase_options.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:workout_logger_app/workout_widgets/exercise_list.dart';

void main() {
  late MockFirebaseDatabase mockDatabase;
  late DatabaseReference databaseReference;
  setupFirebaseMocks();

  // Create test data
  const dummyData = {
    'name': 'Bench Press',
    'sets': "3",
    'reps': "10",
    'weight': "100",
  };
  group('ExerciseList', () {
    String userId = "0";
    String date = DateFormat("dd,MM,yyyy").format(DateTime(2021, 9, 1));

    // Set up firebase before tests
    setUpAll(() async {
      Firebase.initializeApp(
          name: "workout-logger-app",
          options: DefaultFirebaseOptions.currentPlatform);
      mockDatabase = MockFirebaseDatabase();
      databaseReference = mockDatabase.ref("/exercises/");
    });

    testWidgets('Show the correct exercise', (WidgetTester tester) async {
      // Set test data to mock database.
      await databaseReference.child("$userId/$date/").push().set(dummyData);

      // Build app inside MaterialApp and a Column to avoid errors when running tests
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: [
            ExerciseList(
                testDatabaseReference: databaseReference,
                userId: "0",
                selectedDate: DateTime(2021, 9, 1))
          ]),
        ),
      ));

      // Let the snapshots stream fire a snapshot.
      await tester.idle();
      // Re-render.
      await tester.pump();

      // Verify that an exercise has been added
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
    }

        // testWidgets('Add a new exercise', (WidgetTester tester) async {}

        // testWidgets('Show the correct notes', (WidgetTester tester) async {}

        // testWidgets('Add notes', (WidgetTester tester) async {

        // // Edit the notes text field and save
        // await tester.enterText(
        //     find.byKey(const Key('notes_text_field')), 'Good workout');
        // await tester.tap(find.byKey(const Key("notes_text_field")));
        // await tester.pump();

        // // Verify that the notes have been saved
        // expect(find.text('Good workout'), findsOneWidget);
        //}
        );
  });
}
