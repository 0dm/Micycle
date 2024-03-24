import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../home.dart';
import 'location_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class Station{
    String name;
    String address;
    LatLng location;
    int bikes;
    Station({required this.name, required this.address, required this.location, required this.bikes});
    factory Station.fromJson(Map<String, dynamic> json){
        return Station(
            name: json['name'],
            address: json['address'],
            location: LatLng(json['x'], json['y']),
            bikes: json['num_bike']
        );
    }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'x': location.latitude,
      'y': location.longitude,
      'num_bike': bikes,
    };
  }
}

class BottomSheet extends StatelessWidget {
  const BottomSheet(
      {required this.sidex,
      required this.sidey,
      required this.name,
      required this.addrs,
      required this.bikes,
      required this.index,
      });

  final double sidex;
  final double sidey;
  final String name;
  final String addrs;
  final int bikes;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.75),
      padding: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Image.asset(
            'assets/images/placeHolderBike.jpeg', // Replace with your image asset
            width: MediaQuery.of(context)
                .size
                .width, // Set image width to full screen width
            height: MediaQuery.of(context).size.height *
                0.3, // Adjust the size accordingly
            fit: BoxFit
                .cover, // Cover the entire width while keeping aspect ratio
          ),
          SizedBox(height: 16),
          Text(
            '$name',
            style: TextStyle(fontSize: 30), // Adjust the style as needed
          ),
          Text(
            '$addrs',
            style: TextStyle(fontSize: 16), // Adjust the style as needed
          ),
          Text(
            'Remaining Bike: $bikes/10',
            style: TextStyle(fontSize: 16), // Adjust the style as needed
          ),
          SizedBox(height: 16),
          Align(
            alignment:
                Alignment.centerLeft, // Aligning only this widget to the left
            child: Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // To prevent the Row from occupying the entire horizontal space
              children: [
                Container(
                  width: 80, // Diameter of the circle
                  height: 80, // Diameter of the circle
                  margin: EdgeInsets.only(right: 8), // Spacing between buttons
                  decoration: BoxDecoration(
                    color: Colors.blue, // Color of the circle
                    shape: BoxShape.circle,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Action when the button is pressed
                      Uri _url = Uri.parse(
                          'https://www.google.com/maps/dir/?api=1&destination=$sidex,$sidey');
                      launchUrl(_url);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      primary: Colors.blue, // Background color of the button
                    ),
                    child: Icon(Icons.directions),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 80, // Diameter of the circle
                      height: 80, // Diameter of the circle
                      margin:
                          EdgeInsets.only(right: 8), // Spacing between buttons
                      decoration: BoxDecoration(
                        color: Colors.blue, // Color of the circle
                        shape: BoxShape.circle,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                            _onEditStationPressed(index + 1);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          primary:
                              Colors.blue, // Background color of the button
                        ),
                        child: Icon(Icons.edit),
                      ),
                    ),
                    Container(
                      width: 80, // Diameter of the circle
                      height: 80, // Diameter of the circle
                      margin:
                          EdgeInsets.only(right: 8), // Spacing between buttons
                      decoration: BoxDecoration(
                        color: Colors.blue, // Color of the circle
                        shape: BoxShape.circle,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          _onDeleteStationPressed(index + 1);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          primary:
                              Colors.blue, // Background color of the button
                        ),
                        child: Icon(Icons.delete),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  
  void _onEditStationPressed(int index) async {
    var response;
    var url = Uri.http('localhost:8000', 'stations/$index');

    try {
      response = await http.get(url);
    } catch (e) {
      print("Error123");
      print(e);
      return;
    }
    print(index);
    print(response.body);

    Station station =  Station.fromJson(json.decode(response.body));

    TextEditingController nameController = TextEditingController(text: station.name);
    TextEditingController addressController = TextEditingController(text: station.address);
    TextEditingController latitudeController = TextEditingController(text: station.location.latitude.toString());
    TextEditingController longitudeController = TextEditingController(text: station.location.longitude.toString());
    TextEditingController bikesController = TextEditingController(text: station.bikes.toString());

   //implement the editing here
   //stations.put
  }

  //make sure to raise proper errors here
  void _onDeleteStationPressed(int index) async {
    var response;
    var url = Uri.http('localhost:8000', 'stations/');

    try {
      final response = await http.delete(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode( {"station_id": index}),
      );

      if(response == 200){
        print("works");
      }else{
        print("did not work");
      }
    }catch (error) {
      print('Failed to delete station. Error: $error');
    }
    
  }
}

class BasicMap extends StatefulWidget {
  const BasicMap({super.key});
  @override
  _BasicMapState createState() => _BasicMapState();
}

class _BasicMapState extends State<BasicMap> {
  Widget LocationLogo = const Icon(Icons.location_on_rounded);
  Widget StationLogo = const Icon(
    Icons.pedal_bike_sharp,
    color: Colors.black,
    size: 40,
  );
    Widget StationLogoEmpty = const Icon(Icons.pedal_bike_sharp, color: Colors.red, size: 40,);

  LatLng curLoc = LatLng(43.59275, -79.64114);
  bool ifMoved = false;
  Icon locationActive = Icon(Icons.location_on);
  final LocationService _locationService = LocationService();
  final MapController mapController = MapController();
  Marker? _marker;
  bool isProgramMoved = false;
  List<Station> stations = [];
  List<Marker> locMarker = [];
  bool _canFetchStation = true;
  bool isWaitingForMapTap = false;


  void fetchStation() async {
    if (_canFetchStation == false){
      return;
    }
    _canFetchStation = false;
    Timer(Duration(seconds: 1), () {
      _canFetchStation = true;
    });

    var response;
    var url = Uri.http('localhost:8000', 'stations');

    try {
      response = await http.get(url);
    } catch (e) {
      print("Error123");
      print(e);
      return;
    }
    print(response.body);
    if (response.statusCode == 200) {
      stations = (json.decode(response.body) as List)
          .map((data) => Station.fromJson(data))
          .toList();
      List<Marker> tempLocMarker = List<Marker>.generate(
        stations.length,
        (index) => Marker(
            point: stations[index].location,
            child: GestureDetector(
                onTap: () => _showBottomSheet(index),
                child:
                    stations[index].bikes == 0 ? StationLogoEmpty : StationLogo) // Replace 'markerClicked' with the actual widget you want to use as a marker
            ),
      );
      setState(() {
        locMarker = tempLocMarker;
      });
    } else {}
  }

    void _showBottomSheet(int index) {
        // int id = stations[index].id;
        double sidex = stations[index].location.latitude;
        double sidey = stations[index].location.longitude;
        String name = stations[index].name;
        String addrs = stations[index].address;
        int bikes = stations[index].bikes;
        showModalBottomSheet(
            context: context,
            builder: (context) { 
                return BottomSheet(index: index, sidex: sidex, sidey: sidey, name: name, addrs: addrs, bikes: bikes);
            },
            isScrollControlled: true, // Set to true so the BottomSheet can take full screen height if needed
        );
    }

    @override
    void initState() {
        super.initState();  
        mapController.mapEventStream.listen((MapEvent event) {
            if (event.source != MapEventSource.mapController) {
                ifMoved = true;
                setState((){locationActive = Icon(Icons.location_off);});
            } 
        });

        _marker = Marker(point: LatLng(43.59275, -79.64114), child: LocationLogo);      
        _locationService.getCurrentLocation().then((_) {
            print('Initial location: (${_locationService.currentLatLng.latitude}, ${_locationService.currentLatLng.longitude})');
        }).catchError((e) {
            print(e);
        });
        _locationService.onLocationChanged = (newLocation) {
            curLoc = newLocation;
            if (!ifMoved){
                isProgramMoved = true;

                setState(() {
                    mapController.move(newLocation, 15);
                });
                isProgramMoved = false;
                
            }
            setState(() {
              _marker = Marker(point: newLocation, child: LocationLogo);
            });
        };
        fetchStation();
        _locationService.startPositionUpdates();
    }

    @override
    void dispose() {
        _locationService.stopPositionUpdates();
        super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Micycle 🚲')),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          interactionOptions: InteractionOptions(
            enableMultiFingerGestureRace: true,
            flags: InteractiveFlag.doubleTapDragZoom |
                InteractiveFlag.doubleTapZoom |
                InteractiveFlag.drag |
                InteractiveFlag.flingAnimation |
                InteractiveFlag.pinchZoom |
                InteractiveFlag.scrollWheelZoom,
          ),
          initialCenter: LatLng(43.59275, -79.64114),
          initialZoom: 15,
          onTap: (tapPosition, point) => {
              if (isWaitingForMapTap) {
                setState(() {
                  isWaitingForMapTap = false; // Reset the flag
                }),
                _onAddStationPressed(point)
              },
            },),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(markers: [_marker!]),
          MarkerLayer(markers: locMarker),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                    mainAxisSize:
                        MainAxisSize.min, // Use min size to wrap content
                    crossAxisAlignment: CrossAxisAlignment
                        .end, // Aligns the column's children to the start, matching your design intent.
                    children: <Widget>[
                      if(Home.isAdmin) FloatingActionButton(
                        onPressed: promptUserForLocation,
                        child: Icon(Icons.add_location),
                        tooltip: 'Add Station',
                      ),
                      SizedBox(height: 8),
                      FloatingActionButton(
                          onPressed: () {
                            isProgramMoved = true;
                            ifMoved = false;
                            mapController.move(curLoc, 15);
                            setState(() {
                              locationActive = Icon(Icons.location_on);
                            });
                            isProgramMoved = false;
                          },
                          tooltip: 'Jump to Current Location',
                          child: locationActive)
                    ])),
          ),
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () =>
                    launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
              ),
            ],
          ),
                          Align(
                    alignment: Alignment.topLeft,   
                    child: Padding(                            
                        padding: EdgeInsets.all(10.0),
                        child: Container(
                            width: 80, // Diameter of the circle
                            height: 80, // Diameter of the circle
                            margin: EdgeInsets.only(right: 8), // Spacing between buttons
                            decoration: BoxDecoration(
                                color: Colors.blue, // Color of the circle
                                shape: BoxShape.circle,
                            ),
                            child: ElevatedButton(
                                onPressed: () {
                                    fetchStation();
                                },
                                style: ElevatedButton.styleFrom(
                                    shape: CircleBorder(),
                                    backgroundColor: Colors.blue, // Background color of the button
                                ),
                            child: Icon(Icons.refresh)
                            )
                        )
                    ),
                ),

        ],
      ),
    );
  }


  void _onAddStationPressed(LatLng tappedLoc) async {
  TextEditingController nameController = TextEditingController(text: "New Station");
  TextEditingController addressController = TextEditingController(text: "New Address");
  TextEditingController latitudeController = TextEditingController(text: tappedLoc.latitude.toString());
  TextEditingController longitudeController = TextEditingController(text: tappedLoc.longitude.toString());
  TextEditingController bikesController = TextEditingController(text: "0");

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Add New Station"),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Station Name'),
              ),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              TextFormField(
                controller: latitudeController,
                decoration: InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextFormField(
                controller: longitudeController,
                decoration: InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextFormField(
                controller: bikesController,
                decoration: InputDecoration(labelText: 'Number of Bikes'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Add'),
            onPressed: () async {
              var newStation = Station(
                name: nameController.text,
                address: addressController.text,
                location: LatLng(
                  double.parse(latitudeController.text),
                  double.parse(longitudeController.text),
                ),
                bikes: int.parse(bikesController.text),
              );
              
              // Send POST request to add the new station
              final Uri apiUrl = Uri.parse('http://localhost:8000/stations');
              try {
                final response = await http.post(
                  apiUrl,
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(newStation.toJson()),
                );

                if (response.statusCode == 200) {
                  print('Station added successfully');
                  // Add the station to the local list and map markers if needed
                  setState(() {
                    stations.add(newStation);
                    locMarker.add(
                      Marker(
                        point: newStation.location,
                        child: GestureDetector(
                          onTap: () => _showBottomSheet(stations.length - 1),
                          child: StationLogo,
                        ),
                      ),
                    );
                  });
                } else {
                  print('Failed to add station. Error: ${response.statusCode}');
                }
              } catch (error) {
                print('Failed to add station. Error: $error');
              }

              setState(() {
                stations.add(newStation);
                locMarker.add(
                  Marker(
                    point: newStation.location,
                    child: GestureDetector(
                      onTap: () => _showBottomSheet(stations.length - 1),
                      child: StationLogo,
                    ),
                  ),
                );
              });

              // Close the dialog
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

  void promptUserForLocation() {
    final snackBar = SnackBar(
      content: Text('Tap on the map to select the location for the new station.'),
      duration: Duration(seconds: 5),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    setState(() {
      isWaitingForMapTap = true;
    });
  }
}


