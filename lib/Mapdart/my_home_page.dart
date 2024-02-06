import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          constraints: BoxConstraints.expand(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Image.asset(
                'assets\\images\\flutter_logo.png', // Replace with your image asset
                width: MediaQuery.of(context).size.width, // Set image width to full screen width
                height: 150, // Adjust the size accordingly
                fit: BoxFit.cover, // Cover the entire width while keeping aspect ratio
              ),
              SizedBox(height: 16), // Spacing between image and text
              Text(
                'This is some description about the image.',
                style: TextStyle(fontSize: 16), // Adjust the style as needed
              ),
            ],
          ),
        );
      },
      isScrollControlled: true, // Set to true so the BottomSheet can take full screen height if needed
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BottomSheet Full Width Demo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _showBottomSheet,
          child: Text('Show BottomSheet'),
        ),
      ),
    );
  }
}
