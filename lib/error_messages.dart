import 'package:firebase_auth/firebase_auth.dart';

// Check authentication error code and return an appropriate message for user
String getAuthErrorMessage(FirebaseException error) {
  switch (error.code) {
    case 'invalid-email':
      return 'Invalid email';
    // Print invalid email or password for security reasons
    case 'user-not-found':
      return 'Invalid email or password';
    case 'wrong-password':
      return 'Invalid email or password';
    case 'email-already-in-use':
      return 'Email already in use';
    case 'weak-password':
      return 'Password is too weak';
    default:
      return 'An error occurred';
  }
}
