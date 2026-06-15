import "package:flutter/material.dart";
import "../data/districts_data.dart";
import "../models/district.dart";
import "../l10n/strings.dart";
import "../services/weather_service.dart";
import "../services/dengue_scraper.dart";
import "../services/location_service.dart";
import "../services/notification_service.dart";

class AppProvider extends ChangeNotifier {
  bool _isBengali        = false;
  bool _isLoading        = false;
  bool _isLoadingWeather = false;
  int  _tab              = 0;
  List<District> _districts = [];
  DateTime? _lastLiveUpdate;
  DateTime? _lastDghsUpdate;
  DengueData? _dengueData;
  bool _weatherLive      = false;
  UserLocation? _userLocation;
  bool _locating         = false;

  DateTime? _lastRefresh;
  static const _refreshCooldown = Duration(seconds: 30);

  bool   get isBengali        => _isBengali;
  bool   get isLoading        => _isLoading;
  bool   get isLoadingWeather => _isLoadingWeather;
  bool   get locating         => _locating;
  int    get tab              => _tab;
  List<District> get districts => _districts;
  DengueData? get dengueData  => _dengueData;
  bool   get weatherLive      => _weatherLive;
  UserLocation? get userLocation => _userLocation;
  S      get s                => S(_isBengali);

  District get topRisk =>
      _userLocation != null
        ? _userLocation!.nearestDistrict
        : _districts.reduce((a, b) => a.riskScore > b.riskScore ? a : b);

  String get weatherTimeAgo => _timeAgo(_lastLiveUpdate, _isBengali);
  String get dgshTimeAgo    => _timeAgo(_lastDghsUpdate, _isBengali);

  String _timeAgo(DateTime? dt, bool bn) {
    if (dt == null) return bn ? "আপডেট হয়নি" : "Not updated";
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60)  return bn ? "এইমাত্র" : "Just now";
    if (diff.inMinutes < 60)  return bn ? "${diff.inMinutes} মিনিট আগে" : "${diff.inMinutes} min ago";
    if (diff.inHours < 24)    return bn ? "${diff.inHours} ঘণ্টা আগে" : "${diff.inHours} hr ago";
    return bn ? "${diff.inDays} দিন আগে" : "${diff.inDays} day ago";
  }

  Future<void> init() async {
    await NotificationService.init();
    await NotificationService.requestPermission();
    _districts = allDistricts;
    notifyListeners();
    _fetchInBackground();
  }

  void _fetchInBackground() {
    _detectLocation();
    _fetchLiveData();
  }

  Future<void> _detectLocation() async {
    _locating = true;
    notifyListeners();
    _userLocation = await LocationService.getLocation();
    _locating = false;
    notifyListeners();

    // Personal notification for user's district
    if (_userLocation != null) {
      final district = _districts.firstWhere(
        (d) => d.id == _userLocation!.nearestDistrict.id,
        orElse: () => _userLocation!.nearestDistrict,
      );
      await NotificationService.showPersonalAlert(
        district: district, bn: _isBengali);
    }
  }

  Future<void> _fetchLiveData() async {
    _isLoadingWeather = true;
    notifyListeners();

    final results = await Future.wait([
      DengueScraper.fetchLatest(),
      _fetchAllWeather(),
    ]);

    _dengueData = results[0] as DengueData;
    final live = results[1] as bool;
    _weatherLive = live;

    if ((_dengueData as DengueData).isLive) _lastDghsUpdate = DateTime.now();
    if (live) _lastLiveUpdate = DateTime.now();

    _isLoadingWeather = false;
    notifyListeners();

    // National notification for all High risk districts
    await NotificationService.showNationalAlerts(
      districts: _districts, bn: _isBengali);
  }

  Future<bool> _fetchAllWeather() async {
    bool anyLive = false;
    final updated = List<District>.from(_districts);
    final top = updated.take(6).toList();
    final results = await Future.wait(
      top.map((d) => WeatherService.fetchWeather(d.lat, d.lng)));
    for (int i = 0; i < top.length; i++) {
      final w = results[i];
      if (w != null && w.isLive) {
        anyLive = true;
        final idx = updated.indexWhere((d) => d.id == top[i].id);
        if (idx != -1) {
          updated[idx] = District(
            id: updated[idx].id, nameEn: updated[idx].nameEn,
            nameBn: updated[idx].nameBn, divisionEn: updated[idx].divisionEn,
            divisionBn: updated[idx].divisionBn, lat: updated[idx].lat,
            lng: updated[idx].lng,
            riskScore: _calcRisk(w.rainfall, w.temperature, w.humidity, updated[idx].casesThisWeek),
            temperature: w.temperature, humidity: w.humidity, rainfall: w.rainfall,
            casesThisWeek: updated[idx].casesThisWeek,
            shapFactors: _calcShap(w.rainfall, w.temperature, w.humidity),
          );
        }
      }
    }
    _districts = updated;
    return anyLive;
  }

  int _calcRisk(double rain, double temp, double humidity, int cases) {
    double score = 0;
    score += (rain / 30.0).clamp(0, 1) * 38;
    final tf = temp >= 26 && temp <= 32 ? 1.0 : temp > 32 ? 0.7 : 0.5;
    score += tf * 28;
    score += (humidity / 100.0).clamp(0, 1) * 34;
    if (cases > 500) score = (score * 1.2).clamp(0, 100);
    return score.round().clamp(0, 100);
  }

  Map<String, double> _calcShap(double rain, double temp, double humidity) => {
    "Rainfall":    (rain / 30.0 * 0.38).clamp(0.05, 0.55),
    "Temperature": (temp / 35.0 * 0.28).clamp(0.05, 0.45),
    "Cases trend": 0.34,
  };

  void setTab(int t) { _tab = t; notifyListeners(); }

  Future<void> toggleLanguage() async {
    _isBengali = !_isBengali;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_lastRefresh != null &&
        DateTime.now().difference(_lastRefresh!) < _refreshCooldown) return;
    _lastRefresh = DateTime.now();
    _isLoading = true;
    notifyListeners();
    _districts = allDistricts;
    await Future.wait([_fetchLiveData(), _detectLocation()]);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> locateMe() => _detectLocation();
}
