import 'package:flutter/material.dart';

import 'home.dart';

class AccountDetailsPage extends StatelessWidget {
  const AccountDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('Email'),
              subtitle: Text(Home.userEmail ?? 'N/A'), // Accessing static variable
            ),
            ListTile(
              title: Text('Display Name'),
              subtitle: Text(Home.displayName ?? 'N/A'), // Accessing static variable
            ),
          ],
        ),
      ),
    );
  }
}

