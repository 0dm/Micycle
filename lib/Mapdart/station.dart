import 'package:latlong2/latlong.dart';

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