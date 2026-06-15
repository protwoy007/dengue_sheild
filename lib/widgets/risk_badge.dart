import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../models/district.dart";
import "../theme/app_theme.dart";

class RiskBadge extends StatelessWidget {
  final RiskLevel level;
  final String label;
  final bool large;
  const RiskBadge({super.key, required this.level, required this.label, this.large = false});

  Color get bg => switch (level) {
    RiskLevel.high   => AppColors.dangerLight,
    RiskLevel.medium => AppColors.warningLight,
    RiskLevel.low    => AppColors.successLight,
  };

  Color get fg => switch (level) {
    RiskLevel.high   => AppColors.danger,
    RiskLevel.medium => const Color(0xFFE65100),
    RiskLevel.low    => AppColors.success,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 10,
        vertical: large ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(large ? 10 : 6),
        border: Border.all(color: fg.withOpacity(0.3), width: 0.8),
      ),
      child: Text(label,
        style: GoogleFonts.poppins(
          fontSize: large ? 14 : 11,
          fontWeight: FontWeight.w600,
          color: fg,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class RiskDot extends StatelessWidget {
  final RiskLevel level;
  final double size;
  const RiskDot({super.key, required this.level, this.size = 10});

  Color get color => switch (level) {
    RiskLevel.high   => AppColors.danger,
    RiskLevel.medium => AppColors.warning,
    RiskLevel.low    => AppColors.success,
  };

  @override
  Widget build(BuildContext context) =>
      Container(width: size, height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}
