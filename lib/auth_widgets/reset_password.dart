import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

import 'package:workout_logger_app/styles.dart';
import 'auth_service.dart';

class ResetPassword extends StatefulWidget {
  final Function() returnToLogin;
  const ResetPassword({Key? key, required this.returnToLogin, required this.email})
      : super(key: key);

  final String email;

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  late final TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(left: 20),
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
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 30),
            child: const Text(
              'Enter your email and we will send you a password reset link',
              textAlign: TextAlign.center,
            ),
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
          ElevatedButton(
            style: ButtonStyles.shadowPadding,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                AuthService().resetPassword(context, _emailController.text);
              }
            },
            child: const Text('Send password reset email'),
          ),
        ],
      ),
    );
  }
}
