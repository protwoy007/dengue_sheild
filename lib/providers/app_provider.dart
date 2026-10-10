import "package:flutter/material.dart";
import "../data/districts_data.dart";
import "../models/district.dart";
import "../models/case_report.dart";
import "../l10n/strings.dart";
import "../services/weather_service.dart";
import "../services/dengue_scraper.dart";
import "../services/location_service.dart";
import "../services/notification_service.dart";
import "../services/storage_service.dart";

class AppProvider extends ChangeNotifier {
  bool _isBengali = false;
  bool _isLoading = false;        // pull-to-refresh in progress
  bool _isLoadingWeather = false; // background fetch in progress
  bool _locating = false;
  bool _weatherLive = false;      // last fetch succeeded
  int _tab = 0;

  List<District> _districts = List<District>.from(allDistricts);
  DengueData? _dengueData;
  UserLocation? _userLocation;
  String? _manualAreaId;
  DateTime? _weatherUpdated;
  DateTime? _dengueUpdated;

  // ── v1.2 state ──
  ThemeMode _themeMode = ThemeMode.system;
  bool _reminderOn = false;
  int _remH = 8, _remM = 0;
  List<CaseReport> _reports = [];
  Map<String, Map<String, int>> _history = {}; // districtId -> {yyyy-mm-dd: score}

  DateTime? _lastRefresh;
  static const _refreshCooldown = Duration(seconds: 30);

  // ── getters ──
  bool get isBengali => _isBengali;
  bool get isLoading => _isLoading;
  bool get isLoadingWeather => _isLoadingWeather;
  bool get locating => _locating;
  bool get weatherLive => _weatherLive;
  int get tab => _tab;
  List<District> get districts => _districts;
  DengueData? get dengueData => _dengueData;
  UserLocation? get userLocation => _userLocation;
  String? get manualAreaId => _manualAreaId;
  S get s => S(_isBengali);
  ThemeMode get themeMode => _themeMode;
  bool get reminderOn => _reminderOn;
  TimeOfDay get reminderTime => TimeOfDay(hour: _remH, minute: _remM);
  List<CaseReport> get reports => _reports;

  /// True while weather data is older than ~3 hours (i.e. from the offline cache).
  bool get weatherStale =>
      _weatherUpdated == null || DateTime.now().difference(_weatherUpdated!) > const Duration(hours: 3);

  District? _byId(String id) {
    for (final d in _districts) { if (d.id == id) return d; }
    return null;
  }

  /// The user's own district: a manually picked one wins, otherwise GPS.
  District? get myDistrict {
    if (_manualAreaId != null) return _byId(_manualAreaId!);
    if (_userLocation != null) return _byId(_userLocation!.nearestDistrict.id);
    return null;
  }

  bool get usingManualArea => _manualAreaId != null;

  /// Distance from the GPS fix to the matched district centre (null when picked manually).
  double? get gpsDistanceKm => usingManualArea ? null : _userLocation?.distanceKm;

  /// The district to feature on Home: yours if known, else the highest-risk one.
  District get focusDistrict =>
      myDistrict ?? _districts.reduce((a, b) => a.riskScore >= b.riskScore ? a : b);

  String get weatherTimeAgo => _timeAgo(_weatherUpdated, _isBengali);
  String get dgshTimeAgo => _timeAgo(_dengueUpdated, _isBengali);

  String _timeAgo(DateTime? dt, bool bn) {
    if (dt == null) return bn ? "আপডেট হয়নি" : "Not updated";
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return bn ? "এইমাত্র" : "Just now";
    if (diff.inMinutes < 60) return bn ? "${diff.inMinutes} মিনিট আগে" : "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return bn ? "${diff.inHours} ঘণ্টা আগে" : "${diff.inHours} hr ago";
    return bn ? "${diff.inDays} দিন আগে" : "${diff.inDays} day ago";
  }

