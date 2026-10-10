import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";
import "package:google_fonts/google_fonts.dart";
import "package:url_launcher/url_launcher.dart";
import "../providers/app_provider.dart";
import "../theme/app_theme.dart";
import "../models/case_report.dart";

String _fmtDate(DateTime d) =>
    "${d.year.toString().padLeft(4, "0")}-${d.month.toString().padLeft(2, "0")}-${d.day.toString().padLeft(2, "0")}";

String _districtName(AppProvider p, String id, bool bn) {
  for (final d in p.districts) { if (d.id == id) return d.name(bn); }
  return id;
}

String _symptomLabel(String key, bool bn) {
  final v = kReportSymptoms[key];
  if (v == null) return key;
  return (bn ? v[1] : v[0]) as String;
}

String _testLabel(String t, bool bn) => switch (t) {
  "positive" => bn ? "পজিটিভ" : "Positive",
  "negative" => bn ? "নেগেটিভ" : "Negative",
  _ => bn ? "পরীক্ষা হয়নি" : "Not tested",
};

// ═════════════════════════ Report form ═════════════════════════
class ReportCaseScreen extends StatefulWidget {
  const ReportCaseScreen({super.key});
  @override
  State<ReportCaseScreen> createState() => _ReportCaseScreenState();
}

class _ReportCaseScreenState extends State<ReportCaseScreen> {
  bool _forSelf = true;
  late String _districtId;
  DateTime _onset = DateTime.now();
  final Set<String> _symptoms = {};
  String _test = "none";
  bool _hospitalised = false;
  bool _withLocation = false;
  final _note = TextEditingController();

  @override
  void initState() {
    super.initState();
    _districtId = context.read<AppProvider>().focusDistrict.id;
  }

  @override
  void dispose() { _note.dispose(); super.dispose(); }

