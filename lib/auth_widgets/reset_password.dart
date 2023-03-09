import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

import 'package:workout_logger_app/styles.dart';
import 'package:workout_logger_app/error_messages.dart';

class ResetPassword extends StatefulWidget {
  final Function() returnToLogin;
  const ResetPassword(
      {Key? key, required this.returnToLogin, required this.email})
      : super(key: key);

  final String email;

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  late final FirebaseAuth _auth;
  FirebaseException? _error;

  late final TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();
  bool _resetEmailSent = false;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      setState(() {
        _resetEmailSent = true;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(left: 30),
            height: MediaQuery.of(context).size.height * 0.1,
            child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  widget.returnToLogin();
                }),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            child: const Text(
              'Reset password',
              style: TextStyle(fontSize: 26.0),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            child: const Text(
                'Enter your email and we will send you a password reset link'),
          ),
          Form(
            key: _formKey,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              margin: const EdgeInsets.only(bottom: 30),
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  contentPadding: EdgeInsets.only(left: 10),
                ),
                validator: (value) {
                  if (!EmailValidator.validate(value!)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ),
          ),
          _error != null
              ? Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  child: Text(getAuthErrorMessage(_error!),
                      style: const TextStyle(color: Colors.red, fontSize: 16)))
              : const SizedBox.shrink(),
          _resetEmailSent
              ? Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  child: const Text(
                    'Password reset email sent',
                    style: TextStyle(color: Colors.green, fontSize: 16),
                  ))
              : const SizedBox.shrink(),
          ElevatedButton(
            style: ButtonStyles.shadowPadding,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _resetPassword();
              }
            },
            child: const Text('Send password reset email'),
          ),
        ],
      ),
    );
  }
}
