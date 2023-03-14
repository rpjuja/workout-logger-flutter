import 'package:flutter/material.dart';

import 'auth_widgets/auth_service.dart';

class TopBar extends StatelessWidget with PreferredSizeWidget {
  const TopBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 10,
      shadowColor: Colors.deepPurple[300],
      title: const Text("Workout Tracker"),
      actions: [
        // Show profile button if not on profile page
        ModalRoute.of(context)?.settings.name != '/profile'
            ? IconButton(
                iconSize: 30,
                onPressed: () => Navigator.pushNamed(context, '/profile'),
                icon: const Icon(Icons.person))
            : const SizedBox.shrink(),
        const SizedBox(
          width: 10,
        ),
        // Show logout button if on profile page
        ModalRoute.of(context)?.settings.name == '/profile'
            ? IconButton(
                iconSize: 30,
                icon: const Icon(Icons.logout),
                onPressed: () => AuthService().signOut(context),
              )
            : const SizedBox.shrink(),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }
}
