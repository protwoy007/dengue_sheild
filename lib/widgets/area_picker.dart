import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:provider/provider.dart";
import "../providers/app_provider.dart";
import "../theme/app_theme.dart";
import "risk_badge.dart";

/// Bottom sheet that lets the user pick their district manually or go back to GPS.
Future<void> showAreaPicker(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.cardBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => const _AreaPickerSheet(),
  );
}

class _AreaPickerSheet extends StatelessWidget {
  const _AreaPickerSheet();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final bn = p.isBengali;
    final list = [...p.districts]..sort((a, b) => a.nameEn.compareTo(b.nameEn));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      builder: (ctx, scroll) => Column(children: [
        const SizedBox(height: 10),
        Container(width: 40, height: 4,
          decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(children: [
            Expanded(child: Text(bn ? "আপনার এলাকা বাছাই করুন" : "Choose your area",
              style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink))),
          ]),
        ),
        ListTile(
          leading: Icon(Icons.my_location, color: AppColors.teal),
          title: Text(bn ? "আমার GPS অবস্থান ব্যবহার করুন" : "Use my GPS location",
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.teal)),
          trailing: p.usingManualArea ? null : Icon(Icons.check_circle, color: AppColors.teal),
          onTap: () { p.useGps(); Navigator.pop(context); },
        ),
        const Divider(height: 1),
        Expanded(child: ListView.builder(
          controller: scroll,
          itemCount: list.length,
          itemBuilder: (_, i) {
            final d = list[i];
            final selected = p.manualAreaId == d.id;
            return ListTile(
              title: Text(d.name(bn), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink)),
              subtitle: Text(d.division(bn), style: GoogleFonts.poppins(fontSize: 11, color: AppColors.slate)),
              leading: RiskDot(level: d.riskLevel, size: 12),
              trailing: selected ? Icon(Icons.check_circle, color: AppColors.teal) : Text("${d.riskScore}",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.slate)),
              onTap: () { p.setManualArea(d.id); Navigator.pop(context); },
            );
          },
        )),
      ]),
    );
  }
}
