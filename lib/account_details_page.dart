import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'theme/theme_provider.dart';

class AccountDetailsPage extends StatelessWidget {
  const AccountDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    // Dummy data for demonstration purposes
    final String currentUsername = 'JohnDoe';
    final String currentEmail = 'johndoe@example.com';
    final String currentPassword = '••••••••';
    final String paymentInfo = 'Visa **** **** **** 1234';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Account Details',
          style: TextStyle(fontSize: themeProvider.fontSize, color: themeProvider.themeData.colorScheme.primary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView( // Using a ListView in case the content exceeds screen height
          children: <Widget>[
            TextFormField(
              style:TextStyle(fontSize: themeProvider.fontSize, color: themeProvider.themeData.colorScheme.secondary),
              initialValue: currentUsername,
              readOnly: true, // Makes it read-only
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(fontSize: themeProvider.fontSize, color: themeProvider.themeData.colorScheme.secondary),
              ),
            ),
            TextFormField(
              style:TextStyle(fontSize: themeProvider.fontSize, color: themeProvider.themeData.colorScheme.secondary),
              initialValue: currentEmail,
              readOnly: true, // Makes it read-only
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(fontSize: themeProvider.fontSize, color: themeProvider.themeData.colorScheme.secondary),
              ),
            ),
            TextFormField(
              style:TextStyle(fontSize: themeProvider.fontSize, color: themeProvider.themeData.colorScheme.secondary),
              initialValue: currentPassword,
              readOnly: true, // Makes it read-only
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(fontSize: themeProvider.fontSize, color: themeProvider.themeData.colorScheme.secondary),
              ),
            ),
            TextFormField(
              style:TextStyle(fontSize: themeProvider.fontSize, color: themeProvider.themeData.colorScheme.secondary),
              initialValue: paymentInfo,
              readOnly: true, // Makes it read-only
              decoration: InputDecoration(
                labelText: 'Payment Information',
                labelStyle: TextStyle(fontSize: themeProvider.fontSize, color: themeProvider.themeData.colorScheme.secondary),
              ),
            ),
            // Add any other account details here
          ],
        ),
      ),
    );
  }
}
