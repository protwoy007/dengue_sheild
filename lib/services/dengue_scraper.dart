import "package:http/http.dart" as http;
import "package:html/parser.dart" as htmlParser;

class DengueData {
  final int totalCasesThisYear;
  final int totalDeathsThisYear;
  final int? casesThisWeek;       // null when the source didn't state it
  final String source;
  final bool isLive;              // fetched just now
  final bool isSample;            // built-in placeholder numbers
  const DengueData({
    required this.totalCasesThisYear,
    required this.totalDeathsThisYear,
    this.casesThisWeek,
    required this.source,
    this.isLive = false,
    this.isSample = false,
  });

  /// Placeholder numbers shown ONLY when no live or cached data exists.
  static const DengueData fallback = DengueData(
    totalCasesThisYear: 18432, totalDeathsThisYear: 74,
    source: "Sample", isLive: false, isSample: true,
  );

  Map<String, dynamic> toJson() => {
    "c": totalCasesThisYear, "d": totalDeathsThisYear,
    "w": casesThisWeek, "s": source,
  };

  /// Restores a previously fetched (live) record as "cached".
  factory DengueData.fromCache(Map<String, dynamic> j) => DengueData(
    totalCasesThisYear: j["c"] as int,
    totalDeathsThisYear: j["d"] as int,
    casesThisWeek: j["w"] as int?,
    source: j["s"] as String,
    isLive: false, isSample: false,
  );
}

/// Best-effort reader for public DGHS / IEDCR pages. These sites change layout
/// often, so treat results as indicative and keep the "verify at source" hint.
class DengueScraper {
  static const _dghs = "http://103.247.238.81/webportal/pages/dengue.php";
  static const _iedcr = "https://www.iedcr.gov.bd";

  /// Returns live data, or null if every source failed.
  static Future<DengueData?> fetchLatest() async {
    try { final r = await _tryDGHS(); if (r != null) return r; } catch (_) {}
    try { final r = await _tryIEDCR(); if (r != null) return r; } catch (_) {}
    return null;
  }

  static int _num(String s) => int.tryParse(s.replaceAll(",", "")) ?? 0;

  static Future<DengueData?> _tryDGHS() async {
    final response = await http
        .get(Uri.parse(_dghs), headers: {"User-Agent": "Mozilla/5.0"})
        .timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) return null;
    final doc = htmlParser.parse(response.body);
    int total = 0, deaths = 0, week = 0;
    for (final el in doc.querySelectorAll("td, p, span, div")) {
      final text = el.text;
      final cm = RegExp(r"(\d[\d,]+)\s*(cases|patients|admitted)", caseSensitive: false).firstMatch(text);
      if (cm != null) {
        final n = _num(cm.group(1) ?? "0");
        if (n > total && n < 500000) total = n;
      }
      final dm = RegExp(r"(\d+)\s*(death|died)", caseSensitive: false).firstMatch(text);
      if (dm != null) {
        final n = _num(dm.group(1) ?? "0");
        if (n > 0 && n < 10000) deaths = n;
      }
      final wm = RegExp(r"(\d+)\s*(this week|last 7)", caseSensitive: false).firstMatch(text);
      if (wm != null) week = _num(wm.group(1) ?? "0");
    }
    if (total > 0) {
      return DengueData(
        totalCasesThisYear: total, totalDeathsThisYear: deaths,
        casesThisWeek: week > 0 ? week : null,
        source: "DGHS", isLive: true);
    }
    return null;
  }

  static Future<DengueData?> _tryIEDCR() async {
    final response = await http
        .get(Uri.parse(_iedcr), headers: {"User-Agent": "Mozilla/5.0"})
        .timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) return null;
    final doc = htmlParser.parse(response.body);
    int total = 0, deaths = 0;
    for (final el in doc.querySelectorAll("p, td, li, span")) {
      final text = el.text;
      final cm = RegExp(r"(\d[\d,]+)\s*(cases|patients|dengue)", caseSensitive: false).firstMatch(text);
      if (cm != null) {
        final n = _num(cm.group(1) ?? "0");
        if (n > total && n < 500000) total = n;
      }
      final dm = RegExp(r"(\d+)\s*(death|died)", caseSensitive: false).firstMatch(text);
      if (dm != null) {
        final n = _num(dm.group(1) ?? "0");
        if (n > 0 && n < 10000) deaths = n;
      }
    }
    if (total > 0) {
      return DengueData(
        totalCasesThisYear: total, totalDeathsThisYear: deaths,
        source: "IEDCR", isLive: true);
    }
    return null;
  }
}
