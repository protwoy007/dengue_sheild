import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:google_fonts/google_fonts.dart";
import "../providers/app_provider.dart";
import "../theme/app_theme.dart";
import "../models/district.dart";
import "../services/risk_explainer.dart";
import "../widgets/risk_badge.dart";
import "hospital_screen.dart";

/// Alerts are generated from the CURRENT district risk data (not hardcoded).
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});
  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  int _filter = 0; // 0 all, 1 high, 2 medium, 3 low

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final s = p.s;
    final bn = p.isBengali;

    final all = [...p.districts]..sort((a, b) => b.riskScore.compareTo(a.riskScore));
    int count(RiskLevel l) => all.where((d) => d.riskLevel == l).length;
    final shown = switch (_filter) {
      1 => all.where((d) => d.riskLevel == RiskLevel.high).toList(),
      2 => all.where((d) => d.riskLevel == RiskLevel.medium).toList(),
      3 => all.where((d) => d.riskLevel == RiskLevel.low).toList(),
      _ => all,
    };
    final mine = p.myDistrict;

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
              child: Text(bn ? "EN" : "বাং",
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.gold, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.teal,
        onRefresh: p.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            // Summary tiles
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Row(children: [
                _Tile("${count(RiskLevel.high)}", s.highRisk, AppColors.danger, AppColors.dangerLight),
                const SizedBox(width: 8),
                _Tile("${count(RiskLevel.medium)}", s.mediumRisk, AppColors.warning, AppColors.warningLight),
                const SizedBox(width: 8),
                _Tile("${count(RiskLevel.low)}", s.lowRisk, AppColors.success, AppColors.successLight),
              ]),
            ),

            // Freshness
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(children: [
                Icon(p.weatherLive ? Icons.wifi : Icons.cloud_off, size: 13,
                  color: p.weatherLive ? AppColors.success : AppColors.gold),
                const SizedBox(width: 6),
                Expanded(child: Text(
                  p.weatherLive
                    ? (bn ? "আবহাওয়া আপডেট: ${p.weatherTimeAgo}" : "Weather updated: ${p.weatherTimeAgo}")
                    : (bn ? "অফলাইন — সর্বশেষ সংরক্ষিত ডেটা (${p.weatherTimeAgo})"
                          : "Offline — showing last saved data (${p.weatherTimeAgo})"),
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.slate))),
              ]),
            ),

            // Your area highlight
            if (mine != null && mine.riskLevel != RiskLevel.low)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: mine.riskLevel == RiskLevel.high ? AppColors.dangerLight : AppColors.warningLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: mine.riskLevel == RiskLevel.high ? AppColors.danger : AppColors.warning),
                ),
                child: Row(children: [
                  Icon(Icons.notifications_active, size: 18, color: AppColors.ink),
                  const SizedBox(width: 10),
                  Expanded(child: Text(
                    bn ? "আপনার এলাকা ${mine.nameBn}-এ ঝুঁকি ${mine.riskScore}/100। সতর্ক থাকুন।"
                       : "Risk in your area, ${mine.nameEn}, is ${mine.riskScore}/100. Stay alert.",
                    style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.ink))),
                ]),
              ),

            // Filters
            SizedBox(
              height: 46,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  for (final e in [
                    (0, bn ? "সব" : "All"),
                    (1, s.highRisk), (2, s.mediumRisk), (3, s.lowRisk),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _filter = e.$1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: _filter == e.$1 ? AppColors.chipSelected : AppColors.cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _filter == e.$1 ? AppColors.chipSelected : AppColors.border),
                          ),
                          child: Text(e.$2, style: GoogleFonts.poppins(
                            fontSize: 12, fontWeight: FontWeight.w500,
                            color: _filter == e.$1 ? Colors.white : AppColors.slate)),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            if (shown.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(child: Text(bn ? "এই স্তরে কোনো জেলা নেই" : "No districts at this level",
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.slate))),
              ),

            for (final d in shown)
              _AlertCard(
                d: d, bn: bn, s: s, isMine: mine?.id == d.id,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => HospitalScreen(
                    district: d, bn: bn,
                    userLat: p.userLocation?.lat, userLng: p.userLocation?.lng))),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Text(
                bn ? "ঝুঁকি আবহাওয়া ও (নমুনা) কেস-ভিত্তিক একটি সচেতনতা সূচক। অফিসিয়াল ঘোষণার জন্য DGHS/IEDCR দেখুন।"
                   : "Risk is an awareness index from weather and (sample) case data. For official announcements, check DGHS / IEDCR.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.slate)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String count, label;
  final Color color, bg;
  const _Tile(this.count, this.label, this.color, this.bg);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: bg, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.4))),
    child: Column(children: [
      Text(count, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
      Text(label, textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
    ]),
  ));
}

class _AlertCard extends StatelessWidget {
  final District d;
  final bool bn, isMine;
  final dynamic s;
  final VoidCallback onTap;
  const _AlertCard({required this.d, required this.bn, required this.s,
    required this.isMine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final reasons = riskReasons(d, bn);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shape: isMine
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: AppColors.teal, width: 1.5))
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              RiskDot(level: d.riskLevel, size: 12),
              const SizedBox(width: 8),
              Expanded(child: Text(d.name(bn),
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink))),
              if (isMine)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(6)),
                  child: Text(bn ? "আপনার এলাকা" : "YOUR AREA",
                    style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.teal)),
                ),
              RiskBadge(level: d.riskLevel,
                label: d.riskLevel == RiskLevel.high ? s.highRisk
                  : d.riskLevel == RiskLevel.medium ? s.mediumRisk : s.lowRisk),
            ]),
            const SizedBox(height: 8),
            ...reasons.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text("• $r", style: GoogleFonts.poppins(fontSize: 12, color: AppColors.slate)),
            )),
            const SizedBox(height: 8),
            Row(children: [
              Text("${d.riskScore}/100",
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink)),
              const SizedBox(width: 10),
              Text("${d.casesThisWeek} ${s.casesWeek} (${bn ? "নমুনা" : "sample"})",
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.slate)),
              const Spacer(),
              Icon(d.isLive ? Icons.sensors : Icons.history, size: 12,
                color: d.isLive ? AppColors.success : AppColors.gold),
              const SizedBox(width: 3),
              Text(d.isLive ? (bn ? "লাইভ" : "Live") : (bn ? "নমুনা" : "Sample"),
                style: GoogleFonts.poppins(fontSize: 10, color: AppColors.slate)),
            ]),
          ]),
        ),
      ),
    );
  }
}
