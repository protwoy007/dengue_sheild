import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:url_launcher/url_launcher.dart";
import "dart:math";
import "../theme/app_theme.dart";
import "../data/hospitals_data.dart";
import "../models/district.dart";

class HospitalScreen extends StatelessWidget {
  final District district;
  final bool bn;
  final double? userLat;
  final double? userLng;
  const HospitalScreen({super.key, required this.district, required this.bn, this.userLat, this.userLng});

  Future<void> _openMaps(Hospital h) async {
    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(h.nameEn)}&ll=${h.lat},${h.lng}"
    );
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // Haversine formula — accurate km distance
  double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLng = (lng2 - lng1) * pi / 180;
    final a = sin(dLat/2)*sin(dLat/2) +
               cos(lat1 * pi/180)*cos(lat2 * pi/180)*sin(dLng/2)*sin(dLng/2);
    final c = 2 * atan2(sqrt(a), sqrt(1-a));
    return r * c;
  }

  String _distanceText(Hospital h) {
    if (userLat == null || userLng == null) return "";
    final km = _haversineKm(userLat!, userLng!, h.lat, h.lng);
    if (km < 1) return "${(km * 1000).toInt()}m";
    return "${km.toStringAsFixed(1)}km";
  }

  @override
  Widget build(BuildContext context) {
    final hospitals = userLat != null
      ? getHospitalsSortedByDistance(district.id, userLat!, userLng!)
      : allHospitals.where((h) => h.districtId == district.id).toList();

    final govtList = hospitals.where((h) => h.isGovt).toList();
    final prvtList = hospitals.where((h) => !h.isGovt).toList();

    // Fix title — use district object directly
    final title = bn
      ? "${district.nameBn} - হাসপাতাল"
      : "${district.nameEn} Hospitals";

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset("assets/app_icon.png", width: 28, height: 28, fit: BoxFit.contain),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(title,
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
            overflow: TextOverflow.ellipsis)),
        ]),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: hospitals.isEmpty
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ClipRRect(borderRadius: BorderRadius.circular(16),
              child: Image.asset("assets/app_icon.png", width: 64, height: 64)),
            const SizedBox(height: 12),
            Text(bn ? "কোনো হাসপাতাল পাওয়া যায়নি" : "No hospitals found",
              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.slate)),
          ]))
        : ListView(padding: const EdgeInsets.all(16), children: [
            // Emergency dial only — 16263 is valid
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.dangerLight, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.danger.withOpacity(0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.emergency, color: AppColors.danger, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(bn ? "স্বাস্থ্য জরুরি হেল্পলাইন" : "Health Emergency Helpline",
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.danger)),
                  Text(bn ? "বিনামূল্যে · ২৪/৭" : "Free · 24/7",
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.danger)),
                ])),
                GestureDetector(
                  onTap: () async {
                    final uri = Uri(scheme: "tel", path: "16263");
                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(8)),
                    child: Text("16263", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ]),
            ),

            if (userLat != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  const Icon(Icons.sort, size: 14, color: AppColors.teal),
                  const SizedBox(width: 6),
                  Text(bn ? "দূরত্ব অনুযায়ী সাজানো হয়েছে" : "Sorted by distance from your location",
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.teal)),
                ]),
              ),

            if (govtList.isNotEmpty) ...[
              _SectionLabel(bn ? "সরকারি হাসপাতাল" : "Government Hospitals"),
              ...govtList.map((h) => _HospitalCard(
                h: h, bn: bn, distance: _distanceText(h),
                onMaps: () => _openMaps(h))),
            ],
            if (prvtList.isNotEmpty) ...[
              const SizedBox(height: 8),
              _SectionLabel(bn ? "বেসরকারি হাসপাতাল" : "Private Hospitals"),
              ...prvtList.map((h) => _HospitalCard(
                h: h, bn: bn, distance: _distanceText(h),
                onMaps: () => _openMaps(h))),
            ],
          ]),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navy)),
  );
}

class _HospitalCard extends StatelessWidget {
  final Hospital h;
  final bool bn;
  final String distance;
  final VoidCallback onMaps;
  const _HospitalCard({required this.h, required this.bn, required this.distance, required this.onMaps});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFECEFF1), width: 0.8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: h.isGovt ? AppColors.tealLight : AppColors.goldLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.local_hospital,
              color: h.isGovt ? AppColors.teal : AppColors.gold, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(bn ? h.nameBn : h.nameEn,
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navy)),
            Row(children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: h.isGovt ? AppColors.tealLight : AppColors.goldLight,
                  borderRadius: BorderRadius.circular(4)),
                child: Text(
                  h.isGovt ? (bn ? "সরকারি" : "Govt") : (bn ? "বেসরকারি" : "Private"),
                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600,
                    color: h.isGovt ? AppColors.teal : AppColors.gold)),
              ),
              if (distance.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(4)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.near_me, size: 9, color: AppColors.slate),
                    const SizedBox(width: 2),
                    Text(distance, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.slate)),
                  ]),
                ),
              ],
            ]),
          ])),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.location_on_outlined, size: 13, color: AppColors.slate),
          const SizedBox(width: 4),
          Expanded(child: Text(h.address,
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.slate))),
        ]),
        const SizedBox(height: 10),
        // Only Google Maps button — no invalid phone numbers
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onMaps,
            icon: const Icon(Icons.map_outlined, size: 15, color: Colors.white),
            label: Text(bn ? "গুগল ম্যাপে দেখুন" : "Open in Google Maps",
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ]),
    );
  }
}
