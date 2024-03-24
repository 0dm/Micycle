import 'package:flutter/material.dart';

import 'account_details_page.dart';
import 'settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () {
                // Navigate to the Account Details page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountDetailsPage()),
                );
              },
              child: const Text('Account Details'),
            ),
            const Divider(),
            TextButton(
              onPressed: () {
                // Add your Settings logic here
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
              child: const Text('Settings'),
            ),
            const Divider(),
            ElevatedButton(
              onPressed: () {
                // Add your Delete Account logic here
              },
              child: const Text('Delete Account'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Button color
                foregroundColor: Colors.white, // Text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