  bool get _hasWarning =>
      _symptoms.any((k) => (kReportSymptoms[k]?[2] as bool?) ?? false);

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _onset,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now,
    );
    if (d != null) setState(() => _onset = d);
  }

  Future<void> _call() async {
    final uri = Uri(scheme: "tel", path: "16263");
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _save(AppProvider p) async {
    final bn = p.isBengali;
    if (_symptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(bn ? "অন্তত একটি উপসর্গ বাছাই করুন" : "Please select at least one symptom")));
      return;
    }
    final loc = p.userLocation;
    final report = CaseReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      districtId: _districtId,
      forSelf: _forSelf,
      onset: _onset,
      symptoms: _symptoms.toList(),
      testResult: _test,
      hospitalised: _hospitalised,
      note: _note.text.trim(),
      lat: _withLocation ? loc?.lat : null,
      lng: _withLocation ? loc?.lng : null,
    );
    await p.addReport(report);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(bn ? "এই ফোনে সংরক্ষিত হয়েছে" : "Saved on this phone")));
    Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => const ReportsListScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final bn = p.isBengali;
    final districts = [...p.districts]..sort((a, b) => a.nameEn.compareTo(b.nameEn));
    final hasGps = p.userLocation != null;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: Text(bn ? "কেস রিপোর্ট করুন" : "Report a case",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            tooltip: bn ? "আমার রিপোর্ট" : "My reports",
            icon: Badge(
              isLabelVisible: p.reports.isNotEmpty,
              label: Text("${p.reports.length}"),
              child: const Icon(Icons.history, color: Colors.white)),
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ReportsListScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
        children: [
          // Honest scope note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.goldLight, borderRadius: BorderRadius.circular(10)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_outline, size: 18, color: AppColors.gold),
              const SizedBox(width: 8),
              Expanded(child: Text(
                bn ? "প্রোটোটাইপ: রিপোর্ট শুধু এই ফোনে সংরক্ষিত হয়। এটি স্বাস্থ্য কর্তৃপক্ষের কাছে পাঠানো হয় না এবং চিকিৎসার বিকল্প নয়। অসুস্থ হলে ডাক্তার দেখান বা ১৬২৬৩-এ কল করুন।"
                   : "Prototype: reports are saved only on this phone. They are NOT sent to health authorities and don't replace medical care. If you're unwell, see a doctor or call 16263.",
                style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.ink))),
            ]),
          ),

          if (_hasWarning) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dangerLight, borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.danger)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.warning_amber_rounded, size: 20, color: AppColors.danger),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(bn ? "এগুলো গুরুতর ডেঙ্গুর লক্ষণ হতে পারে — এখনই হাসপাতালে যান।"
                           : "These can be signs of severe dengue — go to a hospital now.",
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.danger)),
                  TextButton.icon(
                    onPressed: _call,
                    icon: const Icon(Icons.call, size: 16),
                    label: Text(bn ? "১৬২৬৩-এ কল করুন" : "Call 16263"),
                    style: TextButton.styleFrom(foregroundColor: AppColors.danger, padding: EdgeInsets.zero)),
                ])),
              ]),
            ),
          ],

          _Label(bn ? "কার জন্য?" : "Who is this for?"),
          Wrap(spacing: 8, children: [
            ChoiceChip(
              label: Text(bn ? "আমার জন্য" : "Myself"),
              selected: _forSelf, onSelected: (_) => setState(() => _forSelf = true)),
            ChoiceChip(
              label: Text(bn ? "অন্য কারও জন্য" : "Someone else"),
              selected: !_forSelf, onSelected: (_) => setState(() => _forSelf = false)),
          ]),

          _Label(bn ? "জেলা" : "District"),
          DropdownButtonFormField<String>(
            value: _districtId,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true, fillColor: AppColors.cardBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.border))),
            items: districts.map((d) => DropdownMenuItem<String>(
              value: d.id, child: Text(d.name(bn), style: GoogleFonts.poppins(fontSize: 13)))).toList(),
            onChanged: (v) { if (v != null) setState(() => _districtId = v); },
          ),

          _Label(bn ? "উপসর্গ শুরুর তারিখ" : "When did symptoms start?"),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(_fmtDate(_onset), style: GoogleFonts.poppins(fontSize: 13)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.teal, side: BorderSide(color: AppColors.teal)),
          ),

          _Label(bn ? "উপসর্গ" : "Symptoms"),
          Wrap(spacing: 8, runSpacing: 4, children: [
            for (final e in kReportSymptoms.entries)
              FilterChip(
                label: Text(_symptomLabel(e.key, bn),
                  style: GoogleFonts.poppins(fontSize: 12, color: (e.value[2] as bool) ? AppColors.danger : null)),
                selected: _symptoms.contains(e.key),
                selectedColor: (e.value[2] as bool) ? AppColors.dangerLight : AppColors.tealMid,
                onSelected: (v) => setState(() {
                  if (v) { _symptoms.add(e.key); } else { _symptoms.remove(e.key); }
                }),
              ),
          ]),

          _Label(bn ? "ডেঙ্গু পরীক্ষার ফল" : "Dengue test result"),
          Wrap(spacing: 8, children: [
            for (final t in ["none", "positive", "negative"])
              ChoiceChip(
                label: Text(_testLabel(t, bn)),
                selected: _test == t, onSelected: (_) => setState(() => _test = t)),
          ]),

          const SizedBox(height: 6),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.teal,
            title: Text(bn ? "হাসপাতালে ভর্তি" : "Admitted to hospital",
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.ink)),
            value: _hospitalised,
            onChanged: (v) => setState(() => _hospitalised = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.teal,
            title: Text(bn ? "আমার GPS অবস্থান সংযুক্ত করুন" : "Attach my GPS location",
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.ink)),
            subtitle: Text(
              hasGps ? (bn ? "ঐচ্ছিক — শুধু এই ফোনে থাকবে" : "Optional — stays on this phone")
                     : (bn ? "GPS অবস্থান পাওয়া যায়নি" : "GPS location not available"),
              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.slate)),
            value: _withLocation && hasGps,
            onChanged: hasGps ? (v) => setState(() => _withLocation = v) : null,
          ),

          _Label(bn ? "নোট (ঐচ্ছিক)" : "Note (optional)"),
          TextField(
            controller: _note,
            maxLength: 200, maxLines: 3,
            style: GoogleFonts.poppins(fontSize: 13),
            decoration: InputDecoration(
              hintText: bn ? "নাম বা ফোন নম্বর লিখবেন না" : "Please don't include names or phone numbers",
              hintStyle: GoogleFonts.poppins(fontSize: 12, color: AppColors.slate),
              filled: true, fillColor: AppColors.cardBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.border))),
          ),

          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: () => _save(p),
            icon: const Icon(Icons.save_alt),
            label: Text(bn ? "এই ফোনে সংরক্ষণ করুন" : "Save on this phone",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          )),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Text(text, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
  );
}

// ═════════════════════════ Saved reports ═════════════════════════
class ReportsListScreen extends StatelessWidget {
  const ReportsListScreen({super.key});

