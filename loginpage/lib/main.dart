import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
  initDatabase();
}

Future<void> initDatabase() async {
  // Optionally call a Flask endpoint to initialize the database if needed.
  // This example assumes you've handled initialization directly in app.py as shown above.
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      routes: {
        '/login': (context) => LoginPage(),
        // Define additional routes as needed
      },
    );
  }
}
