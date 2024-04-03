import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // Import this package
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';

import 'Mapdart/basic_map.dart';
import 'chat.dart';
import 'profile.dart';
import 'package:http/http.dart' as http;
import 'qrscanner.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider.instance,
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Micycle',
      theme: ThemeProvider.instance.themeData,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  static var displayName;
  static var email;
  static var isAdmin = true;
  const Home({Key? key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const BasicMap(),
    QRScannerPage(), // Fallback for other platforms
    Chat(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'QR Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        unselectedItemColor: themeProvider.themeData.colorScheme.primary, 
        selectedItemColor: themeProvider.themeData.colorScheme.secondary,
        selectedFontSize: themeProvider.fontSize, // Set the font size for selected labels
        unselectedFontSize: themeProvider.fontSize, // Set the font size for unselected labels
      ),
    );
  }
}

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(43.548729, -79.664291),
        zoom: 12,
      ),
    );
  }
}

class QRScanPage extends StatefulWidget {
  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  late MobileScannerController cameraController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner'),
        actions: [
          IconButton(
            color: Colors.black,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state as TorchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            color: Colors.black,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state as CameraFacing) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          MobileScanner(
            // fit: BoxFit.contain,
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              final Uint8List? image = capture.image;
              for (final barcode in barcodes) {
                print('Barcode found! ${barcode.rawValue}');
              }
            },
          ),
          Center(
              child: Container(
            width: 200,
            height: 200,
            decoration:
                BoxDecoration(border: Border.all(color: Colors.red, width: 3)),
          ))
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();
    if (!status.isGranted) {
      // Show a message to the user explaining why the app needs the camera permission.
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }
}