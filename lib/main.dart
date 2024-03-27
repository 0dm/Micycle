import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart'; // Import flutter_stripe

import 'login_page.dart';
import 'home.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    // Mobile-specific initialization
    Stripe.publishableKey = "pk_test_51OkvTNGUL4Iok28JlEJg9nU5wYZqyLCicm5ZyNcRAZ90DjgmqxYTtdKqBqa1o5oQW53WVKkDWvLZtP3UPkv2H5zc00Od695BDj";
  }
  runApp(Main());
}
Future<void> initDatabase() async {
  // Optionally call a Flask endpoint to initialize the database if needed.
  // This example assumes you've handled initialization directly in app.py as shown above.
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'My Application',
        theme: ThemeData(
          primaryColor: Color(0xFF96B5D4),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: Color.fromARGB(255, 255, 95, 9), // Used to be 'accentColor'
            background: Color.fromARGB(255, 34, 156, 255),
          ),          
          buttonTheme: ButtonThemeData(
            buttonColor: Color(0xFF00EFB2),
          ),
          textTheme: TextTheme(
            labelLarge: TextStyle(color: Color(0xFFF83748)), // Text color for ElevatedButton
            bodyMedium: TextStyle(color: Colors.black),
          ),
          // Other customizations...
        ),
        home: LoginPage(),
        // Other routes...
      );
    }
  }