/// A locally saved "report a case" entry (prototype: stays on this device).
class CaseReport {
  final String id;
  final DateTime createdAt;
  final String districtId;
  final bool forSelf;
  final DateTime onset;
  final List<String> symptoms;   // keys, see kReportSymptoms
  final String testResult;       // none | positive | negative
  final bool hospitalised;
  final String note;
  final double? lat, lng;        // only when the user opted in

  const CaseReport({
    required this.id, required this.createdAt, required this.districtId,
    required this.forSelf, required this.onset, required this.symptoms,
    required this.testResult, required this.hospitalised, required this.note,
    this.lat, this.lng,
  });

  Map<String, dynamic> toJson() => {
    "id": id, "at": createdAt.toIso8601String(), "d": districtId, "self": forSelf,
    "onset": onset.toIso8601String(), "sym": symptoms, "test": testResult,
    "hosp": hospitalised, "note": note, "lat": lat, "lng": lng,
  };

  factory CaseReport.fromJson(Map<String, dynamic> j) => CaseReport(
    id: j["id"] as String,
    createdAt: DateTime.parse(j["at"] as String),
    districtId: j["d"] as String,
    forSelf: j["self"] as bool,
    onset: DateTime.parse(j["onset"] as String),
    symptoms: (j["sym"] as List).map((e) => e as String).toList(),
    testResult: j["test"] as String,
    hospitalised: j["hosp"] as bool,
    note: (j["note"] as String?) ?? "",
    lat: (j["lat"] as num?)?.toDouble(),
    lng: (j["lng"] as num?)?.toDouble(),
  );
}

/// key -> (English, Bengali, isWarningSign)
const Map<String, List<Object>> kReportSymptoms = {
  "fever": ["Fever", "জ্বর", false],
  "headache": ["Severe headache", "তীব্র মাথাব্যথা", false],
  "eye_pain": ["Pain behind eyes", "চোখের পেছনে ব্যথা", false],
  "joint_pain": ["Muscle / joint pain", "পেশী/জয়েন্টে ব্যথা", false],
  "rash": ["Skin rash", "ফুসকুড়ি", false],
  "nausea": ["Nausea", "বমি বমি ভাব", false],
  "abdominal": ["Severe stomach pain", "তীব্র পেটব্যথা", true],
  "vomiting": ["Repeated vomiting", "বারবার বমি", true],
  "bleeding": ["Bleeding", "রক্তপাত", true],
  "drowsy": ["Drowsy / restless", "ঘুম ঘুম/অস্থির", true],
};
