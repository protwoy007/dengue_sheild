import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:google_fonts/google_fonts.dart";
import "../providers/app_provider.dart";
import "../theme/app_theme.dart";
import "report_screen.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  String _fmtTime(BuildContext context, TimeOfDay t) => t.format(context);

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final bn = p.isBengali;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: Text(bn ? "সেটিংস" : "Settings",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Group(title: bn ? "থিম" : "Appearance", children: [
            Wrap(spacing: 8, runSpacing: 8, children: [
              _ModeChip(
                icon: Icons.brightness_auto,
                label: bn ? "সিস্টেম" : "System",
                selected: p.themeMode == ThemeMode.system,
                onTap: () => p.setThemeMode(ThemeMode.system)),
              _ModeChip(
                icon: Icons.light_mode,
                label: bn ? "লাইট" : "Light",
                selected: p.themeMode == ThemeMode.light,
                onTap: () => p.setThemeMode(ThemeMode.light)),
              _ModeChip(
                icon: Icons.dark_mode,
                label: bn ? "ডার্ক" : "Dark",
                selected: p.themeMode == ThemeMode.dark,
                onTap: () => p.setThemeMode(ThemeMode.dark)),
            ]),
          ]),

          _Group(title: bn ? "ভাষা" : "Language", children: [
            Wrap(spacing: 8, runSpacing: 8, children: [
              _ModeChip(
                icon: Icons.language, label: "English", selected: !bn,
                onTap: () { if (bn) p.toggleLanguage(); }),
              _ModeChip(
                icon: Icons.language, label: "বাংলা", selected: bn,
                onTap: () { if (!bn) p.toggleLanguage(); }),
            ]),
          ]),

          _Group(title: bn ? "দৈনিক সকালের রিমাইন্ডার" : "Daily morning reminder", children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.teal,
              title: Text(bn ? "প্রতিদিন ঝুঁকি দেখার রিমাইন্ডার" : "Remind me to check the risk every day",
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.ink)),
              value: p.reminderOn,
              onChanged: (v) => p.setReminder(on: v),
            ),
            if (p.reminderOn)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.access_time, color: AppColors.teal),
                title: Text(bn ? "সময়" : "Time",
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.ink)),
                trailing: Text(_fmtTime(context, p.reminderTime),
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.teal)),
                onTap: () async {
                  final picked = await showTimePicker(context: context, initialTime: p.reminderTime);
                  if (picked != null) await p.setReminder(on: true, time: picked);
                },
              ),
            Text(
              bn ? "রিমাইন্ডারে সংখ্যা থাকে না — অ্যাপ খুললে সর্বশেষ ঝুঁকি দেখা যায়। সময় বাংলাদেশ সময় (UTC+৬)।"
                 : "The reminder doesn't show numbers (they could be out of date) — it nudges you to open the app. Times are Bangladesh time (UTC+6).",
              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.slate)),
          ]),

          _Group(title: bn ? "আমার ডেটা" : "My data", children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.assignment_outlined, color: AppColors.teal),
              title: Text(bn ? "সংরক্ষিত কেস রিপোর্ট" : "Saved case reports",
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.ink)),
              subtitle: Text(
                bn ? "${p.reports.length} টি — শুধু এই ফোনে" : "${p.reports.length} — on this phone only",
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.slate)),
              trailing: Icon(Icons.chevron_right, color: AppColors.slate),
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ReportsListScreen())),
            ),
          ]),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Group({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cardBg, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border, width: 0.8)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
      const SizedBox(height: 10),
      ...children,
    ]),
  );
}

class _ModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ModeChip({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: selected ? AppColors.chipSelected : AppColors.lightGray,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? AppColors.chipSelected : AppColors.border)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: selected ? Colors.white : AppColors.slate),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.poppins(
          fontSize: 12.5, fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.slate)),
      ]),
    ),
  );
}
