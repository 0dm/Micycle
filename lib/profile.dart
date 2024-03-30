import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'account_details_page.dart';
import 'home.dart';
import 'main.dart';
import 'settings_page.dart';
import 'theme/theme.dart';
import 'theme/theme_provider.dart';

const String loginPageRoute = '/login';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
              onPressed: _showDeleteConfirmationDialog,
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

  // Function to show a dialog and confirm account deletion
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _showPasswordVerificationDialog(); // Proceed to verify password
              },
            ),
          ],
        );
      },
    );
  }

  // Function to show a dialog for password verification
  void _showPasswordVerificationDialog() {
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verify Password'),
          content: TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
            obscureText: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () async {
                // Attempt to delete the account
                var response = await http.post(
                  Uri.parse('http://localhost:5000/delete_account'),
                  headers: <String, String>{
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode(<String, String>{
                    'email': Home.email, // Replace with actual user email
                    'password': passwordController.text,
                  }),
                );

                if (response.statusCode == 200) {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Main()), // Navigate back to home
                    (Route<dynamic> route) => false,
                  );
                } else {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(jsonDecode(response.body)['error'])),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
