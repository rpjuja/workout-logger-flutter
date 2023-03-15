import 'package:firebase_auth/firebase_auth.dart';

// Check authentication error code and return an appropriate message for user
String getAuthErrorMessage(FirebaseAuthException error) {
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
    case 'requires-recent-login':
      return 'Please reauthenticate';
    case 'invalid-credential':
      return 'Invalid credentials';
    default:
      return 'An error occurred';
  }
}

String getGoogleAuthErrorMessage(FirebaseAuthException error) {
  switch (error.code) {
    case 'account-exists-with-different-credential':
      return 'Account exists with different credential';
    case 'invalid-credential':
      return 'Invalid credential';
    case 'operation-not-allowed':
      return 'Operation not allowed';
    case 'user-disabled':
      return 'User disabled';
    case 'user-not-found':
      return 'Invalid email or password';
    case 'wrong-password':
      return 'Invalid email or password';
    case 'invalid-verification-code':
      return 'Invalid verification code';
    case 'invalid-verification-id':
      return 'Invalid verification id';
    default:
      return 'An error occurred';
  }
}
