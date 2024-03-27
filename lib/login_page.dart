import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'create_account_page.dart';
import 'home.dart';
import 'theme/theme_provider.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future getDisplayName(String email) async {
    var response = await http.get(
      Uri.parse('http://localhost:5000/get_display_name/$email'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['display_name'];
    } else {
      return null;
    }
  }

  Future<void> login() async {
    var url = 'http://localhost:5000/login';
    var response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      var displayName = json.decode(response.body)['user']['display_name'];
      setState(() {
        Home.userEmail = _emailController.text;
        Home.displayName = displayName;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } else {
      String errorReason = "An unexpected error occurred. Please try again later.";
      if (response.statusCode == 401) {
        errorReason = "Invalid email or password."; // For unauthorized
      } else if (response.statusCode == 404) {
        errorReason = "User not found. Please create an account."; // User not found
      } // Add more conditions as needed

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: Text(errorReason),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Login', style: TextStyle(
          color: themeProvider.themeData.colorScheme.secondary,
          fontSize: themeProvider.fontSize,
        )),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(color: themeProvider.themeData.colorScheme.secondary,fontSize: themeProvider.fontSize),
                    ),
                    validator: (value) {
                      final emailRegex = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      );
                      if (value == null || value.isEmpty || !emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: themeProvider.themeData.colorScheme.secondary,fontSize: themeProvider.fontSize),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6) {
                        return 'Password must be more than 6 characters';
                      }
                      return null;
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      login();
                    }
                  },
                  child: Text('Login', style: TextStyle(
                    color: themeProvider.themeData.colorScheme.primary,
                    fontSize: themeProvider.fontSize,
                  )),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateAccountPage()),
                    );
                  },
                  child: Text('Create Account', style: TextStyle(
                    color: themeProvider.themeData.colorScheme.primary,
                    fontSize: themeProvider.fontSize,
                  )),
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
    super.dispose();
  }
}
