import 'package:flutter/material.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _adminCodeController = TextEditingController();
  bool _isAdmin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                hintText: 'Email',
              ),
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
              ),
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Display Name',
              ),
            ),
            SwitchListTile(
              title: Text('Admin Account'),
              value: _isAdmin,
              onChanged: (bool value) {
                setState(() {
                  _isAdmin = value;
                });
              },
            ),
            if (_isAdmin) TextField(
              controller: _adminCodeController,
              decoration: InputDecoration(
                hintText: 'Admin Code',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Add logic for account creation
              },
              child: Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _adminCodeController.dispose();
    super.dispose();
  }
}
