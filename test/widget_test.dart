import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_logger_app/firebase_options.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:workout_logger_app/workout_widgets/exercise_list.dart';
// import 'package:workout_logger_app/workout_widgets/workout_notes.dart';

void main() {
  late DatabaseReference databaseReference;
  setupFirebaseMocks();

  // Create test data
  const dummyData = {
    'name': 'Bench Press',
    'sets': [
      {
        'reps': '10',
        'weight': '100',
      },
      {
        'reps': '10',
        'weight': '97.5',
      },
      {
        'reps': '8',
        'weight': '97.5',
      }
    ],
  };
  String userId = "0";
  DateTime date = DateTime(2021, 9, 1);
  final dateString = date.toString().split(" ")[0];
  String year = dateString.split("-")[0],
      month = dateString.split("-")[1],
      day = dateString.split("-")[2];
  String exerciseId = "0";

  // A helper function to create a MaterialApp to wrap the tested widget.
  Widget buildTestableWidget(Widget widget) {
    return MaterialApp(
      home: Scaffold(
        body: widget,
      ),
    );
  }

  // Set up firebase before tests
  setUpAll(() async {
    Firebase.initializeApp(
        name: "workout-logger-app", options: DefaultFirebaseOptions.currentPlatform);
  });

  group('Exercise widgets:', () {
    setUpAll(() async {
      databaseReference = MockFirebaseDatabase.instance.ref("exercises");

      // Set test data to the mock database.
      await databaseReference.child("$userId/$year/$month/$day/$exerciseId").set(dummyData);
    });

    testWidgets('Show the correct exercise', (WidgetTester tester) async {
      // Build widget inside a Column to avoid errors when running tests
      await tester.pumpWidget(buildTestableWidget(
        Column(children: [
          ExerciseList(testDatabaseReference: databaseReference, userId: userId, selectedDate: date)
        ]),
      ));

      // Let the snapshots stream fire a snapshot.
      await tester.idle();
      // Re-render.
      await tester.pump();

      // Verify that an exercise has been added
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('8-10'), findsOneWidget);
      expect(find.text('97.5-100'), findsOneWidget);
    });

    testWidgets("Delete the exercise", (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        Column(children: [
          ExerciseList(testDatabaseReference: databaseReference, userId: userId, selectedDate: date)
        ]),
      ));

      await tester.idle();
      await tester.pump();

      // Swipe card to delete and advance frames until complete
      await tester.drag(find.byType(Card), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Verify that the delete dialog is shown and confirm deletion
      expect(find.widgetWithText(AlertDialog, 'Confirm'), findsOneWidget);
      expect(find.widgetWithText(AlertDialog, 'Are you sure you wish to delete Bench Press?'),
          findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify that the dialog is closed and exercise has been deleted
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(Card), findsNothing);
      expect(find.text('Bench Press'), findsNothing);
    });

    testWidgets('Show the add exercise dialog and validator error messages',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(Column(children: [
        ExerciseList(
          testDatabaseReference: databaseReference,
          userId: userId,
          selectedDate: date,
        )
      ])));

      await tester.idle();
      await tester.pump();

      // Tap the add exercise button
      await tester.tap(find.byKey(const Key("addExerciseButton")));
      await tester.pump();

      // Verify that the add exercise dialog is shown
      expect(find.widgetWithText(AlertDialog, 'Add exercise'), findsOneWidget);
      expect(find.byKey(const Key('exerciseNameField')), findsOneWidget);
      expect(find.byKey(const Key('exerciseSetsDropdown')), findsOneWidget);
      expect(find.byKey(const Key('exerciseRepsField0')), findsOneWidget);
      expect(find.byKey(const Key('exerciseWeightField0')), findsOneWidget);
      expect(find.byKey(const Key('confirmButton')), findsOneWidget);
      expect(find.byKey(const Key('cancelButton')), findsOneWidget);

      // Tap the add button with no inputs and verify that the validator error messages are shown
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pump();
      expect(find.text('Please enter a name'), findsOneWidget);
      expect(find.text('Please enter a number'), findsNWidgets(2));

      // Tap the cancel button and verify that the dialog is closed
      await tester.tap(find.byKey(const Key('cancelButton')));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AlertDialog, 'Add Exercise'), findsNothing);
    });

    testWidgets('Add a new exercise', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        Column(children: [
          ExerciseList(testDatabaseReference: databaseReference, userId: userId, selectedDate: date)
        ]),
      ));

      await tester.idle();
      await tester.pump();

      // Tap the add exercise button
      await tester.tap(find.byKey(const Key("addExerciseButton")));
      await tester.pump();

      // Edit the exercise information and add the exercise
      expect(find.widgetWithText(AlertDialog, 'Add exercise'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('exerciseNameField')), 'Squat');
      await tester.tap(find.byKey(const Key('exerciseSetsDropdown')));
      await tester.pump();
      await tester.tap(find.text('2').last);
      await tester.enterText(find.byKey(const Key('exerciseRepsField0')), '5');
      await tester.enterText(find.byKey(const Key('exerciseWeightField0')), '200');
      await tester.enterText(find.byKey(const Key('exerciseRepsField1')), '5');
      await tester.enterText(find.byKey(const Key('exerciseWeightField1')), '195');
      await tester.tap(find.byKey(const Key("confirmButton")));
      await tester.pumpAndSettle();

      // Verify that the dialog is closed and the exercise has been added to the UI
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(Card), findsNWidgets(2));
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Squat'), findsOneWidget);
      expect(find.text('5'), findsNWidgets(2));
      expect(find.text('195-200'), findsOneWidget);
    });
  });

  // group("Workout notes:", () {
  //   setUpAll(() async {
  //     databaseReference = MockFirebaseDatabase.instance.ref("workouts");

  //     await databaseReference.child("$userId/$dateString").set({
  //       'notes': 'Good workout',
  //     });
  //   });

  //   testWidgets('Show the correct notes', (WidgetTester tester) async {
  //     await tester.pumpWidget(buildTestableWidget(WorkoutNotes(
  //         databaseReference: databaseReference,
  //         userId: userId,
  //         selectedDate: date)));

  //     await tester.idle();
  //     await tester.pump();

  //     // Verify that the notes, text field and save button are shown
  //     expect(find.text('Good workout'), findsOneWidget);
  //     expect(find.byKey(const Key('notesTextField')), findsOneWidget);
  //     expect(find.text('Notes'), findsOneWidget);
  //     expect(find.byIcon(Icons.save_alt), findsOneWidget);
  //   });

  //   testWidgets('Add notes', (WidgetTester tester) async {
  //     // Empty the database before adding a new exercise
  //     await databaseReference.child("$userId/$dateString").remove();

  //     await tester.pumpWidget(buildTestableWidget(WorkoutNotes(
  //         databaseReference: databaseReference,
  //         userId: userId,
  //         selectedDate: date)));

  //     await tester.idle();
  //     await tester.pump();

  //     expect(find.text('Add notes'), findsOneWidget);

  //     // Edit the notes text field and save
  //     await tester.enterText(
  //         find.byKey(const Key('notesTextField')), 'Great workout');
  //     await tester.tap(find.byIcon(Icons.save_alt));
  //     await tester.pump();

  //     // Verify that the notes have been saved
  //     expect(find.text('Great workout'), findsOneWidget);
  //   });
  // });
}
