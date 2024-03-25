import 'package:Micycle/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home.dart';

import 'home.dart';

class AccountDetailsPage extends StatelessWidget {
  const AccountDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Details', style: TextStyle(
          color: themeProvider.themeData.colorScheme.secondary,
        )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('Email', style: TextStyle(
          color: themeProvider.themeData.colorScheme.secondary,
        )),
              subtitle: Text(Home.userEmail ?? 'N/A', style: TextStyle(
          color: themeProvider.themeData.colorScheme.secondary,
        )), // Accessing static variable
            ),
            ListTile(
              title: Text('Display Name', style: TextStyle(
          color: themeProvider.themeData.colorScheme.secondary,
        )),
              subtitle: Text(Home.displayName ?? 'N/A', style: TextStyle(
          color: themeProvider.themeData.colorScheme.secondary,
        )), // Accessing static variable
            ),
          ],
        ),
      ),
    );
  }
}

