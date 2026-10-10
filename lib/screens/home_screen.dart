import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:google_fonts/google_fonts.dart";
import "package:url_launcher/url_launcher.dart";
import "../providers/app_provider.dart";
import "../theme/app_theme.dart";
import "../models/district.dart";
import "../services/dengue_scraper.dart";
import "../services/risk_explainer.dart";
import "../services/risk_model.dart";
import "../l10n/strings.dart";
import "../widgets/district_card.dart";
import "../widgets/live_banner.dart";
import "../widgets/area_picker.dart";
import "about_screen.dart";
import "settings_screen.dart";
import "report_screen.dart";
import "learn_screen.dart";
import "hospital_screen.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = "";
  int _sort = 0; // 0 = highest risk first, 1 = A-Z

  void _openHospitals(BuildContext context, AppProvider p, District d) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => HospitalScreen(
        district: d, bn: p.isBengali,
        userLat: p.userLocation?.lat, userLng: p.userLocation?.lng)));
  }

  Future<void> _call(String number) async {
    final uri = Uri(scheme: "tel", path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  List<District> _visibleDistricts(AppProvider p) {
    final q = _query.trim().toLowerCase();
    final list = p.districts.where((d) =>
      q.isEmpty || d.nameEn.toLowerCase().contains(q) || d.nameBn.contains(q) ||
      d.divisionEn.toLowerCase().contains(q)).toList();
    if (_sort == 0) {
      list.sort((a, b) => b.riskScore.compareTo(a.riskScore));
    } else {
      list.sort((a, b) => p.isBengali ? a.nameBn.compareTo(b.nameBn) : a.nameEn.compareTo(b.nameEn));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final s = p.s;
    final bn = p.isBengali;
    final focus = p.focusDistrict;
    final isMine = p.myDistrict != null;
    final visible = _visibleDistricts(p);

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: RefreshIndicator(
        color: AppColors.teal,
        onRefresh: p.refresh,
        child: CustomScrollView(slivers: [
          SliverAppBar(
            pinned: true,
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
                  child: Text(bn ? "EN" : "বাং",
                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.gold, fontWeight: FontWeight.w600)),
                ),
              ),
              IconButton(
                tooltip: bn ? "সেটিংস" : "Settings",
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => AboutScreen(bn: bn))),
              ),
            ],
          ),

          SliverToBoxAdapter(child: Column(children: [
            _AreaBanner(p: p),
            _HeroCard(
              district: focus, bn: bn, s: s, isMine: isMine,
              onHospital: () => _openHospitals(context, p, focus)),
            _QuickActions(
              bn: bn,
              onSymptoms: () => p.setTab(2),
              onHospitals: () => _openHospitals(context, p, focus),
              onReport: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ReportCaseScreen())),
              onCall: () => _call("16263")),
            const SizedBox(height: 4),
            LiveBanner(
              weatherLive: p.weatherLive,
              dgshLive: p.dengueData?.isLive ?? false,
              weatherTimeAgo: p.weatherTimeAgo,
              dgshTimeAgo: p.dgshTimeAgo,
              isLoading: p.isLoadingWeather,
              bn: bn,
            ),
            if (p.dengueData != null) _NationalCard(data: p.dengueData!, bn: bn),
            _WeatherStrip(district: focus, bn: bn, s: s),
            _OutlookCard(district: focus, bn: bn),
            _FactorsCard(district: focus, bn: bn, s: s),
            _TrendCard(values: p.trendFor(focus.id), districtName: focus.name(bn), bn: bn),
            _LearnTile(bn: bn),
            _TipsCard(s: s),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(children: [
                Expanded(child: Text(s.allDistricts,
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink))),
                _SortChip(label: bn ? "ঝুঁকি" : "Risk", selected: _sort == 0, onTap: () => setState(() => _sort = 0)),
                const SizedBox(width: 6),
                _SortChip(label: "A–Z", selected: _sort == 1, onTap: () => setState(() => _sort = 1)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: InputDecoration(
                  hintText: bn ? "জেলা বা বিভাগ খুঁজুন…" : "Search district or division…",
                  hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.slate),
                  prefixIcon: Icon(Icons.search, size: 20, color: AppColors.slate),
                  filled: true, fillColor: AppColors.cardBg,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border)),
                ),
              ),
            ),
          ])),

          if (visible.isEmpty)
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(child: Text(bn ? "কিছু পাওয়া যায়নি" : "No districts match your search",
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.slate))),
            ))
          else
            SliverList(delegate: SliverChildBuilderDelegate(
              (_, i) {
                if (i == visible.length) return const SizedBox(height: 20);
                return DistrictCard(
                  d: visible[i], bn: bn,
                  onTap: () => _openHospitals(context, p, visible[i]));
              },
              childCount: visible.length + 1,
            )),
        ]),
      ),
    );
  }
}

