import "package:geolocator/geolocator.dart";
import "../models/district.dart";
import "../data/districts_data.dart";

class UserLocation {
  final double lat;
  final double lng;
  final District nearestDistrict;
  final double distanceKm; // distance to that district centre
  const UserLocation({required this.lat, required this.lng, required this.nearestDistrict, this.distanceKm = 0});
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

      // Far outside Bangladesh -> treat as "unknown" so the user picks an area manually.
      if (nearest == null || minDist > 300000) return null;

      return UserLocation(
        lat: pos.latitude,
        lng: pos.longitude,
        nearestDistrict: nearest,
        distanceKm: minDist / 1000,
      );
    } catch (_) {
      return null;
    }
  }
}
