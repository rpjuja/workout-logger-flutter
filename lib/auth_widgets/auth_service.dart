import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:workout_logger_app/error_messages.dart';

import '../home_page.dart';
import 'auth_page.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>["email"]);

  // Determine whether the user is logged in or not
  handleAuthState() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            if (kDebugMode) {
              print('User is signed in!');
            }
            return const HomePage();
          } else {
            if (kDebugMode) {
              print('User is currently signed out!');
            }
            return const AuthPage();
          }
        });
  }

  Future<void> signUp(BuildContext context, String email, String password) async {
    try {
      UserCredential user = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await user.user?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getAuthErrorMessage(e)),
        ),
      );
    }
  }

  Future<void> signIn(BuildContext context, String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getAuthErrorMessage(e)),
        ),
      );
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Mobile version of Google sign in
      if (!kIsWeb) {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser != null) {
          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;

          final OAuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          await _auth.signInWithCredential(credential);
        }
      } else {
        // Web version of Google sign in for development purposes
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        await _auth.signInWithPopup(authProvider);
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getGoogleAuthErrorMessage(e)),
        ),
      );
    }
  }

  Future<void> resetPassword(BuildContext context, String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email).then((value) =>
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Password reset email sent"))));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getAuthErrorMessage(e)),
        ),
      );
    }
  }

  Future<void> changePassword(
      BuildContext context, String oldPassword, String newPassword) async {
    try {
      await reauthenticate(context, oldPassword);
      await _auth.currentUser!
          .updatePassword(newPassword)
          .then((value) => Navigator.of(context).pop(true))
          .then((value) => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Password changed successfully"))));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getAuthErrorMessage(e)),
        ),
      );
    }
  }

  Future<void> reauthenticate(BuildContext context, String password) async {
    try {
      final User user = _auth.currentUser!;
      await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: user.email!, password: password));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(getAuthErrorMessage(e))));
    }
  }

  Future<void> reauthenticateGoogleUser(BuildContext context) async {
    try {
      // Mobile version of Google reauthentication
      if (!kIsWeb) {
        final User user = _auth.currentUser!;

        final GoogleSignInAccount? googleUser = await _googleSignIn
            .disconnect()
            .then((value) => _googleSignIn.signIn());
        if (googleUser != null) {
          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;

          final OAuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          await user.reauthenticateWithCredential(credential);
        }
      } else {
        // Web version of Google reauthentication
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        await _auth.currentUser!.reauthenticateWithPopup(authProvider);
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getGoogleAuthErrorMessage(e)),
        ),
      );
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      // Return to home page and sign out
      Navigator.popUntil(context, ModalRoute.withName('/'));
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getAuthErrorMessage(e)),
        ),
      );
    }
  }
}