// ───────────────────────── area banner ─────────────────────────
class _AreaBanner extends StatelessWidget {
  final AppProvider p;
  const _AreaBanner({required this.p});

  @override
  Widget build(BuildContext context) {
    final bn = p.isBengali;
    final mine = p.myDistrict;

    String text;
    if (p.locating && mine == null) {
      text = bn ? "আপনার অবস্থান খোঁজা হচ্ছে..." : "Detecting your location...";
    } else if (mine != null) {
      final km = p.gpsDistanceKm;
      if (km != null && km > 50) {
        text = bn ? "নিকটতম পর্যবেক্ষিত জেলা: ${mine.nameBn} (~${km.round()} কিমি)"
                  : "Nearest monitored district: ${mine.nameEn} (~${km.round()} km)";
      } else {
        text = bn ? "আপনার এলাকা: ${mine.nameBn}" : "Your area: ${mine.nameEn}";
      }
    } else {
      text = bn ? "অবস্থান পাওয়া যায়নি — এলাকা বাছাই করুন" : "Location unavailable — choose your area";
    }

    return GestureDetector(
      onTap: () => showAreaPicker(context),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.tealLight, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.tealMid),
        ),
        child: Row(children: [
          if (p.locating && mine == null)
            SizedBox(width: 14, height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal))
          else
            Icon(mine != null ? Icons.location_on : Icons.location_off_outlined,
              size: 16, color: AppColors.teal),
          const SizedBox(width: 8),
          Expanded(child: Text(text,
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.teal, fontWeight: FontWeight.w500))),
          if (mine != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(4)),
              child: Text(p.usingManualArea ? (bn ? "ম্যানুয়াল" : "MANUAL") : "GPS",
                style: GoogleFonts.poppins(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          Text(bn ? "পরিবর্তন" : "Change",
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.teal, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

// ───────────────────────── hero card ─────────────────────────
class _HeroCard extends StatelessWidget {
  final District district;
  final S s;
  final bool bn, isMine;
  final VoidCallback onHospital;
  const _HeroCard({required this.district, required this.bn, required this.s,
    required this.isMine, required this.onHospital});

  Color get bgColor {
    if (district.riskLevel == RiskLevel.high) return AppColors.danger;
    if (district.riskLevel == RiskLevel.medium) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final label = isMine ? s.yourArea : (bn ? "বর্তমানে সবচেয়ে ঝুঁকিপূর্ণ" : "Highest risk right now");
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: bgColor.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
          const Spacer(),
          if (!district.isLive)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
              child: Text(bn ? "নমুনা ডেটা" : "Sample data",
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.white)),
            ),
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
              district.riskLevel == RiskLevel.high ? s.highRisk
                : district.riskLevel == RiskLevel.medium ? s.mediumRisk : s.lowRisk,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 4),
            Text(riskReasons(district, bn).first,
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

// ───────────────────────── quick actions ─────────────────────────
class _QuickActions extends StatelessWidget {
  final bool bn;
  final VoidCallback onSymptoms, onHospitals, onReport, onCall;
  const _QuickActions({required this.bn, required this.onSymptoms,
    required this.onHospitals, required this.onReport, required this.onCall});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Row(children: [
      _QA(Icons.medical_information, bn ? "উপসর্গ পরীক্ষা" : "Check symptoms", AppColors.teal, onSymptoms),
      const SizedBox(width: 8),
      _QA(Icons.local_hospital, bn ? "হাসপাতাল" : "Hospitals", AppColors.ink, onHospitals),
      const SizedBox(width: 8),
      _QA(Icons.edit_note, bn ? "কেস রিপোর্ট" : "Report case", AppColors.gold, onReport),
      const SizedBox(width: 8),
      _QA(Icons.call, bn ? "১৬২৬৩ কল" : "Call 16263", AppColors.danger, onCall),
    ]),
  );
}

class _QA extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QA(this.icon, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => Expanded(child: InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(label, textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ]),
    ),
  ));
}