  // ── lifecycle ──
  /// Fast: loads saved settings + cache so the UI is usable immediately (even offline).
  Future<void> init() async {
    await StorageService.init();
    _isBengali = StorageService.isBengali;
    _manualAreaId = StorageService.areaId;
    _districts = List<District>.from(allDistricts);
    _themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == StorageService.themeMode, orElse: () => ThemeMode.system);
    _reminderOn = StorageService.reminderOn;
    _remH = StorageService.reminderHour;
    _remM = StorageService.reminderMinute;
    _loadReports();
    _loadHistory();

    _loadWeatherCache();
    _loadDengueCache();
    notifyListeners();

    // Notification setup + network fetches must not block the splash screen.
    _startBackground();
  }

  Future<void> _startBackground() async {
    await NotificationService.init();
    await NotificationService.requestPermission();
    await Future.wait([_detectLocation(notify: false), _fetchLiveData()]);
    await _sendAlerts();
    await _syncReminder();
  }

  // ── theme ──
  Future<void> setThemeMode(ThemeMode m) async {
    _themeMode = m;
    notifyListeners();
    await StorageService.setThemeMode(m.name);
  }

  // ── daily reminder ──
  Future<void> setReminder({required bool on, TimeOfDay? time}) async {
    _reminderOn = on;
    if (time != null) { _remH = time.hour; _remM = time.minute; }
    notifyListeners();
    await StorageService.setReminder(_reminderOn, _remH, _remM);
    if (on) await NotificationService.requestPermission();
    await _syncReminder();
  }

  Future<void> _syncReminder() async {
    if (!_reminderOn) {
      await NotificationService.cancelDailyReminder();
      return;
    }
    await NotificationService.scheduleDailyReminder(
      hour: _remH, minute: _remM, bn: _isBengali, areaName: myDistrict?.name(_isBengali));
  }

  // ── case reports (stored on this device only) ──
  void _loadReports() {
    try {
      final raw = StorageService.readJson("case_reports");
      if (raw is List) {
        _reports = raw
            .map((e) => CaseReport.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (_) { _reports = []; }
  }

  Future<void> _saveReports() =>
      StorageService.writeJson("case_reports", _reports.map((r) => r.toJson()).toList());

  Future<void> addReport(CaseReport r) async {
    _reports = [r, ..._reports];
    notifyListeners();
    await _saveReports();
  }

  Future<void> deleteReport(String id) async {
    _reports = _reports.where((r) => r.id != id).toList();
    notifyListeners();
    await _saveReports();
  }

  Future<void> clearReports() async {
    _reports = [];
    notifyListeners();
    await StorageService.remove("case_reports");
  }

  // ── 14-day risk history (recorded on this device) ──
  static String _dayKey(DateTime d) =>
      "${d.year.toString().padLeft(4, "0")}-${d.month.toString().padLeft(2, "0")}-${d.day.toString().padLeft(2, "0")}";

  void _loadHistory() {
    try {
      final raw = StorageService.readJson("risk_history");
      if (raw is Map) {
        _history = raw.map((k, v) => MapEntry(
          k as String,
          (v as Map).map((dk, dv) => MapEntry(dk as String, (dv as num).toInt()))));
      }
    } catch (_) { _history = {}; }
  }

  Future<void> _recordHistory() async {
    final today = _dayKey(DateTime.now());
    for (final d in _districts) {
      if (!d.isLive) continue;
      final m = _history.putIfAbsent(d.id, () => <String, int>{});
      m[today] = d.riskScore;
      if (m.length > 30) {
        final keys = m.keys.toList()..sort();
        for (final k in keys.take(m.length - 30)) { m.remove(k); }
      }
    }
    await StorageService.writeJson("risk_history", _history);
  }

  /// Last 14 days of recorded risk scores, oldest first (null = no data that day).
  List<int?> trendFor(String districtId) {
    final m = _history[districtId] ?? const <String, int>{};
    final now = DateTime.now();
    return List<int?>.generate(14, (i) => m[_dayKey(now.subtract(Duration(days: 13 - i)))]);
  }

  void _loadWeatherCache() {
    final cached = StorageService.loadCache("weather");
    if (cached == null) return;
    try {
      final map = cached.map((k, v) =>
          MapEntry(k, WeatherData.fromJson(Map<String, dynamic>.from(v as Map))));
      _applyWeather(map);
      _weatherUpdated = StorageService.cacheTime("weather");
    } catch (_) {}
  }

  void _loadDengueCache() {
    final cached = StorageService.loadCache("dengue");
    if (cached != null) {
      try {
        _dengueData = DengueData.fromCache(cached);
        _dengueUpdated = StorageService.cacheTime("dengue");
        return;
      } catch (_) {}
    }
    _dengueData = DengueData.fallback;
  }

  void _applyWeather(Map<String, WeatherData> weather) {
    _districts = allDistricts.map((base) {
      final w = weather[base.id];
      if (w == null) return base;
      return base.withWeather(
        temperature: w.temperature, humidity: w.humidity,
        rainfall: w.rainfall, rain7d: w.rain7d, daily: w.daily);
    }).toList();
  }

  // ── data fetching ──
  Future<void> _fetchLiveData() async {
    _isLoadingWeather = true;
    notifyListeners();

    final results = await Future.wait([
      WeatherService.fetchAll(allDistricts),
      DengueScraper.fetchLatest(),
    ]);

    final weather = results[0] as Map<String, WeatherData>?;
    final dengue = results[1] as DengueData?;

    if (weather != null) {
      _applyWeather(weather);
      _weatherLive = true;
      _weatherUpdated = DateTime.now();
      await StorageService.saveCache("weather", weather.map((k, v) => MapEntry(k, v.toJson())));
      await _recordHistory();
    } else {
      _weatherLive = false; // keep whatever we had (cache or baseline)
    }

    if (dengue != null) {
      _dengueData = dengue;
      _dengueUpdated = DateTime.now();
      await StorageService.saveCache("dengue", dengue.toJson());
    } else if (_dengueData != null && _dengueData!.isLive) {
      // Previously live but this fetch failed -> present as cached.
      _dengueData = DengueData(
        totalCasesThisYear: _dengueData!.totalCasesThisYear,
        totalDeathsThisYear: _dengueData!.totalDeathsThisYear,
        casesThisWeek: _dengueData!.casesThisWeek,
        source: _dengueData!.source, isLive: false);
    }

    _isLoadingWeather = false;
    notifyListeners();
  }

  Future<void> _detectLocation({bool notify = true}) async {
    _locating = true;
    if (notify) notifyListeners();
    final loc = await LocationService.getLocation();
    if (loc != null) _userLocation = loc; // keep the previous fix if this attempt failed
    _locating = false;
    notifyListeners();
  }

  Future<void> _sendAlerts() async {
    final mine = myDistrict;
    if (mine != null) {
      await NotificationService.showPersonalAlert(district: mine, bn: _isBengali);
    }
    await NotificationService.showNationalAlerts(districts: _districts, bn: _isBengali);
  }

  // ── user actions ──
  void setTab(int t) { _tab = t; notifyListeners(); }

  Future<void> toggleLanguage() async {
    _isBengali = !_isBengali;
    notifyListeners();
    await StorageService.setBengali(_isBengali);
    await _syncReminder();
  }

  Future<void> setManualArea(String id) async {
    _manualAreaId = id;
    notifyListeners();
    await StorageService.setAreaId(id);
    final d = _byId(id);
    if (d != null) await NotificationService.showPersonalAlert(district: d, bn: _isBengali);
    await _syncReminder();
  }

  /// Go back to GPS-based area detection.
  Future<void> useGps() async {
    _manualAreaId = null;
    notifyListeners();
    await StorageService.setAreaId(null);
    await _detectLocation();
    await _syncReminder();
  }

  Future<void> refresh() async {
    if (_lastRefresh != null &&
        DateTime.now().difference(_lastRefresh!) < _refreshCooldown) return;
    _lastRefresh = DateTime.now();
    _isLoading = true;
    notifyListeners();
    await Future.wait([_fetchLiveData(), _detectLocation(notify: false)]);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> locateMe() => _detectLocation();
}
