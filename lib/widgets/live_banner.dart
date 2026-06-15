import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../theme/app_theme.dart";

class LiveBanner extends StatelessWidget {
  final bool weatherLive;
  final bool dgshLive;
  final String weatherTimeAgo;
  final String dgshTimeAgo;
  final bool isLoading;
  final bool bn;

  const LiveBanner({
    super.key,
    required this.weatherLive,
    required this.dgshLive,
    required this.weatherTimeAgo,
    required this.dgshTimeAgo,
    required this.isLoading,
    required this.bn,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.tealLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.tealMid),
        ),
        child: Row(children: [
          const SizedBox(width: 14, height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal)),
          const SizedBox(width: 10),
          Text(bn ? "লাইভ ডেটা লোড হচ্ছে..." : "Fetching live data...",
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.teal)),
        ]),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        _Row(
          icon: Icons.cloud_outlined,
          label: bn ? "আবহাওয়া" : "Weather",
          isLive: weatherLive,
          timeAgo: weatherTimeAgo,
          bn: bn,
        ),
        const SizedBox(height: 6),
        _Row(
          icon: Icons.medical_information_outlined,
          label: bn ? "ডেঙ্গু ডেটা" : "Dengue data",
          isLive: dgshLive,
          timeAgo: dgshTimeAgo,
          bn: bn,
        ),
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLive;
  final String timeAgo;
  final bool bn;
  const _Row({required this.icon, required this.label,
    required this.isLive, required this.timeAgo, required this.bn});

  @override
  Widget build(BuildContext context) {
    final color = isLive ? AppColors.teal : AppColors.slate;
    final bg    = isLive ? AppColors.tealLight : AppColors.lightGray;
    final border= isLive ? AppColors.tealMid : const Color(0xFFDDE1E7);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Row(children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        const SizedBox(width: 6),
        const Spacer(),
        if (isLive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(4)),
            child: Text("LIVE", style: GoogleFonts.poppins(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
          )
        else ...[
          const Icon(Icons.history, size: 12, color: AppColors.slate),
          const SizedBox(width: 4),
          Text(timeAgo, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.slate)),
        ],
      ]),
    );
  }
}
