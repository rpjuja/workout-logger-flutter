import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workout_logger_app/auth_widgets/auth_service.dart';
import 'package:workout_logger_app/styles.dart';

import '../auth_widgets/confirm_sensitive_action.dart';
import '../error_messages.dart';

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({
    Key? key,
    required this.user,
  }) : super(key: key);

  final User user;

  @override
  State createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  void _deleteAccount() async {
    try {
      await widget.user
          .delete()
          .then(((value) => Navigator.of(context).pop(true)));
    } on FirebaseAuthException catch (e) {
      // If the user's credential is too old, they need to reauthenticate.
      if (e.code == 'requires-recent-login' &&
          widget.user.providerData[0].providerId == 'password') {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return ConfirmSensitiveAction(
                user: widget.user,
                action: _deleteAccount,
              );
            });
      } else if (e.code == 'requires-recent-login' &&
          widget.user.providerData[0].providerId == 'google.com') {
        AuthService()
            .reauthenticateGoogleUser(context)
            .then(() => _deleteAccount())
            .then(() => Navigator.of(context).pop(true));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(getAuthErrorMessage(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirm"),
      content: const Text(
          'Are you sure you wish to delete your account? Everything will be lost.'),
      actions: <Widget>[
        ElevatedButton(
            style: ButtonStyles.shadowPadding,
            onPressed: () => {
                  _deleteAccount(),
                },
            child: const Text("Delete")),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
