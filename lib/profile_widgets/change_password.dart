import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workout_logger_app/styles.dart';

import '../auth_widgets/auth_service.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  State createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
          child: Text("Change Password", style: TextStyle(fontSize: 20))),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: TextFormField(
                controller: _oldPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your old password';
                  }
                  return null;
                },
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                    labelText: 'Old password',
                    errorMaxLines: 2,
                    contentPadding: EdgeInsets.only(left: 10)),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: TextFormField(
                controller: _newPasswordController,
                validator: (value) {
                  return value!.length < 6
                      ? 'Password must be at least 6 characters'
                      : null;
                },
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                    labelText: 'New password',
                    errorMaxLines: 2,
                    contentPadding: EdgeInsets.only(left: 10)),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: TextFormField(
                controller: _confirmPasswordController,
                validator: (value) {
                  return value!.length < 6
                      ? 'Password must be at least 6 characters'
                      : value != _newPasswordController.text
                          ? 'Passwords do not match'
                          : null;
                },
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                    labelText: 'Confirm new password',
                    errorMaxLines: 2,
                    contentPadding: EdgeInsets.only(left: 10)),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
            onPressed: () => {
                  if (_formKey.currentState!.validate())
                    AuthService().changePassword(
                        context,
                        _oldPasswordController.text,
                        _newPasswordController.text),
                },
            child: const Text("Confirm")),
      ],
    );
  }
}
