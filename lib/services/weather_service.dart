import "dart:convert";
import "package:http/http.dart" as http;
import "../models/district.dart";

class WeatherData {
  final double temperature, humidity, rainfall, rain7d;
  final List<DailyWeather> daily;
  const WeatherData({
    required this.temperature, required this.humidity,
    required this.rainfall, required this.rain7d, required this.daily,
  });

  Map<String, dynamic> toJson() => {
    "t": temperature, "h": humidity, "r": rainfall, "r7": rain7d,
    "daily": daily.map((d) => d.toJson()).toList(),
  };

  factory WeatherData.fromJson(Map<String, dynamic> j) => WeatherData(
    temperature: (j["t"] as num).toDouble(),
    humidity: (j["h"] as num).toDouble(),
    rainfall: (j["r"] as num).toDouble(),
    rain7d: (j["r7"] as num).toDouble(),
    daily: (j["daily"] as List)
        .map((e) => DailyWeather.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
  );
}

class WeatherService {
  static const String _base = "https://api.open-meteo.com/v1/forecast";

  static double _n(dynamic v) => (v as num?)?.toDouble() ?? 0;

  /// One request for ALL districts: current conditions + 7 past days + 7 forecast days.
  /// Returns null on any failure so the caller can fall back to cached data.
  static Future<Map<String, WeatherData>?> fetchAll(List<District> districts) async {
    if (districts.isEmpty) return null;
    try {
      final lats = districts.map((d) => d.lat).join(",");
      final lngs = districts.map((d) => d.lng).join(",");
      final uri = Uri.parse(
        "$_base?latitude=$lats&longitude=$lngs"
        "&current=temperature_2m,relative_humidity_2m,precipitation"
        "&daily=precipitation_sum,temperature_2m_max,temperature_2m_min"
        "&past_days=7&forecast_days=7&timezone=Asia%2FDhaka");
      final res = await http.get(uri).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return null;

      final decoded = jsonDecode(res.body);
      // Multiple locations -> list; a single location -> object.
      final List items = decoded is List ? decoded : [decoded];
      if (items.length != districts.length) return null;

      final out = <String, WeatherData>{};
      for (int i = 0; i < districts.length; i++) {
        final item = items[i] as Map;
        final cur = item["current"] as Map;
        final daily = item["daily"] as Map;
        final times = (daily["time"] as List).cast<String>();
        final rain = daily["precipitation_sum"] as List;
        final tmax = daily["temperature_2m_max"] as List;
        final tmin = daily["temperature_2m_min"] as List;

        final days = <DailyWeather>[];
        for (int k = 0; k < times.length; k++) {
          days.add(DailyWeather(
            date: DateTime.parse(times[k]),
            rain: _n(rain[k]), tMax: _n(tmax[k]), tMin: _n(tmin[k]),
            isPast: k < 7,
          ));
        }
        final rain7 = days.where((d) => d.isPast).fold<double>(0, (a, d) => a + d.rain);

        out[districts[i].id] = WeatherData(
          temperature: _n(cur["temperature_2m"]),
          humidity: _n(cur["relative_humidity_2m"]),
          rainfall: _n(cur["precipitation"]),
          rain7d: rain7,
          daily: days,
        );
      }
      return out;
    } catch (_) {
      return null;
    }
  }
}
