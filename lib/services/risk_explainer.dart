import "../models/district.dart";

/// Plain-language reasons behind a district's score (max 3).
List<String> riskReasons(District d, bool bn) {
  final r = <String>[];
  if (d.rain7d >= 50) {
    r.add(bn ? "গত ৭ দিনে ভারী বৃষ্টি (${d.rain7d.round()} মিমি)"
             : "Heavy rain in the past 7 days (${d.rain7d.round()} mm)");
  }
  if (d.rainNext7d >= 50) {
    r.add(bn ? "আগামী সপ্তাহে আরও বৃষ্টির পূর্বাভাস"
             : "More rain forecast this week");
  }
  if (d.humidity >= 80) {
    r.add(bn ? "উচ্চ আর্দ্রতা (${d.humidity.round()}%)"
             : "High humidity (${d.humidity.round()}%)");
  }
  if (d.temperature >= 26 && d.temperature <= 32) {
    r.add(bn ? "মশার প্রজননের অনুকূল তাপমাত্রা"
             : "Temperature ideal for mosquito breeding");
  }
  if (d.casesThisWeek >= 500) {
    r.add(bn ? "সাম্প্রতিক কেসের সংখ্যা বেশি" : "High number of recent cases");
  }
  if (r.isEmpty) {
    r.add(bn ? "বর্তমান আবহাওয়া মশার প্রজননের জন্য অনুকূল নয়"
             : "Weather currently unfavourable for mosquito breeding");
  }
  return r.take(3).toList();
}
