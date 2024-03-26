// create_account_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'stripe_web.dart'; // Import the Stripe web service
import 'stripe_ios.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>(); // GlobalKey for the form
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _adminCodeController = TextEditingController();
  bool _isAdmin = false;

  Future<void> createAccount() async {
    // Check if the Admin option is selected and the admin code is not "admin"
    if (_isAdmin && _adminCodeController.text != 'admin') {
      _showDialog('Error', 'Invalid admin code. Please try again.');
      return; // Stop the function from proceeding further
    }

    try {
      if (kIsWeb) {
        // Use the StripeWeb service for web-specific logic
        await StripeWeb().createAccount(
          email: _emailController.text,
          password: _passwordController.text,
          displayName: _displayNameController.text,
          isAdmin: _isAdmin,
          adminCode: _adminCodeController.text,
        );
        // Web browser will handle redirection to Stripe checkout
      } else {
        await StripeIOS().createAccount(
          context: context,
          email: _emailController.text,
          password: _passwordController.text,
          displayName: _displayNameController.text,
          isAdmin: _isAdmin,
          adminCode: _adminCodeController.text,
        );
      }
      
    } catch (e) {
      // Handle any errors by showing a dialog
      _showDialog('Error', e.toString());
    }
  }

  // Helper method to show dialogs
  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildTextField(_emailController, 'Email', (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                }),
                _buildTextField(_passwordController, 'Password', (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'Password must be more than 6 characters';
                  }
                  return null;
                }, obscureText: true),
                _buildTextField(_displayNameController, 'Display Name', (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a display name';
                  }
                  return null;
                }),
                SwitchListTile(
                  title: Text('Admin Account'),
                  value: _isAdmin,
                  onChanged: (bool value) {
                    setState(() {
                      _isAdmin = value;
                    });
                  },
                ),
                if (_isAdmin)
                  _buildTextField(_adminCodeController, 'Admin Code', (value) => null),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      createAccount();
                    }
                  },
                  child: Text('Create Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _adminCodeController.dispose();
    super.dispose();
  }

  // Helper method to build text fields
  Widget _buildTextField(TextEditingController controller, String labelText, String? Function(String?) validator, {bool obscureText = false}) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(hintText: labelText),
        validator: validator,
        obscureText: obscureText,
      ),
    );
  }
}