// ───────────────────────── national stats ─────────────────────────
class _NationalCard extends StatelessWidget {
  final DengueData data;
  final bool bn;
  const _NationalCard({required this.data, required this.bn});

  String _fmt(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(",");
      b.write(s[i]);
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final String status;
    if (data.isSample) {
      status = bn ? "নমুনা সংখ্যা — লাইভ উৎস পাওয়া যায়নি" : "Sample figures — live source unavailable";
    } else if (data.isLive) {
      status = bn ? "সূত্র: ${data.source} (এইমাত্র)" : "Source: ${data.source} (just now)";
    } else {
      status = bn ? "সূত্র: ${data.source} (সংরক্ষিত)" : "Source: ${data.source} (saved earlier)";
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.public, size: 18, color: AppColors.teal),
          const SizedBox(width: 8),
          Text(bn ? "জাতীয় চিত্র (এই বছর)" : "National picture (this year)",
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _Stat(_fmt(data.totalCasesThisYear), bn ? "মোট কেস" : "Cases", AppColors.ink),
          _Stat(_fmt(data.totalDeathsThisYear), bn ? "মৃত্যু" : "Deaths", AppColors.danger),
          if (data.casesThisWeek != null)
            _Stat(_fmt(data.casesThisWeek!), bn ? "এই সপ্তাহে" : "This week", AppColors.teal),
        ]),
        const SizedBox(height: 10),
        Text(status, style: GoogleFonts.poppins(
          fontSize: 10.5, color: data.isSample ? AppColors.gold : AppColors.slate)),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _Stat(this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
    Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.slate)),
  ]));
}

// ───────────────────────── weather strip ─────────────────────────
class _WeatherStrip extends StatelessWidget {
  final District district;
  final S s;
  final bool bn;
  const _WeatherStrip({required this.district, required this.bn, required this.s});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.cardBg, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border, width: 0.8),
    ),
    child: Row(children: [
      Flexible(child: Text(s.todayWeather,
        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink))),
      const Spacer(),
      _WChip("🌡", "${district.temperature.toStringAsFixed(1)}°C"),
      const SizedBox(width: 10),
      _WChip("💧", "${district.humidity.toInt()}%"),
      const SizedBox(width: 10),
      _WChip("🌧", "${district.rainfall.toStringAsFixed(1)}mm"),
    ]),
  );
}

class _WChip extends StatelessWidget {
  final String icon, value;
  const _WChip(this.icon, this.value);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Text(icon, style: const TextStyle(fontSize: 14)),
    const SizedBox(width: 3),
    Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.slate)),
  ]);
}

// ───────────────────────── rainfall outlook ─────────────────────────
class _OutlookCard extends StatelessWidget {
  final District district;
  final bool bn;
  const _OutlookCard({required this.district, required this.bn});

  String _advice() {
    if (district.rainNext7d >= 50) {
      return bn ? "ভারী বৃষ্টির পূর্বাভাস: জমে থাকা পানি মশার প্রজনন বাড়াতে পারে। এখনই পানির পাত্র খালি করুন।"
                : "Heavy rain forecast: standing water can breed mosquitoes. Empty containers now.";
    }
    if (district.rain7d >= 50) {
      return bn ? "সাম্প্রতিক ভারী বৃষ্টি — ফুলের টব, টায়ার ও বালতিতে জমা পানি পরীক্ষা করুন।"
                : "Recent heavy rain — check pots, tyres and buckets for standing water.";
    }
    return bn ? "প্রতি সপ্তাহে একবার বাড়ির আশেপাশের পানির পাত্র খালি করুন।"
              : "Empty water containers around your home at least once a week.";
  }

