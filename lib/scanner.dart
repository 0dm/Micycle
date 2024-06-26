import 'dart:async';
import 'package:Micycle/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
class Scanner extends StatefulWidget {
  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  late MobileScannerController cameraController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner', style: TextStyle(color:themeProvider.themeData.colorScheme.primary)),
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
                    return Icon(Icons.camera_front, color: themeProvider.themeData.colorScheme.primary);
                  case CameraFacing.back:
                    return Icon(Icons.camera_rear, color: themeProvider.themeData.colorScheme.primary);
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
                if (barcode.rawValue != null){
                  Navigator.pop(context, barcode.rawValue);
                }
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
