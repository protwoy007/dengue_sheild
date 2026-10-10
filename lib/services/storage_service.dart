import "dart:convert";
import "package:shared_preferences/shared_preferences.dart";

/// Thin wrapper around SharedPreferences: settings + offline cache.
class StorageService {
  static SharedPreferences? _p;

  static Future<void> init() async {
    try { _p ??= await SharedPreferences.getInstance(); } catch (_) {}
  }

  // ── Settings ──
  static bool get isBengali => _p?.getBool("bn") ?? false;
  static Future<void> setBengali(bool v) async => _p?.setBool("bn", v);

  static String? get areaId => _p?.getString("area_id");
  static Future<void> setAreaId(String? id) async {
    if (id == null) { await _p?.remove("area_id"); } else { await _p?.setString("area_id", id); }
  }

  // ── Theme & reminder settings ──
  static String get themeMode => _p?.getString("theme") ?? "system"; // system | light | dark
  static Future<void> setThemeMode(String v) async => _p?.setString("theme", v);

  static bool get reminderOn => _p?.getBool("remind_on") ?? false;
  static int get reminderHour => _p?.getInt("remind_h") ?? 8;
  static int get reminderMinute => _p?.getInt("remind_m") ?? 0;
  static Future<void> setReminder(bool on, int h, int m) async {
    await _p?.setBool("remind_on", on);
    await _p?.setInt("remind_h", h);
    await _p?.setInt("remind_m", m);
  }

  // ── JSON blobs (case reports, risk history) ──
  static Object? readJson(String key) {
    try {
      final raw = _p?.getString(key);
      return raw == null ? null : jsonDecode(raw);
    } catch (_) { return null; }
  }
  static Future<void> writeJson(String key, Object value) async =>
      _p?.setString(key, jsonEncode(value));
  static Future<void> remove(String key) async => _p?.remove(key);

  // ── Generic string stamps (used to throttle notifications) ──
  static String? getString(String k) => _p?.getString(k);
  static Future<void> setString(String k, String v) async => _p?.setString(k, v);

  // ── Offline cache ──
  static Future<void> saveCache(String key, Object json) async {
    await _p?.setString("cache_$key", jsonEncode(json));
    await _p?.setString("cache_${key}_at", DateTime.now().toIso8601String());
  }

  static Map<String, dynamic>? loadCache(String key) {
    try {
      final raw = _p?.getString("cache_$key");
      if (raw == null) return null;
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) { return null; }
  }

  static DateTime? cacheTime(String key) {
    final raw = _p?.getString("cache_${key}_at");
    return raw == null ? null : DateTime.tryParse(raw);
  }
}