  @override
  Widget build(BuildContext context) {
    final days = district.daily;
    final maxRain = days.isEmpty
        ? 1.0
        : days.map((d) => d.rain).reduce((a, b) => a > b ? a : b).clamp(5.0, 500.0).toDouble();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.water_drop_outlined, size: 18, color: Color(0xFF1565C0)),
          const SizedBox(width: 8),
          Expanded(child: Text(bn ? "বৃষ্টিপাত: গত ৭ দিন ও আগামী ৭ দিন" : "Rainfall: past 7 & next 7 days",
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink))),
        ]),
        const SizedBox(height: 12),
        if (days.isEmpty)
          Text(bn ? "পূর্বাভাস পেতে ইন্টারনেট সংযোগ দিন।" : "Connect to the internet to load the forecast.",
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.slate))
        else ...[
          SizedBox(
            height: 90,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 0; i < days.length; i++)
                  Expanded(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Container(
                        height: 4 + 56 * (days[i].rain / maxRain),
                        decoration: BoxDecoration(
                          color: days[i].isPast
                              ? AppColors.tealMid
                              : (i == 7 ? AppColors.gold : const Color(0xFF64B5F6)),
                          borderRadius: BorderRadius.circular(3)),
                      ),
                      const SizedBox(height: 4),
                      Text("${days[i].date.day}",
                        style: GoogleFonts.poppins(fontSize: 9,
                          color: i == 7 ? AppColors.gold : AppColors.slate,
                          fontWeight: i == 7 ? FontWeight.w700 : FontWeight.w400)),
                    ]),
                  )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            _Legend(AppColors.tealMid, bn ? "গত" : "Past"),
            const SizedBox(width: 10),
            _Legend(AppColors.gold, bn ? "আজ" : "Today"),
            const SizedBox(width: 10),
            _Legend(const Color(0xFF64B5F6), bn ? "পূর্বাভাস" : "Forecast"),
            const Spacer(),
            Text("${district.rain7d.round()} mm → ${district.rainNext7d.round()} mm",
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.ink)),
          ]),
        ],
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(8)),
          child: Text(_advice(), style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.teal)),
        ),
      ]),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String text;
  const _Legend(this.color, this.text);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 4),
    Text(text, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.slate)),
  ]);
}

// ───────────────────────── how the score is built ─────────────────────────
class _FactorsCard extends StatelessWidget {
  final District district;
  final S s;
  final bool bn;
  const _FactorsCard({required this.district, required this.bn, required this.s});

  static const _bnNames = {
    "Rainfall": "বৃষ্টিপাত", "Temperature": "তাপমাত্রা",
    "Humidity": "আর্দ্রতা", "Reported cases": "রিপোর্টকৃত কেস",
  };

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cardBg, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border, width: 0.8),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.auto_graph, size: 18, color: AppColors.teal),
        const SizedBox(width: 8),
        Expanded(child: Text(s.whyRisk,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(6)),
          child: Text(bn ? "নিয়ম-ভিত্তিক" : "RULE-BASED",
            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.teal, fontWeight: FontWeight.w600)),
        ),
      ]),
      const SizedBox(height: 12),
      ...district.riskFactors.entries.map((e) {
        final max = RiskModel.weights[e.key] ?? 1;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(bn ? (_bnNames[e.key] ?? e.key) : e.key,
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.slate)),
              const Spacer(),
              Text("+${e.value.round()} / ${max.round()}",
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink)),
            ]),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: (e.value / max).clamp(0.0, 1.0).toDouble(),
                backgroundColor: AppColors.lightGray,
                valueColor: AlwaysStoppedAnimation(AppColors.teal),
                minHeight: 6,
              ),
            ),
          ]),
        );
      }),
      const SizedBox(height: 2),
      Text(
        bn ? "এটি আবহাওয়া ও কেস-ভিত্তিক একটি সহজ সূচক, চিকিৎসাগত পূর্বাভাস নয়।"
           : "A simple weather + cases index to raise awareness — not a clinical forecast.",
        style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.slate)),
    ]),
  );
}

// ───────────────────────── tips ─────────────────────────
class _TipsCard extends StatelessWidget {
  final S s;
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
        Icon(Icons.shield_outlined, size: 18, color: AppColors.teal),
        const SizedBox(width: 8),
        Text(s.preventionTip, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.teal)),
      ]),
      const SizedBox(height: 10),
      ...[s.tip1, s.tip2, s.tip3, s.tip4, s.tip5].map((t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("▸ ", style: TextStyle(color: AppColors.teal, fontSize: 13)),
          Expanded(child: Text(t, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.teal))),
        ]),
      )),
    ]),
  );
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SortChip({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: selected ? AppColors.chipSelected : AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selected ? AppColors.chipSelected : AppColors.border),
      ),
      child: Text(label, style: GoogleFonts.poppins(
        fontSize: 11, fontWeight: FontWeight.w500,
        color: selected ? Colors.white : AppColors.slate)),
    ),
  );
}

// ───────────────────────── 14-day trend ─────────────────────────
class _TrendCard extends StatelessWidget {
  final List<int?> values;
  final String districtName;
  final bool bn;
  const _TrendCard({required this.values, required this.districtName, required this.bn});

