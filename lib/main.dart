import 'package:Micycle/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import 'home.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider.instance,
      child: Main(),
    )
  );
  initDatabase();
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
      title: 'Micycle Login',
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: Home(),
      routes: {
        '/login': (context) => LoginPage(),
        // Define additional routes as needed
      },
    );
  }
}
