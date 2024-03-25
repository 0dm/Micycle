import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'account_details_page.dart';
import 'home.dart';
import 'settings_page.dart';

const String loginPageRoute = '/login';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
              onPressed: () => _showDeleteConfirmation(context),
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

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _showPasswordForDeletion(context); // Proceed to ask for password
              },
            ),
          ],
        );
      },
    );
  }

  void _showPasswordForDeletion(BuildContext context) {
    TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verify Password'),
          content: TextField(
            controller: passwordController,
            decoration: const InputDecoration(hintText: "Enter your password"),
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
              child: const Text('Confirm'),
              onPressed: () async {
                print("Password entered for deletion: ${passwordController.text}");
                Navigator.of(context).pop(); // Close the dialog
                bool passwordCorrect = await _verifyPassword(passwordController.text);
                if (passwordCorrect) {
                  _deleteAccount(context);
                } else {
                  _showErrorDialog(context, "Password incorrect. Please try again.");
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount(BuildContext context) async {
    var url = Uri.parse('http://localhost:5000/delete_account');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "email": Home.userEmail, // Assuming Home.userEmail stores the user's email
      }),
    );

    if (response.statusCode == 200) {
      _showSuccessDialog(context, "Account deleted successfully. Please log in again.");
    } else {
      // Log error or show a dialog/message to the user
      _showErrorDialog(context, "Failed to delete account. Please try again later.");
    }
  }

  Future<bool> _verifyPassword(String password) async {
    var url = Uri.parse('http://localhost:5000/verify_password');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"password": password, "email": Home.userEmail}), // Include the email in the request
    );
    print("Verify Password Response: ${response.body}"); // Debug response
    return response.statusCode == 200;
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the success dialog
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed(loginPageRoute);
                }// Redirect to login
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(), // Close the error dialog
            ),
          ],
        );
      },
    );
  }
}