  String _asText(AppProvider p, CaseReport r) {
    final b = StringBuffer()
      ..writeln("DengueShield BD – case report (${_fmtDate(r.createdAt)})")
      ..writeln("District: ${_districtName(p, r.districtId, false)}")
      ..writeln("Case for: ${r.forSelf ? "Myself" : "Someone else"}")
      ..writeln("Symptoms started: ${_fmtDate(r.onset)}")
      ..writeln("Symptoms: ${r.symptoms.map((k) => _symptomLabel(k, false)).join(", ")}")
      ..writeln("Dengue test: ${_testLabel(r.testResult, false)}")
      ..writeln("Admitted to hospital: ${r.hospitalised ? "Yes" : "No"}");
    if (r.note.isNotEmpty) b.writeln("Note: ${r.note}");
    if (r.lat != null && r.lng != null) {
      b.writeln("Location: ${r.lat!.toStringAsFixed(4)}, ${r.lng!.toStringAsFixed(4)}");
    }
    return b.toString();
  }

  Future<bool> _confirm(BuildContext context, bool bn, String msg) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(bn ? "বাতিল" : "Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(bn ? "মুছুন" : "Delete")),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final bn = p.isBengali;
    final reports = p.reports;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: Text(bn ? "আমার রিপোর্ট" : "My reports",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context)),
        actions: [
          if (reports.isNotEmpty)
            IconButton(
              tooltip: bn ? "সব মুছুন" : "Delete all",
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white),
              onPressed: () async {
                if (await _confirm(context, bn,
                    bn ? "সব রিপোর্ট মুছে ফেলবেন?" : "Delete all saved reports?")) {
                  await p.clearReports();
                }
              },
            ),
        ],
      ),
      body: reports.isEmpty
        ? Center(child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.assignment_outlined, size: 56, color: AppColors.slate),
              const SizedBox(height: 12),
              Text(bn ? "কোনো রিপোর্ট নেই" : "No reports yet",
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink)),
              const SizedBox(height: 4),
              Text(bn ? "রিপোর্ট শুধু এই ফোনে সংরক্ষিত হয়।" : "Reports are stored on this phone only.",
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.slate)),
            ]),
          ))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (_, i) {
              final r = reports[i];
              final warn = r.symptoms.any((k) => (kReportSymptoms[k]?[2] as bool?) ?? false);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardBg, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: warn ? AppColors.danger : AppColors.border, width: warn ? 1.2 : 0.8)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(_districtName(p, r.districtId, bn),
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink))),
                    Text(_fmtDate(r.createdAt),
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.slate)),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    "${r.forSelf ? (bn ? "নিজের জন্য" : "For myself") : (bn ? "অন্যের জন্য" : "For someone else")} • "
                    "${bn ? "শুরু" : "Started"} ${_fmtDate(r.onset)}",
                    style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.slate)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 6, runSpacing: 6, children: r.symptoms.map((k) {
                    final w = (kReportSymptoms[k]?[2] as bool?) ?? false;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: w ? AppColors.dangerLight : AppColors.tealLight,
                        borderRadius: BorderRadius.circular(10)),
                      child: Text(_symptomLabel(k, bn),
                        style: GoogleFonts.poppins(fontSize: 11, color: w ? AppColors.danger : AppColors.teal)),
                    );
                  }).toList()),
                  const SizedBox(height: 8),
                  Text(
                    "${bn ? "পরীক্ষা" : "Test"}: ${_testLabel(r.testResult, bn)}  •  "
                    "${bn ? "হাসপাতালে ভর্তি" : "Admitted"}: ${r.hospitalised ? (bn ? "হ্যাঁ" : "Yes") : (bn ? "না" : "No")}",
                    style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.ink)),
                  if (r.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(r.note, style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.slate)),
                  ],
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: _asText(p, r)));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(bn ? "কপি হয়েছে" : "Copied to clipboard")));
                        }
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: Text(bn ? "কপি" : "Copy"),
                      style: TextButton.styleFrom(foregroundColor: AppColors.teal)),
                    TextButton.icon(
                      onPressed: () async {
                        if (await _confirm(context, bn, bn ? "এই রিপোর্ট মুছবেন?" : "Delete this report?")) {
                          await p.deleteReport(r.id);
                        }
                      },
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: Text(bn ? "মুছুন" : "Delete"),
                      style: TextButton.styleFrom(foregroundColor: AppColors.danger)),
                  ]),
                ]),
              );
            },
          ),
    );
  }
}
