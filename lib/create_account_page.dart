import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'env.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>(); // Add GlobalKey for the form
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _adminCodeController = TextEditingController();
  bool _isAdmin = false;

  Future<void> createAccount() async {
    // Check if the Admin option is selected and the admin code is not "admin"
    if (_isAdmin && _adminCodeController.text != 'admin') {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error'),
          content: Text('Invalid admin code. Please try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Dismiss the dialog
              },
              child: Text('Okay'),
            ),
          ],
        ),
      );
      return; // Stop the function from proceeding further
    }
  var url = Env.ACCOUNT_SERVER + '/create_account';
  var response = await http.post(
    Uri.parse(url),
    headers: {"Content-Type": "application/json"},
    body: json.encode({
      'email': _emailController.text,
      'password': _passwordController.text,
      'displayName': _displayNameController.text, // Make sure to add this line
      'isAdmin': _isAdmin, // Assuming you have a boolean value for isAdmin
      'adminCode': _isAdmin ? _adminCodeController.text : '', // Include adminCode conditionally based on isAdmin
    }),
  );

  if (response.statusCode == 200) {
    print('Response body: ${response.body}');
    var responseData = json.decode(response.body);
    var checkoutUrl = responseData['url'];  // Use 'id' instead of 'checkoutSessionId'
    launch(checkoutUrl); // Launch the Stripe Checkout page
  } else if (response.statusCode == 409) {
    // Email already exists
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text('This email address already has an account.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  } if (response.statusCode == 201) {
  // Account created successfully
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Success'),
      content: Text('Account created successfully, please log in.'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            // This assumes you have a named route set up for your login page
            // Replace '/loginPage' with the actual route name for your login page
            Navigator.of(ctx).pop(); // Close the dialog
            Navigator.of(context).pushReplacementNamed('/login');
            },
          child: Text('Login'),
          ),
        ],
      ),
    );
  }
  else {
    // Handle other errors
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text('Failed to create account. Please try again.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }
}


    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            // Wrap Column with a Form widget
            key: _formKey, // Assign the GlobalKey to the Form
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(16),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(hintText: 'Email'),
                      validator: (value) {
                        // Regular expression for validating email
                        final emailRegex = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        );
                        if (value == null ||
                            value.isEmpty ||
                            !emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    )),
                Padding(
                    padding: EdgeInsets.all(16),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(hintText: 'Password'),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length < 6) {
                          return 'Password must be more than 6 characters';
                        }
                        return null;
                      },
                    )),
                Padding(
                    padding: EdgeInsets.all(16),
                    child: TextFormField(
                      controller: _displayNameController,
                      decoration: InputDecoration(hintText: 'Display Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a display name';
                        }
                        return null;
                      },
                    )),
                SwitchListTile(
                  title: Text('Admin Account'),
                  value: _isAdmin,
                  onChanged: (bool value) {
                    setState(() {
                      _isAdmin = value;
                    });
                  },
                ),
                if (_isAdmin)
                  TextFormField(
                    controller: _adminCodeController,
                    decoration: InputDecoration(hintText: 'Admin Code'),
                    // Optional: Add validator if admin code has specific requirements
                  ),
                ElevatedButton(
                  onPressed: () {
                    // Validate form before sending request
                    if (_formKey.currentState!.validate()) {
                      createAccount();
                    }
                  },
                  child: Text('Create Account'),
                ),
              ],
            ),
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