import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:typed_data';
import 'scanner.dart';
import 'home.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../env.dart';

final Uri _url = Uri.parse('web/scanner.html');



class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  
  bool rented = false;
  String stationInfo = '';
  Timer? timer;
  int elapsedSeconds = 0;

  @override
  Widget build(BuildContext context) {
    _startTimer();
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
                if (!rented){
                  _launchQRScanner();
                }
                // _getStationInfo();
              },
              child: Text('Rent Bike with QR code'),
            ),
            SizedBox(height: 20),
            Text(stationInfo),
            SizedBox(height: 20),
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
    if (result == null) {
      return;
    }
    
    print('Scanned QR Code: $result');

    // Construct the data to be sent in the POST request
    Map<String, String> postData = {
      'id': result, 
      'email': Home.email
    };

    print(jsonEncode(postData));

    // Make the POST request to the server
    final response = await http.post(
      Uri.parse('http://localhost:8000/qr'), 
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
          stationInfo = 'Bike sucesfully rented';
          _startTimer();
        });
      _checkStatus();
    } else {
      print('Failed to make POST request. Status code: ${response.statusCode}, ${response.body}');
    }
  }

  void _checkStatus() async {
          print('http://localhost:8000/active/${Home.email}');

    final response = await http.get(
      Uri.parse('http://localhost:8000/active/${Home.email}'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200){
      print("Panic");
      return;
    }

    dynamic body = jsonDecode(response.body);
    rented = body["Rented"];

    if (body["Rented"]){
      setState(() {
          stationInfo = 'Bike rented for ${body["Time"]}';
        });
    }
    else{
        setState(() {
          stationInfo = 'Bike returned after ${body["Time"]}';
        });
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
    _stopTimer();
    timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _checkStatus();
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
