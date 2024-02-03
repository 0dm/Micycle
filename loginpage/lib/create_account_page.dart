import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _adminCodeController = TextEditingController();
  bool _isAdmin = false;

  Future<void> createAccount() async {
    var url = 'http://127.0.0.1:5000/create_account'; // Change to your actual server address
    var response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'email': _emailController.text,
        'password': _passwordController.text,
        'displayName': _displayNameController.text,
        'isAdmin': _isAdmin,
        'adminCode': _isAdmin ? _adminCodeController.text : null,
      }),
    );

    if (response.statusCode == 201) {
      print('Account created successfully');
      // Handle successful account creation here
      // For example, navigate back to the login page or show a success message
    } else {
      print('Failed to create account');
      // Handle error here
      // For example, show an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
      ),
      body: Center(
        child: SingleChildScrollView( // Added to enable scrolling when the keyboard is visible
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                ),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                ),
              ),
              TextField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  hintText: 'Display Name',
                ),
              ),
              SwitchListTile(
                title: Text('Admin Account'),
                value: _isAdmin,
                onChanged: (bool value) {
                  setState(() {
                    _isAdmin = value;
                  });
                },
              ),
              if (_isAdmin) TextField(
                controller: _adminCodeController,
                decoration: InputDecoration(
                  hintText: 'Admin Code',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  createAccount(); // Call the create account function when the button is pressed
                },
                child: Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _adminCodeController.dispose();
    super.dispose();
  }
}