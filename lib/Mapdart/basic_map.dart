import 'dart:convert';

import 'package:Micycle/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../home.dart';
import '../env.dart';
import 'location_service.dart';
import 'dart:async';
import 'station_bubble.dart';
import 'station_form.dart';
import 'bottom_sheet.dart';
import 'station_models.dart';

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
    var url = Uri.http('172.174.183.117:8000', 'stations');

    try {
      response = await http.get(url);
    } catch (e) {
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
        double sidex = stations[index].location.latitude;
        double sidey = stations[index].location.longitude;
        String name = stations[index].name;
        String addrs = stations[index].address;
        int bikes = stations[index].bikes;
        List<dynamic> predicted_num_bike = stations[index].predicted_num_bike;
        showModalBottomSheet(
            context: context,
            builder: (context) { 
                return StationBottomSheet(
                  index: index, 
                  sidex: sidex, 
                  sidey: sidey, 
                  name: name, 
                  addrs: addrs, 
                  bikes: bikes,
                  predicted_num_bike: predicted_num_bike,
                  children: [
                StationBubble(
                    onPressed: (){
                      Uri _url = Uri.parse( 'https://www.google.com/maps/dir/?api=1&destination=$sidex,$sidey'); launchUrl(_url);
                      }, 
                    icon: Icon(Icons.directions)
                  ), Visibility(
                  visible: (Home.isAdmin),
                  child:
                Row(
                  children: [ 
                   StationBubble(
                    onPressed: (){
                     _onEditStationPressed(index + 1);
                    Navigator.of(context).pop();
                    fetchStation();
                    }, 
                    icon: Icon(Icons.edit)
                  ),
                  StationBubble(
                    onPressed: (){_onDeleteStationPressed(index + 1);}, 
                    icon: Icon(Icons.delete)
                  ),
                  ],
                ),),
              ],
                  );
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
                        heroTag: null,
                        onPressed: promptUserForLocation,
                        child: Icon(Icons.add_location),
                        tooltip: 'Add Station',
                      ),
                      SizedBox(height: 8),
                      FloatingActionButton(
                          heroTag: null,
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
                        child: FloatingActionButton(
                          onPressed:  fetchStation,
                          child:  Icon(Icons.refresh),
                          tooltip: "Refresh Stations",
                        ),
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
      return StationForm(
        text: "Add a New Station", 
        nameController: nameController, 
        addressController: addressController, 
        latitudeController: latitudeController, 
        longitudeController: longitudeController, 
        bikesController: bikesController, 
        onPressed: () async {
              var newStation = Station(
                name: nameController.text,
                address: addressController.text,
                location: LatLng(
                  double.parse(latitudeController.text),
                  double.parse(longitudeController.text),
                ),
                bikes: int.parse(bikesController.text),
                predicted_num_bike: []
              );

              // Send POST request to add the new station
              var url = Uri.http('172.174.183.117:8000', 'stations/');
              try {
                final response = await http.post(
                  url,
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(newStation.toJson()),
                );

                if (response.statusCode == 200) {
                  print('Station added successfully');
                  fetchStation();
                } else {
                  print('Failed to add station. Error: ${response.statusCode}');
                }
              } catch (error) {
                print('Failed to add station. Error: $error');
              }
              Navigator.of(context).pop();
          }
        );
      },
    );
  }

  void _onEditStationPressed(int index) async {
    var response;
    var url = Uri.http('172.174.183.117:8000', 'stations/$index');

    try {
      response = await http.get(url);
    } catch (e) {
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

    url = Uri.http('172.174.183.117:8000', 'stations/');

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StationForm(
          text: "Edit a Station", 
          nameController: nameController, 
          addressController: addressController, 
          latitudeController: latitudeController, 
          longitudeController: longitudeController, 
          bikesController: bikesController, 
          onPressed: () async {
              var editedStation = updateStation(
                id: index,
                name: nameController.text,
                address: addressController.text,
                location: LatLng(
                  double.parse(latitudeController.text),
                  double.parse(longitudeController.text),
                ),
                bikes: int.parse(bikesController.text),
              );

              try {
                final response = await http.put(
                  url,
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(editedStation.toJson()),
                );

                if (response.statusCode == 200) {
                  print('Station edited successfully');
                  fetchStation();
                } else {
                  print('Failed to edit station. Error: ${response.statusCode}');
                }
              } catch (error) {
                print('Failed to edit station. Error: $error');
              }

              Navigator.of(context).pop();
          }
        );
      }
    );
  }

  //make sure to raise proper errors here
  void _onDeleteStationPressed(int index) async {
    var response;
    var url = Uri.http('172.174.183.117:8000', 'stations/');

    var deletedStation = deleteStation(id: index);
    try {
      final response = await http.delete(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(deletedStation.toJson()),
      );
      if(response.statusCode == 200){
        print('Station deleted successfully');
      }else{
        print('Failed to delete station. Error: ${response.statusCode}');
      }
    }catch (error) {
      print('Failed to delete station. Error: $error');
    }
    Navigator.of(context).pop();
    fetchStation();
    
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

