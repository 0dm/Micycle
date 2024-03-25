import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:typed_data';
import 'scanner.dart';
import 'home.dart';

final Uri _url = Uri.parse('web/scanner.html');



class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  String stationInfo = '';
  Timer? timer;
  int elapsedSeconds = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _launchQRScanner();
                _getStationInfo();
              },
              child: Text('Rent Bike with QR code'),
            ),
            SizedBox(height: 20),
            Text(stationInfo),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _stopTimer();
                setState(() {
                  stationInfo = 'Timer stopped. Elapsed time: $elapsedSeconds seconds';
                  elapsedSeconds = 0; // Reset elapsed time
                });
              },
              child: Text('Return Bike'),
            ),
          ],
        ),
      ),
    );
  }

  void _launchQRScanner() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Scanner()),
  );

  if (result != null) {
    print('Scanned QR Code: $result');
    
    // Construct the data to be sent in the POST request
    Map<String, String> postData = {
      'message': result, 
      'email': '123@gmail.com'
    };

    print(jsonEncode(postData));

    // Make the POST request to the server
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/qr'), 
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(postData),
    );

    // Handle the response
    print("sent post");
    if (response.statusCode == 200) {
      print('POST Request Successful');
      print(response.body);
      setState(() {
          stationInfo = 'Rented a bike';
          _startTimer();
        });
        return;

    } else {
      print('Failed to make POST request. Status code: ${response.statusCode}, ${response.body}');
    }
  }
}

  void _getStationInfo() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5001/get_endpoint'));
    if (response.statusCode == 200) {
      final responseData = response.body;
      if (responseData.length > 15) {
        final station = responseData[12];
        final bike = responseData[15];
        setState(() {
          stationInfo = 'Station: $station and Bike: $bike';
          _startTimer();
        });
        return;
      }
      setState(() {
        stationInfo = 'Failed to extract station info';
      });
    } else {
      setState(() {
        stationInfo = 'Failed to fetch station info';
      });
    }
  }

  void _startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        elapsedSeconds++;
      });
    });
  }

  void _stopTimer() {
    timer?.cancel();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
