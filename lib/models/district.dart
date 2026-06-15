enum RiskLevel { high, medium, low }

class District {
  final String id;
  final String nameEn;
  final String nameBn;
  final String divisionEn;
  final String divisionBn;
  final double lat;
  final double lng;
  final int riskScore;
  final double temperature;
  final double humidity;
  final double rainfall;
  final int casesThisWeek;
  final Map<String, double> shapFactors;

  const District({
    required this.id,
    required this.nameEn,
    required this.nameBn,
    required this.divisionEn,
    required this.divisionBn,
    required this.lat,
    required this.lng,
    required this.riskScore,
    required this.temperature,
    required this.humidity,
    required this.rainfall,
    required this.casesThisWeek,
    required this.shapFactors,
  });

  RiskLevel get riskLevel {
    if (riskScore >= 60) return RiskLevel.high;
    if (riskScore >= 30) return RiskLevel.medium;
    return RiskLevel.low;
  }

  String name(bool bn) => bn ? nameBn : nameEn;
  String division(bool bn) => bn ? divisionBn : divisionEn;
}
