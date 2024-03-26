// stripe_web.dart
import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;

class StripeWeb {
  final String serverUrl = 'http://localhost:5000'; // Adjust to your actual server address
  
  Future<void> createAccount({
    required String email,
    required String password,
    required String displayName,
    required bool isAdmin,
    String adminCode = '',
  }) async {
    if (isAdmin && adminCode != 'admin') {
      throw Exception('Invalid admin code. Please try again.');
    }

    var url = Uri.parse('$serverUrl/create_account');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'email': email,
        'password': password,
        'displayName': displayName,
        'isAdmin': isAdmin,
        'adminCode': isAdmin ? adminCode : '',
      }),
    );

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      var responseData = json.decode(response.body);
      var checkoutUrl = responseData['url']; // Use 'url' to navigate
      html.window.location.href = checkoutUrl; // Redirects to the Stripe checkout
    } else if (response.statusCode == 409) {
      throw Exception('This email address already has an account.');
    } else {
      throw Exception('Failed to create account. Please try again.');
    }
  }
}
