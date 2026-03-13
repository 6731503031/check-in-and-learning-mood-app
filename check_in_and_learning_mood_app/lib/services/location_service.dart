import 'package:geolocator/geolocator.dart';

import '../models/class_session.dart';

class LocationService {
  Future<LocationPoint> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw StateError('Location service is disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw StateError('Location permission denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw StateError(
        'Location permission denied forever. Please enable it in settings.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return LocationPoint(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
