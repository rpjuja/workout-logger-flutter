import 'package:firebase_auth/firebase_auth.dart';

String getErrorMessage(FirebaseException error) {
  // list out all the possible errors from realtime database
  switch (error.code) {
    case 'permission-denied':
      return 'Permission denied';
    case 'database-error':
      return 'Database error';
    case 'disconnected':
      return 'Disconnected';
    case 'expired-token':
      return 'Session expired';
    case 'invalid-token':
      return 'Invalid token';
    case 'network-error':
      return 'Network error';
    case 'operation-failed':
      return 'Operation failed';
    case 'overridden-by-set':
      return 'Overridden by subsequent set';
    case 'Unavailable':
      return 'Unavailable';
    case 'unknown-error':
      return 'Unknown error';
    case 'user-code-exception':
      return 'User code exception';
    case 'write-canceled':
      return 'Write canceled';
    default:
      return 'An error occurred';
  }
}

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
    case 'account-exists-with-different-credential':
      return 'Account exists with different credentials';
    case 'user-disabled':
      return 'User disabled';
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
    case 'missing-verification-code':
      return 'Missing verification code';
    case 'missing-verification-id':
      return 'Missing verification id';
    case 'session-expired':
      return 'Session expired';
    case 'quota-exceeded':
      return 'Quota exceeded';
    default:
      return 'An error occurred';
  }
}
