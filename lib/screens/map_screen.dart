import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:latlong2/latlong.dart";
import "package:provider/provider.dart";
import "package:google_fonts/google_fonts.dart";
import "../providers/app_provider.dart";
import "../theme/app_theme.dart";
import "../models/district.dart";
import "../widgets/risk_badge.dart";

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  District? _selected;
  final _mapController = MapController();

  Color _riskColor(RiskLevel l) => switch (l) {
    RiskLevel.high   => AppColors.danger,
    RiskLevel.medium => AppColors.warning,
    RiskLevel.low    => AppColors.success,
  };

  void _select(District d) {
    setState(() => _selected = d);
    _mapController.move(LatLng(d.lat, d.lng), 9.5);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final s = p.s;
    final userLoc = p.userLocation;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Text("🦟"), const SizedBox(width: 8), Text(s.riskMap),
        ]),
        actions: [
          if (userLoc != null)
            IconButton(
              icon: const Icon(Icons.my_location, color: AppColors.gold),
              onPressed: () => _mapController.move(
                LatLng(userLoc.lat, userLoc.lng), 12.0),
            ),
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
      body: Stack(children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: userLoc != null
              ? LatLng(userLoc.lat, userLoc.lng)
              : const LatLng(23.685, 90.356),
            initialZoom: userLoc != null ? 11.0 : 7.2,
            onTap: (_, __) => setState(() => _selected = null),
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: "com.dengueshield.app",
            ),

            // Risk circles
            CircleLayer(circles: p.districts.map((d) {
              final c = _riskColor(d.riskLevel);
              return CircleMarker(
                point: LatLng(d.lat, d.lng),
                radius: 28000,
                useRadiusInMeter: true,
                color: c.withOpacity(0.22),
                borderColor: c,
                borderStrokeWidth: 1.5,
              );
            }).toList()),

            // District markers
            MarkerLayer(markers: p.districts.map((d) {
              final c = _riskColor(d.riskLevel);
              return Marker(
                point: LatLng(d.lat, d.lng),
                width: 36, height: 36,
                child: GestureDetector(
                  onTap: () => _select(d),
                  child: Container(
                    decoration: BoxDecoration(
                      color: c, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [BoxShadow(color: c.withOpacity(0.5), blurRadius: 8)],
                    ),
                    child: Center(child: Text("${d.riskScore}",
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white))),
                  ),
                ),
              );
            }).toList()),

            // Exact user location marker
            if (userLoc != null)
              MarkerLayer(markers: [
                Marker(
                  point: LatLng(userLoc.lat, userLoc.lng),
                  width: 44, height: 44,
                  child: Stack(alignment: Alignment.center, children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.withOpacity(0.15),
                        border: Border.all(color: Colors.blue.withOpacity(0.4), width: 1),
                      ),
                    ),
                    Container(
                      width: 18, height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 8)],
                      ),
                    ),
                  ]),
                ),
              ]),
          ],
        ),

        // Legend
        Positioned(top: 12, left: 12, child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.94),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFECEFF1)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.legend, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.navy)),
            const SizedBox(height: 6),
            ...[
              [RiskLevel.high,   s.highRisk],
              [RiskLevel.medium, s.mediumRisk],
              [RiskLevel.low,    s.lowRisk],
            ].map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                RiskDot(level: r[0] as RiskLevel, size: 9),
                const SizedBox(width: 6),
                Text(r[1] as String, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.slate)),
              ]),
            )),
            const SizedBox(height: 4),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 9, height: 9,
                decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text("You", style: GoogleFonts.poppins(fontSize: 10, color: AppColors.slate)),
            ]),
          ]),
        )),

        // Tap hint
        if (_selected == null && userLoc == null)
          Positioned(bottom: 14, left: 0, right: 0, child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.navy.withOpacity(0.85),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(s.tapDistrict,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
            ),
          )),

        // District detail sheet
        if (_selected != null)
          Positioned(bottom: 0, left: 0, right: 0,
            child: _DistrictDetail(
              d: _selected!, bn: p.isBengali, s: s,
              onClose: () => setState(() => _selected = null))),
      ]),
    );
  }
}

class _DistrictDetail extends StatelessWidget {
  final District d;
  final bool bn;
  final dynamic s;
  final VoidCallback onClose;
  const _DistrictDetail({required this.d, required this.bn, required this.s, required this.onClose});

  Color get riskColor => switch (d.riskLevel) {
    RiskLevel.high   => AppColors.danger,
    RiskLevel.medium => AppColors.warning,
    RiskLevel.low    => AppColors.success,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 20)],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(d.name(bn),
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navy)),
            Text(d.division(bn),
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.slate)),
          ]),
          const Spacer(),
          RiskBadge(level: d.riskLevel,
            label: d.riskLevel == RiskLevel.high ? s.highRisk
              : d.riskLevel == RiskLevel.medium ? s.mediumRisk : s.lowRisk,
            large: true),
          const SizedBox(width: 8),
          GestureDetector(onTap: onClose,
            child: Container(padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: AppColors.lightGray, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 18, color: AppColors.slate))),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          _StatBox("${d.riskScore}", s.riskScore, riskColor),
          const SizedBox(width: 8),
          _StatBox("${d.temperature.toStringAsFixed(1)}°C", s.temperature, AppColors.teal),
          const SizedBox(width: 8),
          _StatBox("${d.humidity.toInt()}%", s.humidity, AppColors.navy),
          const SizedBox(width: 8),
          _StatBox("${d.rainfall}mm", s.rainfall, const Color(0xFF1565C0)),
        ]),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(10)),
          child: Text("${d.casesThisWeek} ${s.casesWeek}",
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.navy),
            textAlign: TextAlign.center),
        ),
      ]),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatBox(this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Column(children: [
      Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
      Text(label, style: GoogleFonts.poppins(fontSize: 9, color: AppColors.slate), textAlign: TextAlign.center),
    ]),
  ));
}
