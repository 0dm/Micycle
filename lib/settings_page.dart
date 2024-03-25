import 'package:Micycle/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: themeProvider.fontSize,
            color: themeProvider.themeData.colorScheme.primary,
          ),
        ),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                title: Text(
                  'Change Username',
                  style: TextStyle(
                    fontSize: themeProvider.fontSize,
                    color: themeProvider.themeData.colorScheme.secondary,
                  ),
                ),
                trailing: Icon(Icons.chevron_right,color: themeProvider.themeData.colorScheme.secondary),
                onTap: () {
                  // Navigate to Change Username Page or Dialog
                },
              ),
              ListTile(
                title: Text(
                  'Change Email',
                  style: TextStyle(
                    fontSize: themeProvider.fontSize,
                    color: themeProvider.themeData.colorScheme.secondary,
                  ),
                ),
                trailing: Icon(Icons.chevron_right,color: themeProvider.themeData.colorScheme.secondary),
                onTap: () {
                  // Navigate to Change Email Page or Dialog
                },
              ),
              ListTile(
                title: Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: themeProvider.fontSize,
                    color: themeProvider.themeData.colorScheme.secondary,
                  ),
                ),
                trailing: Icon(Icons.chevron_right,color: themeProvider.themeData.colorScheme.secondary),
                onTap: () {
                  // Navigate to Change Password Page or Dialog
                },
              ),
              ListTile(
                title: Text(
                  'Font Size',
                  style: TextStyle(
                    fontSize: themeProvider.fontSize,
                    color: themeProvider.themeData.colorScheme.secondary,
                  ),
                ),
                trailing: SizedBox(
                  width: 200,
                  child: Slider(
                    value: themeProvider.fontSize,
                    min: 10,
                    max: 30,
                    activeColor: themeProvider.themeData.colorScheme.primary,
                    inactiveColor: themeProvider.themeData.colorScheme.secondary,
                    divisions: 4,
                    label: themeProvider.fontSize.toString(),
                    onChanged: (double value) {
                      setState(() {
                        themeProvider.fontSize = value;
                      });
                    },
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  'Color Theme',
                  style: TextStyle(
                    fontSize: themeProvider.fontSize,
                    color: themeProvider.themeData.colorScheme.secondary,
                  ),
                ),
                trailing: Switch(
                  value: _darkTheme,
                  activeColor: themeProvider.themeData.colorScheme.primary,
                  inactiveThumbColor: themeProvider.themeData.colorScheme.secondary,
                  onChanged: (bool value) {
                    setState(() {
                      _darkTheme = value;
                      themeProvider.toggleTheme();
                    });
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

