import "../services/risk_model.dart";

enum RiskLevel { high, medium, low }

class DailyWeather {
  final DateTime date;
  final double rain, tMax, tMin;
  /// true for days before today
  final bool isPast;
  const DailyWeather({
    required this.date, required this.rain,
    required this.tMax, required this.tMin, required this.isPast,
  });

  Map<String, dynamic> toJson() => {
    "d": date.toIso8601String(), "r": rain, "x": tMax, "n": tMin, "p": isPast,
  };
  factory DailyWeather.fromJson(Map<String, dynamic> j) => DailyWeather(
    date: DateTime.parse(j["d"] as String),
    rain: (j["r"] as num).toDouble(),
    tMax: (j["x"] as num).toDouble(),
    tMin: (j["n"] as num).toDouble(),
    isPast: j["p"] as bool,
  );
}

class District {
  final String id;
  final String nameEn, nameBn, divisionEn, divisionBn;
  final double lat, lng;
  final double temperature, humidity, rainfall; // current conditions
  final double rain7d;                          // mm over the previous 7 days
  final int casesThisWeek;                      // currently sample data
  final bool isLive;                            // weather came from the live API
  final List<DailyWeather> daily;
  final int riskScore;
  final Map<String, double> riskFactors;        // points per factor

  const District._({
    required this.id, required this.nameEn, required this.nameBn,
    required this.divisionEn, required this.divisionBn,
    required this.lat, required this.lng,
    required this.temperature, required this.humidity, required this.rainfall,
    required this.rain7d, required this.casesThisWeek, required this.isLive,
    required this.daily, required this.riskScore, required this.riskFactors,
  });

  factory District({
    required String id,
    required String nameEn, required String nameBn,
    required String divisionEn, required String divisionBn,
    required double lat, required double lng,
    required double temperature, required double humidity, required double rainfall,
    required int casesThisWeek,
    double? rain7d,
    bool isLive = false,
    List<DailyWeather> daily = const [],
  }) {
    final r7 = rain7d ?? rainfall * 4; // sample estimate when no live data
    final res = RiskModel.compute(
      rain7d: r7, temp: temperature, humidity: humidity, cases: casesThisWeek);
    return District._(
      id: id, nameEn: nameEn, nameBn: nameBn,
      divisionEn: divisionEn, divisionBn: divisionBn, lat: lat, lng: lng,
      temperature: temperature, humidity: humidity, rainfall: rainfall,
      rain7d: r7, casesThisWeek: casesThisWeek, isLive: isLive,
      daily: daily, riskScore: res.score, riskFactors: res.factors,
    );
  }

  /// Same district with fresh weather; risk is recomputed.
  District withWeather({
    required double temperature, required double humidity,
    required double rainfall, required double rain7d,
    required List<DailyWeather> daily,
  }) => District(
    id: id, nameEn: nameEn, nameBn: nameBn, divisionEn: divisionEn,
    divisionBn: divisionBn, lat: lat, lng: lng,
    temperature: temperature, humidity: humidity, rainfall: rainfall,
    casesThisWeek: casesThisWeek, rain7d: rain7d, isLive: true, daily: daily);

  RiskLevel get riskLevel {
    if (riskScore >= 60) return RiskLevel.high;
    if (riskScore >= 30) return RiskLevel.medium;
    return RiskLevel.low;
  }

  /// Forecast rain for today + the coming days (mm).
  double get rainNext7d =>
      daily.where((d) => !d.isPast).fold<double>(0, (a, d) => a + d.rain);

  String name(bool bn) => bn ? nameBn : nameEn;
  String division(bool bn) => bn ? divisionBn : divisionEn;
}
