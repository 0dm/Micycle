import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'account_details_page.dart';
import 'settings_page.dart';
import 'theme/theme_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
                  fontSize: themeProvider.fontSize,
                  color: themeProvider.themeData.colorScheme.primary,
                ),
        ),
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
              child: Text(
                'Account Details',
                style: TextStyle(
                  fontSize: themeProvider.fontSize,
                  color: themeProvider.themeData.colorScheme.secondary,
                ),
              ),
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
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: themeProvider.fontSize,
                  color: themeProvider.themeData.colorScheme.secondary,
                ),
              ),
            ),
            const Divider(),
            ElevatedButton(
              onPressed: () {
                // Add your Delete Account logic here
              },
              child: Text(
                'Delete Account',
                style: TextStyle(
                  fontSize: themeProvider.fontSize,
                  color: themeProvider.themeData.colorScheme.secondary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Button color
                // Use themeProvider.themeData.colorScheme.secondary for text color
                foregroundColor: Colors.white, // Text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
