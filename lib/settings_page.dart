import 'dart:convert';

import 'package:Micycle/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'home.dart';

const String loginPageRoute = '/login';



class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _fontSize = 14; // Initial value for the font size slider
  bool _darkTheme = false; // Initial value for the switch

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings',
                  style: TextStyle(
                    fontSize: themeProvider.fontSize,
                    color: themeProvider.themeData.colorScheme.secondary,
                  ),),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text('Change Username',
                  style: TextStyle(
                    fontSize: themeProvider.fontSize,
                    color: themeProvider.themeData.colorScheme.secondary,
                  ),),
            trailing: const Icon(Icons.chevron_right),
            onTap: _changeUsername, // Pass context here
          ),
          ListTile(
            title: Text('Change Email',
                  style: TextStyle(
                    fontSize: themeProvider.fontSize,
                    color: themeProvider.themeData.colorScheme.secondary,
                  ),),
            trailing: const Icon(Icons.chevron_right),
            onTap: _changeEmail,
          ),
          ListTile(
            title:Text('Change Password',
                  style: TextStyle(
                    fontSize: themeProvider.fontSize,
                    color: themeProvider.themeData.colorScheme.secondary,
                  ),),
            trailing: const Icon(Icons.chevron_right),
            onTap: _changePassword,
          ),
          ListTile(
            title: Text('Font Size',
                  style: TextStyle(
                    fontSize: themeProvider.fontSize,
                    color: themeProvider.themeData.colorScheme.secondary,
                  ),),
            trailing: SizedBox(
              width: 200,
              child: Slider(
                    value: themeProvider.fontSize,
                    min: 10,
                    max: 30,
                    activeColor: themeProvider.themeData.colorScheme.primary,
                    inactiveColor: themeProvider.themeData.colorScheme.secondary,
                    divisions: 4,
                    label: themeProvider.fontSize.toString(),
                    onChanged: (double value) {
                      setState(() {
                        themeProvider.fontSize = value;
                      });
                },
              ),
            ),
          ),
          ListTile(
            title: Text('Color Theme',
                  style: TextStyle(
                    fontSize: themeProvider.fontSize,
                    color: themeProvider.themeData.colorScheme.secondary,
                  ),),
            trailing: Switch(
                  value: _darkTheme,
                  activeColor: themeProvider.themeData.colorScheme.primary,
                  inactiveThumbColor: themeProvider.themeData.colorScheme.secondary,
                  onChanged: (bool value) {
                    setState(() {
                      _darkTheme = value;
                      themeProvider.toggleTheme();
                    });
              },
            ),
          ),
        ],
      ),
    );
  }
  void _changeEmail() async {
    final currentPassword = await _showPasswordDialog();
    if (currentPassword == null) return;

    // Ensure Home.email is not null or handle accordingly before proceeding
    if (Home.email == null) {
      _showErrorDialog("Email is not available. Please log in again.");
      return;
    }

    final passwordCorrect = await _verifyPassword(currentPassword, Home.email); // Pass the email here
    if (!passwordCorrect) {
      _showErrorDialog("Password incorrect. Please try again.");
      return;
    }

    final newEmail = await _showEmailDialog();
    if (newEmail == null) return;

    // You may want to pass user ID or use another method to identify which user's email to update
    final updateSuccess = await _updateEmail(newEmail);
    if (!updateSuccess) {
      _showErrorDialog("Failed to update email. Please try again later.");
      return;
    }

    Navigator.of(context).pushReplacementNamed(loginPageRoute);
  }

  Future<String?> _showPasswordDialog() async {
    String? password;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verify Your Password'),
          content: TextField(
            onChanged: (value) {
              password = value;
            },
            decoration: const InputDecoration(hintText: "Password"),
            obscureText: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context, password),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _verifyPassword(String password, String email) async {
    var url = Uri.parse('http://localhost:5000/verify_password');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"password": password, "email": email}), // Include the email in the request
    );
    print("Verify Password Response: ${response.body}"); // Debug response
    return response.statusCode == 200;
  }



  Future<String?> _showEmailDialog() async {
    String? email;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter New Email'),
          content: TextField(
            onChanged: (value) {
              email = value;
            },
            decoration: const InputDecoration(hintText: "New Email"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context, email),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _updateEmail(String newEmail) async {
    var url = Uri.parse('http://localhost:5000/update_email');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "current_email": Home.email, // Assuming Home.email is the current email
        "new_email": newEmail
      }),
    );
    return response.statusCode == 200;
  }

    Future<bool> _updatePassword(String newPassword) async {
    var url = Uri.parse('http://localhost:5000/update_password');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "email": Home.email, // Assuming Home.email is the current email
        "new_password": newPassword,
      }),
    );
    return response.statusCode == 200;
  }

  // Part of your SettingsPage or wherever you manage user settings
  Future<void> _changeUsername() async {
    String? newUsername = await _showUsernameDialog();
    if (newUsername != null && newUsername.isNotEmpty) {
      bool updateSuccess = await _updateUsername(newUsername);
      if (updateSuccess) {
        // Here, you might want to update the local user data
        // Assuming Home.displayName is where you store the username
        setState(() {
          Home.displayName = newUsername;
        });
        // Optionally, re-fetch user details or re-navigate to ensure the app's state is refreshed
        // For simplicity, this example does not include those steps
      } else {
        _showErrorDialog("Failed to update username. Please try again later.");
      }
    }
  }

  Future<String?> _showUsernameDialog() async {
    String? newUsername;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Username'),
          content: TextField(
            onChanged: (value) {
              newUsername = value;
            },
            decoration: const InputDecoration(hintText: "New Username"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context, newUsername),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _updateUsername(String newUsername) async {
    var url = Uri.parse('http://localhost:5000/update_username');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "email": Home.email, // Assuming Home.email stores the user's email
        "new_username": newUsername,
      }),
    );

    return response.statusCode == 200;
  }

  Future<String?> _showNewPasswordDialog() async {
    String? newPassword;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter New Password'),
          content: TextField(
            onChanged: (value) => newPassword = value,
            decoration: const InputDecoration(hintText: "New Password"),
            obscureText: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context, newPassword),
            ),
          ],
        );
      },
    );
  }

  void _changePassword() async {
    final currentPassword = await _showPasswordDialog();
    if (currentPassword == null || currentPassword.isEmpty) return;

    final passwordCorrect = await _verifyPassword(currentPassword, Home.email);
    if (!passwordCorrect) {
      _showErrorDialog("Password incorrect. Please try again.");
      return;
    }

    final newPassword = await _showNewPasswordDialog();
    if (newPassword == null || newPassword.isEmpty) return;

    final updateSuccess = await _updatePassword(newPassword);
    if (updateSuccess) {
      _showSuccessDialog("Password updated successfully. Please log in again.");
      // Assuming you have a method to log out
      _logOut();
    } else {
      _showErrorDialog("Failed to update password. Please try again later.");
    }
  }

  
  void _logOut() {
    // Log out the user and navigate to the login page
    Navigator.of(context).pushReplacementNamed(loginPageRoute);
  }

  void _showSuccessDialog(String message) {
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
                Navigator.pop(context); // Close the dialog
                _logOut(); // Proceed to log out
              },
            ),
          ],
        );
      },
    );
  }


  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}