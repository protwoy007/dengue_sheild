import "package:geolocator/geolocator.dart";
import "../models/district.dart";
import "../data/districts_data.dart";

class UserLocation {
  final double lat;
  final double lng;
  final District nearestDistrict;
  const UserLocation({required this.lat, required this.lng, required this.nearestDistrict});
}

class LocationService {
  static Future<UserLocation?> getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 12),
      );

      District? nearest;
      double minDist = double.infinity;
      for (final d in allDistricts) {
        final dist = Geolocator.distanceBetween(
          pos.latitude, pos.longitude, d.lat, d.lng);
        if (dist < minDist) { minDist = dist; nearest = d; }
      }

      return UserLocation(
        lat: pos.latitude,
        lng: pos.longitude,
        nearestDistrict: nearest!,
      );
    } catch (_) {
      return null;
    }
  }
}
