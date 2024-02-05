import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
    Position? _currentPosition;
    StreamSubscription<Position>? _positionStreamSubscription;
    LatLng latLong2 = LatLng(0.0, 0.0); // Initialize with default values
    Function(LatLng)? onLocationChanged;

    Position? get currentPosition => _currentPosition;
    LatLng get currentLatLng => latLong2;

    // Request permission and get the current location
    Future<void> getCurrentLocation() async {
        bool serviceEnabled;
        LocationPermission permission;

        // Check if location services are enabled
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
            return Future.error('Location services are disabled.');
        }

        // Check permission status
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
            if (permission == LocationPermission.denied) {
                return Future.error('Location permissions are denied.');
            }
        }

        if (permission == LocationPermission.deniedForever) {
            return Future.error(
                    'Location permissions are permanently denied, we cannot request permissions.');
        }

        // When permissions are granted, get the current position
        _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        latLong2 = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    }

    void startPositionUpdates() {
        const locationSettings = LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10, // Only update if location changes by more than 10 meters
        );

        _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (Position? position) {
                if (position != null) {
                    _currentPosition = position;
                    
                    // Update latLong2 with the new position
                    latLong2 = LatLng(position.latitude, position.longitude);
                    print('New location: (${latLong2.latitude}, ${latLong2.longitude})');

                    // If you have any listeners or callbacks, you can call them here.
                    // For example: notifyListeners(); if you're using a ChangeNotifier
                    if (onLocationChanged != null) {
                        onLocationChanged!(latLong2);
                    }

                }
            },
        );
    }

    void stopPositionUpdates() {
        _positionStreamSubscription?.cancel();
    }
}
