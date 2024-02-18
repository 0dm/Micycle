import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart'; // Import flutter_stripe

import 'login_page.dart';

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
