import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _fontSize = 14; // Initial value for the font size slider
  bool _darkTheme = false; // Initial value for the switch

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Change Username'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to Change Username Page or Dialog
            },
          ),
          ListTile(
            title: const Text('Change Email'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to Change Email Page or Dialog
            },
          ),
          ListTile(
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to Change Password Page or Dialog
            },
          ),
          ListTile(
            title: const Text('Font Size'),
            trailing: SizedBox(
              width: 200,
              child: Slider(
                value: _fontSize,
                min: 10,
                max: 24,
                divisions: 14,
                label: _fontSize.round().toString(),
                onChanged: (value) {
                  setState(() {
                    _fontSize = value;
                  });
                },
              ),
            ),
          ),
          ListTile(
            title: const Text('Color Theme'),
            trailing: Switch(
              value: _darkTheme,
              onChanged: (bool value) {
                setState(() {
                  _darkTheme = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
