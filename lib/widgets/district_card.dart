import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../models/district.dart";
import "../theme/app_theme.dart";
import "risk_badge.dart";

class DistrictCard extends StatelessWidget {
  final District d;
  final bool bn;
  final VoidCallback? onTap;
  const DistrictCard({super.key, required this.d, required this.bn, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            _ScoreCircle(score: d.riskScore, level: d.riskLevel),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.name(bn),
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.navy)),
                const SizedBox(height: 2),
                Text(d.division(bn),
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.slate)),
                const SizedBox(height: 6),
                Row(children: [
                  _WeatherChip(icon: Icons.thermostat_outlined, value: "${d.temperature.toStringAsFixed(1)}°C"),
                  const SizedBox(width: 6),
                  _WeatherChip(icon: Icons.water_drop_outlined, value: "${d.humidity.toInt()}%"),
                  const SizedBox(width: 6),
                  _WeatherChip(icon: Icons.umbrella_outlined, value: "${d.rainfall}mm"),
                ]),
              ],
            )),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              RiskBadge(level: d.riskLevel,
                label: bn
                  ? (d.riskLevel == RiskLevel.high ? "উচ্চ" : d.riskLevel == RiskLevel.medium ? "মাঝারি" : "কম")
                  : (d.riskLevel == RiskLevel.high ? "HIGH" : d.riskLevel == RiskLevel.medium ? "MED" : "LOW")),
              const SizedBox(height: 6),
              Text("${d.casesThisWeek} ${bn ? "কেস" : "cases"}",
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.slate)),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _ScoreCircle extends StatelessWidget {
  final int score;
  final RiskLevel level;
  const _ScoreCircle({required this.score, required this.level});

  Color get color => switch (level) {
    RiskLevel.high   => AppColors.danger,
    RiskLevel.medium => AppColors.warning,
    RiskLevel.low    => AppColors.success,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52, height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2.5),
        color: color.withOpacity(0.08),
      ),
      child: Center(child: Text("$score",
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: color))),
    );
  }
}

class _WeatherChip extends StatelessWidget {
  final IconData icon;
  final String value;
  const _WeatherChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 12, color: AppColors.slate),
      const SizedBox(width: 2),
      Text(value, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.slate)),
    ]);
  }
}
