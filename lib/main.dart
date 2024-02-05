import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiCycle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    MapPage(),
    QRScannerPage(),
    BikePage(),
    InfoPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MiCycle 🚲'),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
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
            icon: Icon(Icons.directions_bike),
            label: 'Bike',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Info',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.blue,
      ),
    );
  }
}

class MapPage extends StatelessWidget {
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

class QRScannerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('QR Scanner Page'));
  }
}

class BikePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Bike Page'));
  }
}

class InfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Info Page'));
  }
}
