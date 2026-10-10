/// Transparent, rule-based dengue risk index (0-100).
///
/// This is NOT a trained machine-learning model. It combines four inputs with
/// fixed weights so every number on screen can be explained:
///   rainfall (past 7 days) + temperature suitability + humidity + reported cases.
class RiskResult {
  final int score;
  /// Points contributed by each factor (they add up to [score], before rounding).
  final Map<String, double> factors;
  const RiskResult(this.score, this.factors);
}

class RiskModel {
  static const Map<String, double> weights = {
    "Rainfall": 35,
    "Temperature": 15,
    "Humidity": 25,
    "Reported cases": 25,
  };

  static const double _rainFullAt = 90;   // mm in 7 days that maxes the factor
  static const double _humidityFloor = 55; // % below which humidity adds nothing
  static const double _casesFullAt = 800;  // weekly cases that max the factor

  static double _c01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

  /// Aedes mosquitoes breed best at roughly 26-32 °C.
  static double tempSuitability(double t) {
    if (t >= 26 && t <= 32) return 1;
    if (t < 26) return _c01((t - 18) / 8);
    return _c01((38 - t) / 6);
  }

  static RiskResult compute({
    required double rain7d,
    required double temp,
    required double humidity,
    required int cases,
  }) {
    final f = <String, double>{
      "Rainfall": _c01(rain7d / _rainFullAt) * weights["Rainfall"]!,
      "Temperature": tempSuitability(temp) * weights["Temperature"]!,
      "Humidity": _c01((humidity - _humidityFloor) / (95 - _humidityFloor)) * weights["Humidity"]!,
      "Reported cases": _c01(cases / _casesFullAt) * weights["Reported cases"]!,
    };
    final total = f.values.fold<double>(0, (a, b) => a + b);
    return RiskResult(total.round().clamp(0, 100), f);
  }
}
