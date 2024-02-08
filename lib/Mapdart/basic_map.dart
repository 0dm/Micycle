import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'location_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
}


class BottomSheet extends StatelessWidget{
    final double sidex;
    final double sidey;
    final String name;
    final String addrs;
    final int bikes;
    BottomSheet({required this.sidex, required this.sidey, required this.name, required this.addrs, required this.bikes});

    @override
    Widget build(BuildContext context) {
        return Container(
            constraints: BoxConstraints.expand(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.75
            ),
            padding: EdgeInsets.all(16),
            child: Column(
                children: <Widget>[
                    Image.asset(
                        'assets/images/placeHolderBike.jpeg', // Replace with your image asset
                        width: MediaQuery.of(context).size.width, // Set image width to full screen width
                        height: MediaQuery.of(context).size.height * 0.3, // Adjust the size accordingly
                        fit: BoxFit.cover, // Cover the entire width while keeping aspect ratio
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
                    	alignment: Alignment.centerLeft, // Aligning only this widget to the left
                    	child: Row(
                    	    mainAxisSize: MainAxisSize.min, // To prevent the Row from occupying the entire horizontal space
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
                                            Uri _url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$sidex,$sidey');
                                            launchUrl(_url);
                            			    
                            			},
                            			style: ElevatedButton.styleFrom(
                            			    shape: CircleBorder(),
                            			    primary: Colors.blue, // Background color of the button
                            			),
                            			child: Icon(Icons.directions),
                        		    ),
                        		),
                            ],
                    	),
                	)
                ],
            ),
        );
    }
}

class BasicMap extends StatefulWidget {
    const BasicMap({super.key});

    @override
    _BasicMapState createState() => _BasicMapState();
}

class _BasicMapState extends State<BasicMap> {
    Widget LocationLogo = const Icon(Icons.location_on_rounded);
    Widget StationLogo = const Icon(Icons.pedal_bike_sharp, color: Colors.black, size: 40,);
    LatLng curLoc = LatLng(43.59275, -79.64114);
    bool ifMoved = false;
    Icon locationActive = Icon(Icons.location_on);
    final LocationService _locationService = LocationService();
    final MapController mapController = MapController();
    Marker? _marker;
    bool isProgramMoved = false;
    List<Station> stations = [];
    List<Marker> locMarker = [];
    void fetchStation() async {
        var response;
        var url = Uri.http('localhost:8000', 'stations');
        
        try{
            response = await http.get(url);
        }
        catch(e){
            print("Error123");
            print(e);
            return;
        }
        print(response.body);
        if (response.statusCode == 200){
            stations = (json.decode(response.body) as List).map((data) => Station.fromJson(data)).toList();
            List<Marker> tempLocMarker = List<Marker>.generate(
                stations.length,
                (index) => Marker(
                    point: stations[index].location,
                    child: GestureDetector(onTap: () => _showBottomSheet(index), child: StationLogo) // Replace 'markerClicked' with the actual widget you want to use as a marker
                ),
            );
            setState(() {
               locMarker = tempLocMarker;
            });
        }
        else{
            
        }

    }

    void _showBottomSheet(int index) {
        double sidex = stations[index].location.latitude;
        double sidey = stations[index].location.longitude;
        String name = stations[index].name;
        String addrs = stations[index].address;
        int bikes = stations[index].bikes;
        showModalBottomSheet(
            context: context,
            builder: (context) { 
                return BottomSheet(sidex: sidex, sidey: sidey, name: name, addrs: addrs, bikes: bikes);
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
        return FlutterMap(
            mapController: mapController,
            
            options: const MapOptions(
                interactionOptions:InteractionOptions(
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
            ),
            children: [

                TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(markers: [_marker!]),
                MarkerLayer(
                    markers: locMarker
                ),

                Align(
                    alignment: Alignment.bottomLeft,   
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
                                    isProgramMoved = true;
                                    ifMoved = false;
                                    mapController.move(curLoc, 15);
                                    setState(() {locationActive = Icon(Icons.location_on);});
                                    isProgramMoved=false;
                                },
                                style: ElevatedButton.styleFrom(
                                    shape: CircleBorder(),
                                    backgroundColor: Colors.blue, // Background color of the button
                                ),
                            child: locationActive
                            )
                        )
                    ),
                ),

                RichAttributionWidget(
                    attributions: [
                        TextSourceAttribution(
                            'OpenStreetMap contributors',
                            onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                        ),
                    ],
                ),
            ],
            
        );
    }
}


