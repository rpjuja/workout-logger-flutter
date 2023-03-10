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
            print('User is signed in!');
            return const HomePage();
          } else {
            print('User is currently signed out!');
            return const AuthPage();
          }
        });
  }

  signUp(BuildContext context, String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getAuthErrorMessage(e)),
        ),
      );
    }
  }

  signIn(BuildContext context, String email, String password) async {
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

  signInWithGoogle(BuildContext context) async {
    if (!kIsWeb) {
      // Mobile version of Google sign in
      try {
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
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getGoogleAuthErrorMessage(e)),
          ),
        );
      }
    } else {
      // Web version of Google sign in for development purposes
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      try {
        final UserCredential userCredential =
            await _auth.signInWithPopup(authProvider);
      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getGoogleAuthErrorMessage(e)),
          ),
        );
      }
    }
  }

  resetPassword(BuildContext context, String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset email sent"),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getAuthErrorMessage(e)),
        ),
      );
    }
  }

  signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getAuthErrorMessage(e)),
        ),
      );
    }
  }
}
