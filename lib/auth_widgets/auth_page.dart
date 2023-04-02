import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

import 'package:workout_logger_app/styles.dart';
import 'package:workout_logger_app/auth_widgets/reset_password.dart';
import 'package:workout_logger_app/custom_icons.dart';
import 'package:workout_logger_app/top_bar.dart';

import 'auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({
    Key? key,
  }) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loginMode = true;
  bool _resetPasswordMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPasswordModeChange() {
    setState(() {
      _resetPasswordMode = !_resetPasswordMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevents keyboard from resizing and overflowing the screen
      appBar: const TopBar(),
      body: Center(
        child: _resetPasswordMode
            ? ResetPassword(returnToLogin: _resetPasswordModeChange, email: _emailController.text)
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(left: 20),
                      height: MediaQuery.of(context).size.height * 0.1,
                      child: !_loginMode
                          ? IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () {
                                setState(() {
                                  _loginMode = !_loginMode;
                                });
                              })
                          : null),
                  Container(
                    margin: const EdgeInsets.only(bottom: 30),
                    child: Text(
                      _loginMode ? 'Log in' : 'Sign up',
                      style: const TextStyle(fontSize: 26.0),
                    ),
                  ),
                  _loginMode
                      ? Container(
                          margin: const EdgeInsets.only(bottom: 30),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Text("Don't have an account?"),
                            const SizedBox(width: 1),
                            TextButton(
                                style: ButtonStyle(
                                    foregroundColor:
                                        MaterialStateProperty.all(Colors.deepPurple[300])),
                                onPressed: () {
                                  setState(() {
                                    _loginMode = !_loginMode;
                                  });
                                },
                                child: const Text('Sign up'))
                          ]))
                      : const SizedBox.shrink(),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          margin: const EdgeInsets.only(bottom: 30),
                          child: TextFormField(
                            controller: _emailController,
                            validator: (value) {
                              if (!EmailValidator.validate(value!)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                                labelText: 'Email',
                                errorMaxLines: 2,
                                contentPadding: EdgeInsets.only(left: 10)),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          // Smaller bottom margin for forgot password button below
                          margin: const EdgeInsets.only(bottom: 0),
                          child: TextFormField(
                            controller: _passwordController,
                            // Validate password on sign up only
                            validator: (value) {
                              return _loginMode
                                  ? null
                                  : value!.length < 6
                                      ? 'Password must be at least 6 characters'
                                      : null;
                            },
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            decoration: const InputDecoration(
                                labelText: 'Password',
                                errorMaxLines: 2,
                                contentPadding: EdgeInsets.only(left: 10)),
                          ),
                        ),
                        !_loginMode
                            ? Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                // Add top margin to separate from other password field
                                margin: const EdgeInsets.fromLTRB(0, 30, 0, 30),
                                child: TextFormField(
                                  controller: _confirmPasswordController,
                                  validator: (value) {
                                    return value!.length < 6
                                        ? 'Password must be at least 6 characters'
                                        : value != _passwordController.text
                                            ? 'Passwords do not match'
                                            : null;
                                  },
                                  obscureText: true,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  decoration: const InputDecoration(
                                      labelText: 'Confirm password',
                                      errorMaxLines: 2,
                                      contentPadding: EdgeInsets.only(left: 10)),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  _loginMode
                      ? Container(
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.fromLTRB(
                              0, 0, MediaQuery.of(context).size.width * 0.2, 20),
                          child: TextButton(
                              style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.deepPurple[300])),
                              onPressed: () {
                                setState(() {
                                  _resetPasswordMode = !_resetPasswordMode;
                                });
                              },
                              child: const Text('Forgot password?')))
                      : const SizedBox.shrink(),
                  Container(
                    child: _loginMode
                        ? Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    AuthService().signIn(
                                        context, _emailController.text, _passwordController.text);
                                  }
                                },
                                style: ButtonStyles.shadowPadding,
                                child: const Text('Log in'),
                              ),
                              const SizedBox(height: 30),
                              // Add a button for 3rd paty authentication with Google
                              ElevatedButton.icon(
                                style: ButtonStyles.shadowPadding.copyWith(
                                    padding: MaterialStateProperty.all(
                                        const EdgeInsets.symmetric(horizontal: 10, vertical: 15))),
                                icon: const Icon(CustomIcons.google_1),
                                label: const Text('Sign in with Google'),
                                onPressed: () => AuthService().signInWithGoogle(context),
                              ),
                            ],
                          )
                        : ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                AuthService().signUp(
                                    context, _emailController.text, _passwordController.text);
                              }
                            },
                            style: ButtonStyles.shadowPadding,
                            child: const Text('Sign up'),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
