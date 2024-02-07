import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'login_page.dart';

void main() {
  runApp(Main());
  initDatabase();
}

Future<void> initDatabase() async {
  // Optionally call a Flask endpoint to initialize the database if needed.
  // This example assumes you've handled initialization directly in app.py as shown above.
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Micycle Login',
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
