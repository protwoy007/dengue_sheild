import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:google_fonts/google_fonts.dart";
import "../providers/app_provider.dart";
import "../theme/app_theme.dart";
import "../models/district.dart";
import "../widgets/risk_badge.dart";
import "../widgets/district_card.dart";
import "../widgets/live_banner.dart";
import "about_screen.dart";
import "hospital_screen.dart";

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final s = p.s;
    final top = p.topRisk;
    final userLoc = p.userLocation;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: RefreshIndicator(
        color: AppColors.teal,
        onRefresh: p.refresh,
        child: CustomScrollView(slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 0,
            backgroundColor: AppColors.navy,
            title: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset("assets/app_icon.png", width: 30, height: 30, fit: BoxFit.contain),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(s.appName,
                style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white))),
            ]),
            actions: [
              GestureDetector(
                onTap: p.toggleLanguage,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.gold.withOpacity(0.6)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(p.isBengali ? "EN" : "বাং",
                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.gold, fontWeight: FontWeight.w600)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => AboutScreen(bn: p.isBengali))),
              ),
            ],
          ),

          SliverToBoxAdapter(child: Column(children: [
            if (p.locating)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.tealLight, borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.tealMid),
                ),
                child: Row(children: [
                  const SizedBox(width: 14, height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal)),
                  const SizedBox(width: 10),
                  Text(p.isBengali ? "আপনার অবস্থান খোঁজা হচ্ছে..." : "Detecting your location...",
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.teal)),
                ]),
              )
            else if (userLoc != null)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.tealLight, borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.tealMid),
                ),
                child: Row(children: [
                  const Icon(Icons.location_on, size: 16, color: AppColors.teal),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    p.isBengali
                      ? "আপনার এলাকা: ${userLoc.nearestDistrict.nameBn}"
                      : "Your location: ${userLoc.nearestDistrict.nameEn}",
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.teal, fontWeight: FontWeight.w500))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(4)),
                    child: Text("GPS", style: GoogleFonts.poppins(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ]),
              ),

            _TopRiskCard(
              district: top, bn: p.isBengali, s: s,
              onHospital: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => HospitalScreen(
                  district: top, bn: p.isBengali,
                  userLat: userLoc?.lat, userLng: userLoc?.lng)))),

            const SizedBox(height: 4),
            LiveBanner(
              weatherLive: p.weatherLive,
              dgshLive: p.dengueData?.isLive ?? false,
              weatherTimeAgo: p.weatherTimeAgo,
              dgshTimeAgo: p.dgshTimeAgo,
              isLoading: p.isLoadingWeather,
              bn: p.isBengali,
            ),

            _WeatherStrip(district: top, bn: p.isBengali, s: s),
            _WhyRiskCard(district: top, bn: p.isBengali, s: s),
            _TipsCard(s: s),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(s.allDistricts,
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.navy)),
            ),
          ])),

          if (p.isLoading)
            const SliverToBoxAdapter(child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator(color: AppColors.teal)),
            ))
          else
            SliverList(delegate: SliverChildBuilderDelegate(
              (_, i) {
                if (i == p.districts.length) return const SizedBox(height: 20);
                return DistrictCard(
                  d: p.districts[i], bn: p.isBengali,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => HospitalScreen(
                      district: p.districts[i], bn: p.isBengali,
                      userLat: userLoc?.lat, userLng: userLoc?.lng))),
                );
              },
              childCount: p.districts.length + 1,
            )),
        ]),
      ),
    );
  }
}

class _TopRiskCard extends StatelessWidget {
  final dynamic district, s;
  final bool bn;
  final VoidCallback onHospital;
  const _TopRiskCard({required this.district, required this.bn, required this.s, required this.onHospital});

  Color get bgColor {
    if (district.riskLevel == RiskLevel.high)   return AppColors.danger;
    if (district.riskLevel == RiskLevel.medium) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: bgColor.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(s.yourArea, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
          const Spacer(),
          GestureDetector(
            onTap: onHospital,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.local_hospital, size: 13, color: Colors.white),
                const SizedBox(width: 4),
                Text(bn ? "হাসপাতাল" : "Hospitals",
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.white)),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 6),
        Text(district.name(bn),
          style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
        Text(district.division(bn),
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
        const SizedBox(height: 16),
        Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.riskScore, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
            Text("${district.riskScore}/100",
              style: GoogleFonts.poppins(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white)),
          ]),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              district.riskLevel == RiskLevel.high
                ? (bn ? "উচ্চ ঝুঁকি" : "HIGH RISK")
                : district.riskLevel == RiskLevel.medium
                  ? (bn ? "মাঝারি ঝুঁকি" : "MEDIUM RISK")
                  : (bn ? "কম ঝুঁকি" : "LOW RISK"),
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 4),
            Text("${district.casesThisWeek} ${bn ? 'কেস এই সপ্তাহে' : 'cases this week'}",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
          ])),
        ]),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: district.riskScore / 100,
            backgroundColor: Colors.white30,
            valueColor: const AlwaysStoppedAnimation(Colors.white),
            minHeight: 5,
          ),
        ),
      ]),
    );
  }
}

class _WeatherStrip extends StatelessWidget {
  final dynamic district, s;
  final bool bn;
  const _WeatherStrip({required this.district, required this.bn, required this.s});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.cardBg, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFECEFF1), width: 0.8),
    ),
    child: Row(children: [
      Text(s.todayWeather, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navy)),
      const Spacer(),
      _WChip("🌡", "${district.temperature.toStringAsFixed(1)}°C"),
      const SizedBox(width: 12),
      _WChip("💧", "${district.humidity.toInt()}%"),
      const SizedBox(width: 12),
      _WChip("🌧", "${district.rainfall}mm"),
    ]),
  );
}

class _WChip extends StatelessWidget {
  final String icon, value;
  const _WChip(this.icon, this.value);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Text(icon, style: const TextStyle(fontSize: 14)),
    const SizedBox(width: 4),
    Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.slate)),
  ]);
}

class _WhyRiskCard extends StatelessWidget {
  final dynamic district, s;
  final bool bn;
  const _WhyRiskCard({required this.district, required this.bn, required this.s});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cardBg, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFECEFF1), width: 0.8),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.auto_graph, size: 18, color: AppColors.teal),
        const SizedBox(width: 8),
        Text(s.whyRisk, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navy)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(6)),
          child: Text("SHAP AI", style: GoogleFonts.poppins(fontSize: 10, color: AppColors.teal, fontWeight: FontWeight.w600)),
        ),
      ]),
      const SizedBox(height: 12),
      ...district.shapFactors.entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(e.key, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.slate)),
            const Spacer(),
            Text("${(e.value * 100).toInt()}%",
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navy)),
          ]),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: e.value,
              backgroundColor: AppColors.lightGray,
              valueColor: const AlwaysStoppedAnimation(AppColors.teal),
              minHeight: 6,
            ),
          ),
        ]),
      )),
    ]),
  );
}

class _TipsCard extends StatelessWidget {
  final dynamic s;
  const _TipsCard({required this.s});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.tealLight, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.tealMid, width: 0.8),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.shield_outlined, size: 18, color: AppColors.teal),
        const SizedBox(width: 8),
        Text(s.preventionTip, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.teal)),
      ]),
      const SizedBox(height: 10),
      ...[s.tip1, s.tip2, s.tip3, s.tip4].map((t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("▸ ", style: TextStyle(color: AppColors.teal, fontSize: 13)),
          Expanded(child: Text(t, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.teal))),
        ]),
      )),
    ]),
  );
}
