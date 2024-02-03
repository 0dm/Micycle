import 'package:flutter/material.dart';
import 'login_page.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(), // Set the login page as the home page
      // Define routes to navigate to different pages
      routes: {
        '/login': (context) => LoginPage(),
        // Additional routes can be defined here
      },
    );
  }
}
