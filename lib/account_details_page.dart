import 'package:flutter/material.dart';

class AccountDetailsPage extends StatelessWidget {
  const AccountDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy data for demonstration purposes
    final String currentUsername = 'JohnDoe';
    final String currentEmail = 'johndoe@example.com';
    final String currentPassword = '••••••••';
    final String paymentInfo = 'Visa **** **** **** 1234';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView( // Using a ListView in case the content exceeds screen height
          children: <Widget>[
            TextFormField(
              initialValue: currentUsername,
              readOnly: true, // Makes it read-only
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            TextFormField(
              initialValue: currentEmail,
              readOnly: true, // Makes it read-only
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextFormField(
              initialValue: currentPassword,
              readOnly: true, // Makes it read-only
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            TextFormField(
              initialValue: paymentInfo,
              readOnly: true, // Makes it read-only
              decoration: const InputDecoration(
                labelText: 'Payment Information',
              ),
            ),
            // Add any other account details here
          ],
        ),
      ),
    );
  }
}
