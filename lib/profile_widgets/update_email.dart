import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth_widgets/confirm_sensitive_action.dart';
import '../error_messages.dart';

class UpdateEmail extends StatefulWidget {
  final Function() stopEditingEmail;
  final Function() getUserData;

  const UpdateEmail({
    Key? key,
    required this.stopEditingEmail,
    required this.getUserData,
    required this.user,
  }) : super(key: key);

  final User user;

  @override
  State createState() => _UpdateEmailState();
}

class _UpdateEmailState extends State<UpdateEmail> {
  late final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.user.email!;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateEmail() async {
    try {
      await widget.user.updateEmail(_emailController.text);
      widget.stopEditingEmail();
      widget.getUserData().then((value) => ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Email updated"))));
    } on FirebaseAuthException catch (e) {
      // If the user's credential is too old, they need to reauthenticate.
      if (e.code == 'requires-recent-login') {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return ConfirmSensitiveAction(
                user: widget.user,
                action: _updateEmail,
              );
            });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(getAuthErrorMessage(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: TextFormField(
          controller: _emailController,
          validator: (value) {
            if (!EmailValidator.validate(value!)) {
              return 'Please enter a valid email';
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: "Email",
            contentPadding: const EdgeInsets.only(left: 10),
            alignLabelWithHint: true,
            prefixIcon: IconButton(
              icon: const Icon(Icons.arrow_back),
              hoverColor: Colors.transparent,
              onPressed: () {
                widget.stopEditingEmail();
              },
            ),
            suffixIcon: IconButton(
                icon: const Icon(Icons.check),
                hoverColor: Colors.transparent,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateEmail();
                  }
                }),
          ),
        ),
      ),
    );
  }
}
