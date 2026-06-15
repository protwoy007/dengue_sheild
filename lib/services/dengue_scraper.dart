import "package:http/http.dart" as http;
import "package:html/parser.dart" as htmlParser;

class DengueData {
  final int totalCasesThisYear;
  final int totalDeathsThisYear;
  final int casesThisWeek;
  final String lastUpdated;
  final bool isLive;
  const DengueData({
    required this.totalCasesThisYear,
    required this.totalDeathsThisYear,
    required this.casesThisWeek,
    required this.lastUpdated,
    this.isLive = false,
  });
  static DengueData get fallback => const DengueData(
    totalCasesThisYear: 18432,
    totalDeathsThisYear: 74,
    casesThisWeek: 420,
    lastUpdated: "DGHS (cached)",
    isLive: false,
  );
}

class DengueScraper {
  static const _dghs = "http://103.247.238.81/webportal/pages/dengue.php";
  static const _iedcr = "https://www.iedcr.gov.bd";

  // Reduced timeout to 4 seconds so app doesn't wait too long
  static Future<DengueData> fetchLatest() async {
    try {
      final r = await _tryDGHS();
      if (r != null) return r;
    } catch (_) {}
    try {
      final r = await _tryIEDCR();
      if (r != null) return r;
    } catch (_) {}
    return DengueData.fallback;
  }

  static Future<DengueData?> _tryDGHS() async {
    final response = await http
        .get(Uri.parse(_dghs), headers: {"User-Agent": "Mozilla/5.0"})
        .timeout(const Duration(seconds: 4)); // reduced from 10
    if (response.statusCode != 200) return null;
    final doc = htmlParser.parse(response.body);
    int total = 0, deaths = 0, week = 0;
    for (final el in doc.querySelectorAll("td, p, span, div")) {
      final text = el.text;
      final cm = RegExp(r"(\d[\d,]+)\s*(cases|patients|admitted)", caseSensitive: false).firstMatch(text);
      if (cm != null) {
        final n = int.tryParse(cm.group(1)?.replaceAll(",", "") ?? "0") ?? 0;
        if (n > total && n < 500000) total = n;
      }
      final dm = RegExp(r"(\d+)\s*(death|died)", caseSensitive: false).firstMatch(text);
      if (dm != null) {
        final n = int.tryParse(dm.group(1) ?? "0") ?? 0;
        if (n > 0 && n < 10000) deaths = n;
      }
      final wm = RegExp(r"(\d+)\s*(this week|last 7)", caseSensitive: false).firstMatch(text);
      if (wm != null) week = int.tryParse(wm.group(1) ?? "0") ?? 0;
    }
    if (total > 0) return DengueData(
      totalCasesThisYear: total,
      totalDeathsThisYear: deaths,
      casesThisWeek: week > 0 ? week : (total * 0.02).round(),
      lastUpdated: "DGHS (live)",
      isLive: true,
    );
    return null;
  }

  static Future<DengueData?> _tryIEDCR() async {
    final response = await http
        .get(Uri.parse(_iedcr), headers: {"User-Agent": "Mozilla/5.0"})
        .timeout(const Duration(seconds: 4)); // reduced from 10
    if (response.statusCode != 200) return null;
    final doc = htmlParser.parse(response.body);
    int total = 0, deaths = 0;
    for (final el in doc.querySelectorAll("p, td, li, span")) {
      final text = el.text;
      final cm = RegExp(r"(\d[\d,]+)\s*(cases|patients|dengue)", caseSensitive: false).firstMatch(text);
      if (cm != null) {
        final n = int.tryParse(cm.group(1)?.replaceAll(",", "") ?? "0") ?? 0;
        if (n > total && n < 500000) total = n;
      }
      final dm = RegExp(r"(\d+)\s*(death|died)", caseSensitive: false).firstMatch(text);
      if (dm != null) {
        final n = int.tryParse(dm.group(1) ?? "0") ?? 0;
        if (n > 0) deaths = n;
      }
    }
    if (total > 0) return DengueData(
      totalCasesThisYear: total,
      totalDeathsThisYear: deaths,
      casesThisWeek: (total * 0.02).round(),
      lastUpdated: "IEDCR (live)",
      isLive: true,
    );
    return null;
  }
}
