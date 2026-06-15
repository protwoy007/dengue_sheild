import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:google_fonts/google_fonts.dart";
import "../providers/app_provider.dart";
import "../theme/app_theme.dart";
import "../models/district.dart";
import "../widgets/risk_badge.dart";

class _Alert {
  final String nameEn, nameBn, descEn, descBn;
  final RiskLevel level;
  final String time;
  final int cases;
  const _Alert(this.nameEn, this.nameBn, this.descEn, this.descBn, this.level, this.time, this.cases);
}

const _alerts = [
  _Alert("Dhaka", "ঢাকা", "Surge detected in Mirpur, Mohammadpur, Demra", "মিরপুর, মোহাম্মদপুর, ডেমরায় প্রাদুর্ভাব", RiskLevel.high, "2h", 1240),
  _Alert("Narayanganj", "নারায়ণগঞ্জ", "Cases rising sharply — 82% confidence", "কেস দ্রুত বাড়ছে — ৮২% নিশ্চিততা", RiskLevel.high, "4h", 420),
  _Alert("Chittagong", "চট্টগ্রাম", "High mosquito activity post-rainfall", "বৃষ্টির পরে মশার কার্যকলাপ বৃদ্ধি", RiskLevel.high, "6h", 890),
  _Alert("Gazipur", "গাজীপুর", "Moderate increase in dengue fever cases", "ডেঙ্গু জ্বরের মাঝারি বৃদ্ধি", RiskLevel.medium, "1d", 340),
  _Alert("Sylhet", "সিলেট", "Weather conditions favour mosquito breeding", "আবহাওয়া মশার প্রজননের অনুকূল", RiskLevel.medium, "1d", 280),
  _Alert("Mymensingh", "ময়মনসিংহ", "Monitoring elevated. Stay cautious.", "পর্যবেক্ষণ বৃদ্ধি করা হয়েছে।", RiskLevel.medium, "2d", 160),
  _Alert("Barisal", "বরিশাল", "Low-level activity. Monitoring continues.", "নিম্নস্তরের কার্যকলাপ।", RiskLevel.low, "3d", 130),
  _Alert("Khulna", "খুলনা", "Stable. No immediate threat detected.", "স্থিতিশীল। কোনো হুমকি নেই।", RiskLevel.low, "3d", 95),
];

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});
  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  int _filter = 0;

  List<_Alert> get _filtered {
    if (_filter == 0) return _alerts;
    final levels = [RiskLevel.high, RiskLevel.high, RiskLevel.medium, RiskLevel.low];
    return _alerts.where((a) => a.level == levels[_filter]).toList();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final s = p.s;
    final highCount   = _alerts.where((a) => a.level == RiskLevel.high).length;
    final medCount    = _alerts.where((a) => a.level == RiskLevel.medium).length;
    final lowCount    = _alerts.where((a) => a.level == RiskLevel.low).length;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: Row(children: [
          const Text("🦟"), const SizedBox(width: 8), Text(s.recentAlerts),
        ]),
        actions: [
          GestureDetector(
            onTap: p.toggleLanguage,
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gold.withOpacity(0.6)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(p.isBengali ? "EN" : "বাং",
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.gold, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Column(children: [

        // ── Fixed summary strip ──
        Container(
          color: AppColors.navy,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              p.isBengali
                ? "বাংলাদেশ জুড়ে সক্রিয় প্রাদুর্ভাব সতর্কতা"
                : "Active outbreak warnings across Bangladesh",
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54),
            ),
            const SizedBox(height: 8),
            Row(children: [
              _SummaryChip("$highCount", p.isBengali ? "উচ্চ" : "High",     AppColors.danger),
              const SizedBox(width: 8),
              _SummaryChip("$medCount",  p.isBengali ? "মাঝারি" : "Medium", AppColors.warning),
              const SizedBox(width: 8),
              _SummaryChip("$lowCount",  p.isBengali ? "কম" : "Low",        AppColors.success),
            ]),
          ]),
        ),

        // ── Filter chips ──
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            ...[
              p.isBengali ? "সব" : "All",
              p.isBengali ? "উচ্চ" : "High",
              p.isBengali ? "মাঝারি" : "Medium",
              p.isBengali ? "কম" : "Low",
            ].asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _filter = e.key),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: _filter == e.key ? AppColors.navy : AppColors.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _filter == e.key ? AppColors.navy : const Color(0xFFDDE1E7)),
                  ),
                  child: Text(e.value,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _filter == e.key ? Colors.white : AppColors.slate)),
                ),
              ),
            )),
          ]),
        ),

        // ── Alert list ──
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          itemCount: _filtered.length,
          itemBuilder: (_, i) => _AlertCard(a: _filtered[i], bn: p.isBengali, s: s),
        )),
      ]),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String count, label;
  final Color color;
  const _SummaryChip(this.count, this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.18),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(count, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.poppins(fontSize: 11, color: color.withOpacity(0.8))),
    ]),
  );
}

class _AlertCard extends StatelessWidget {
  final _Alert a;
  final bool bn;
  final dynamic s;
  const _AlertCard({required this.a, required this.bn, required this.s});

  Color get leftColor => switch (a.level) {
    RiskLevel.high   => AppColors.danger,
    RiskLevel.medium => AppColors.warning,
    RiskLevel.low    => AppColors.success,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFECEFF1), width: 0.8),
      ),
      child: IntrinsicHeight(child: Row(children: [
        Container(width: 5, decoration: BoxDecoration(
          color: leftColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
        )),
        Expanded(child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(bn ? a.nameBn : a.nameEn,
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.navy))),
              const SizedBox(width: 8),
              RiskBadge(
                level: a.level,
                label: a.level == RiskLevel.high
                  ? (bn ? "উচ্চ" : "HIGH")
                  : a.level == RiskLevel.medium
                    ? (bn ? "মাঝারি" : "MED")
                    : (bn ? "কম" : "LOW")),
            ]),
            const SizedBox(height: 4),
            Text(bn ? a.descBn : a.descEn,
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.slate)),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.access_time, size: 12, color: AppColors.slate),
              const SizedBox(width: 4),
              Text("${a.time} ${bn ? "আগে" : "ago"}",
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.slate)),
              const SizedBox(width: 12),
              const Icon(Icons.local_hospital_outlined, size: 12, color: AppColors.slate),
              const SizedBox(width: 4),
              Text("${a.cases} ${s.casesWeek}",
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.slate)),
            ]),
          ]),
        )),
      ])),
    );
  }
}
