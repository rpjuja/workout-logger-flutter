import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workout_logger_app/styles.dart';

import 'auth_service.dart';

class ConfirmSensitiveAction extends StatefulWidget {
  final Function() action;
  const ConfirmSensitiveAction({
    Key? key,
    required this.user,
    required this.action,
  }) : super(key: key);

  final User user;

  @override
  State createState() => _ConfirmSensitiveActionState();
}

class _ConfirmSensitiveActionState extends State<ConfirmSensitiveAction> {
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
          child: Text("Reauthenticate to confirm action", style: TextStyle(fontSize: 20))),
      content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
                labelText: 'Password', errorMaxLines: 2, contentPadding: EdgeInsets.only(left: 10)),
          )),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancel")),
        ElevatedButton(
            style: ButtonStyles.shadowPadding,
            onPressed: () => {
                  if (_formKey.currentState!.validate())
                    AuthService()
                        .reauthenticate(context, _passwordController.text)
                        .then((value) => {
                              if (value) {widget.action().then(Navigator.of(context).pop(true))}
                            })
                },
            child: const Text("Confirm")),
      ],
    );
  }
}
