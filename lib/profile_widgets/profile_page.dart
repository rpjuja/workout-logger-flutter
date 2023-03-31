import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workout_logger_app/error_messages.dart';
import 'package:workout_logger_app/profile_widgets/delete_account.dart';
import 'package:workout_logger_app/profile_widgets/update_email.dart';
import 'package:workout_logger_app/styles.dart';
import 'package:workout_logger_app/top_bar.dart';

import 'change_password.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User _user;
  bool _editingEmail = false;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void _stopEditingEmail() {
    setState(() {
      _editingEmail = false;
    });
  }

  Future<void> _getUserData() async {
    try {
      setState(() {
        _user = FirebaseAuth.instance.currentUser!;
      });
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(getAuthErrorMessage(e))));
    }
  }

  Future<void> _sendVericiationEmail() async {
    try {
      await _user
          .sendEmailVerification()
          .then((value) => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Verification email sent"),
                ),
              ));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(getAuthErrorMessage(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(0, 30, 0, 20),
              child: const Text(
                "Profile",
                style: TextStyle(fontSize: 26),
              ),
            ),
            _editingEmail
                ? UpdateEmail(
                    stopEditingEmail: _stopEditingEmail,
                    getUserData: _getUserData,
                    user: _user)
                : Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.1),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: "Email: ",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: _user.email,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          // Add an edit email button if the user is signed in using email and password
                          _user.providerData[0].providerId == 'password'
                              ? WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(5, 0, 0, 3),
                                    child: IconButton(
                                      icon: const Icon(Icons.edit),
                                      hoverColor: Colors.transparent,
                                      onPressed: () => setState(() {
                                        _editingEmail = true;
                                      }),
                                    ),
                                  ),
                                )
                              : const WidgetSpan(child: SizedBox.shrink()),
                        ],
                      ),
                    ),
                  ),
            const SizedBox(height: 10),
            // Add more space after the email modification field if the email is not verified
            _user.emailVerified == false && _editingEmail
                ? const SizedBox(height: 10)
                : const SizedBox.shrink(),
            _user.emailVerified == false
                ? ElevatedButton(
                    onPressed: () => _sendVericiationEmail(),
                    style: ButtonStyles.shadowPadding,
                    child: const Text("Resend verification email"),
                  )
                : const SizedBox.shrink(),
            _user.providerData[0].providerId == 'google.com'
                ? const Text('Signed in with Google')
                : const SizedBox.shrink(),
            const Spacer(),
            _user.providerData[0].providerId == 'password'
                ? Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    margin: const EdgeInsets.only(bottom: 30),
                    child: ElevatedButton(
                        onPressed: () => {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ChangePassword(user: _user);
                                  })
                            },
                        style: ButtonStyles.shadowPadding,
                        child: const Text('Change password')),
                  )
                : const SizedBox.shrink(),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              margin: const EdgeInsets.only(bottom: 30),
              child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return DeleteAccount(user: _user);
                        });
                  },
                  style: ButtonStyles.shadowPadding,
                  child: const Text('Delete account')),
            ),
          ],
        ),
      ),
    );
  }
}
