import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeIOS {
  final String _serverUrl = 'http://localhost:5000'; // Adjust to your server

  StripeIOS() {
    Stripe.publishableKey = 'pk_test_51OkvTNGUL4Iok28JlEJg9nU5wYZqyLCicm5ZyNcRAZ90DjgmqxYTtdKqBqa1o5oQW53WVKkDWvLZtP3UPkv2H5zc00Od695BDj'; // Your Stripe publishable key
    Stripe.merchantIdentifier = 'merchant.com.example'; // For Apple Pay, if used
    Stripe.instance.applySettings();
  }

  Future<void> createAccount({
    required BuildContext context,
    required String email,
    required String password,
    required String displayName,
    required bool isAdmin,
    String adminCode = '',
  }) async {
    // Step 1: Create Stripe Customer and save to your backend
    final customerResponse = await _createStripeCustomer(
      email: email,
      displayName: displayName,
    );
    if (customerResponse == null) {
      _showErrorDialog(context, 'Error', 'Failed to create Stripe customer.');
      return;
    }

    // Extract the Stripe customer ID from the response
    final stripeCustomerId = customerResponse['stripeCustomerId'];

    // Step 2: Setup payment method for the customer
    final setupIntentClientSecret = await _getSetupIntentClientSecret(email: email);
    if (setupIntentClientSecret == null) {
      _showErrorDialog(context, 'Error', 'Failed to get setup intent for payment method.');
      return;
    }

    // Present the payment sheet for adding a payment method
    final paymentMethodAdded = await _presentPaymentSheet(setupIntentClientSecret);
    if (!paymentMethodAdded) {
      _showErrorDialog(context, 'Error', 'Failed to add payment method.');
      return;
    }

    // Navigate back to the login page upon success
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushReplacementNamed(context, '/login_page');
  }

  Future<Map<String, dynamic>?> _createStripeCustomer({required String email, required String displayName}) async {
    final url = Uri.parse('$_serverUrl/create_stripe_customer');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({'email': email, 'displayName': displayName}),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    }
    return null;
  }

  Future<String?> _getSetupIntentClientSecret({required String email}) async {
    // Implement the backend call to create a SetupIntent and return its client secret
    // This requires a backend endpoint not shown in your initial setup
    return 'setup_intent_client_secret'; // Placeholder
  }

  Future<bool> _presentPaymentSheet(String clientSecret) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: clientSecret,
          merchantDisplayName: 'Your App Name',
          // Additional configuration as necessary
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      return true;
    } catch (e) {
      return false;
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
