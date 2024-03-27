import 'package:latlong2/latlong.dart';

class Station {
  String name;
  String address;
  LatLng location;
  int bikes;
  List<dynamic> predicted_num_bike;
  Station(
      {required this.name,
      required this.address,
      required this.location,
      required this.bikes,
      required this.predicted_num_bike});
  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
        name: json['name'],
        address: json['address'],
        location: LatLng(json['x'], json['y']),
        bikes: json['num_bike'],
        predicted_num_bike: json['predicted_num_bike']);
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'x': location.latitude,
      'y': location.longitude,
      'num_bike': bikes
    };
  }
}