  @override
  Widget build(BuildContext context) {
    final known = [for (final v in values) if (v != null) v];
    String summary;
    if (known.length < 2) {
      summary = bn
          ? "ট্রেন্ড তৈরি হয় আপনি অ্যাপ ব্যবহার করার সাথে সাথে (এখন পর্যন্ত ${known.length} দিনের তথ্য)।"
          : "The trend builds up as you use the app (${known.length} day recorded so far).";
    } else {
      final delta = known.last - known.first;
      final word = delta > 0 ? (bn ? "বেড়েছে" : "up") : (bn ? "কমেছে" : "down");
      summary = delta == 0
          ? (bn ? "ঝুঁকি অপরিবর্তিত (${known.last}/100)" : "Risk unchanged at ${known.last}/100")
          : (bn ? "ঝুঁকি ${delta.abs()} পয়েন্ট $word (${known.first} → ${known.last})"
                : "Risk $word ${delta.abs()} points (${known.first} → ${known.last})");
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.show_chart, size: 18, color: AppColors.teal),
          const SizedBox(width: 8),
          Expanded(child: Text(
            bn ? "ঝুঁকির ট্রেন্ড — ১৪ দিন ($districtName)" : "Risk trend — 14 days ($districtName)",
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink))),
        ]),
        const SizedBox(height: 12),
        if (known.length >= 2)
          SizedBox(
            height: 90,
            width: double.infinity,
            child: CustomPaint(painter: _TrendPainter(
              values: values,
              line: AppColors.teal,
              grid: AppColors.border,
              high: AppColors.danger,
              medium: AppColors.warning,
            )),
          ),
        if (known.length >= 2) const SizedBox(height: 6),
        if (known.length >= 2)
          Row(children: [
            _Legend(AppColors.danger, bn ? "উচ্চ ≥৬০" : "High ≥60"),
            const SizedBox(width: 10),
            _Legend(AppColors.warning, bn ? "মাঝারি ≥৩০" : "Medium ≥30"),
          ]),
        const SizedBox(height: 8),
        Text(summary, style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.slate)),
        const SizedBox(height: 2),
        Text(bn ? "ডেটা শুধু এই ফোনে রেকর্ড করা হয়।" : "History is recorded on this phone only.",
          style: GoogleFonts.poppins(fontSize: 10, color: AppColors.slate)),
      ]),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<int?> values;
  final Color line, grid, high, medium;
  _TrendPainter({required this.values, required this.line, required this.grid,
    required this.high, required this.medium});

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 6.0;
    final h = size.height - pad * 2;
    double yOf(num v) => pad + h * (1 - v / 100);

    canvas.drawLine(Offset(0, yOf(60)), Offset(size.width, yOf(60)),
      Paint()..color = high.withOpacity(0.45)..strokeWidth = 1);
    canvas.drawLine(Offset(0, yOf(30)), Offset(size.width, yOf(30)),
      Paint()..color = medium.withOpacity(0.45)..strokeWidth = 1);
    canvas.drawLine(Offset(0, yOf(0)), Offset(size.width, yOf(0)),
      Paint()..color = grid..strokeWidth = 1);

    final n = values.length;
    if (n < 2) return;
    final dx = size.width / (n - 1);
    final pts = <Offset>[];
    for (int i = 0; i < n; i++) {
      final v = values[i];
      if (v != null) pts.add(Offset(dx * i, yOf(v)));
    }
    if (pts.length >= 2) {
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final pt in pts.skip(1)) { path.lineTo(pt.dx, pt.dy); }
      canvas.drawPath(path, Paint()
        ..color = line
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round);
    }
    final dot = Paint()..color = line;
    for (final pt in pts) { canvas.drawCircle(pt, 3.2, dot); }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) => true;
}

// ───────────────────────── facts & myths entry ─────────────────────────
class _LearnTile extends StatelessWidget {
  final bool bn;
  const _LearnTile({required this.bn});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: InkWell(
      onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => const LearnScreen())),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBg, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.8)),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.tealLight, shape: BoxShape.circle),
            child: Icon(Icons.menu_book_outlined, size: 20, color: AppColors.teal)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(bn ? "ডেঙ্গু: তথ্য ও ভুল ধারণা" : "Dengue facts & myths",
              style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.ink)),
            Text(bn ? "উপসর্গ, ধাপ ও সাধারণ ভুল ধারণা" : "Symptoms, illness stages and common myths",
              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.slate)),
          ])),
          Icon(Icons.chevron_right, color: AppColors.slate),
        ]),
      ),
    ),
  );
}
