import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:google_fonts/google_fonts.dart";
import "package:url_launcher/url_launcher.dart";
import "../providers/app_provider.dart";
import "../theme/app_theme.dart";
import "../models/district.dart";
import "../widgets/risk_badge.dart";

class _Question {
  final String en, bn, icon;
  const _Question(this.en, this.bn, this.icon);
}

const _questions = [
  _Question("Do you have a fever (≥38°C)?", "আপনার কি জ্বর আছে (≥38°C)?", "🌡️"),
  _Question("Do you have a severe headache?", "আপনার কি তীব্র মাথাব্যথা আছে?", "🤯"),
  _Question("Do you have pain behind the eyes?", "চোখের পেছনে কি ব্যথা আছে?", "👁️"),
  _Question("Do you have severe muscle or joint pain?", "পেশী বা জয়েন্টে তীব্র ব্যথা আছে?", "🦴"),
  _Question("Do you have a skin rash?", "ত্বকে কি ফুসকুড়ি আছে?", "🔴"),
  _Question("Do you have nausea or vomiting?", "বমি বমি ভাব বা বমি আছে?", "🤢"),
  _Question("Any unusual bleeding (nose, gums, or under skin)?", "অস্বাভাবিক রক্তপাত আছে (নাক, মাড়ি, ত্বকের নিচে)?", "🩸"),
];

class SymptomScreen extends StatefulWidget {
  const SymptomScreen({super.key});
  @override
  State<SymptomScreen> createState() => _SymptomScreenState();
}

class _SymptomScreenState extends State<SymptomScreen> {
  int _step = -1;
  final List<bool?> _answers = List.filled(7, null);

  int get _score => _answers.where((a) => a == true).length;

  RiskLevel get _riskLevel {
    if (_score >= 5) return RiskLevel.high;
    if (_score >= 3) return RiskLevel.medium;
    return RiskLevel.low;
  }

  void _answer(bool val) {
    setState(() {
      _answers[_step] = val;
      if (_step < 6) _step++;
      else _step = 7;
    });
  }

  void _reset() => setState(() {
    _step = -1;
    for (int i = 0; i < 7; i++) _answers[i] = null;
  });

  Future<void> _dialDoctor() async {
    final uri = Uri(scheme: "tel", path: "16263");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final s = p.s;
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: Row(children: [
          const Text("🦟"), const SizedBox(width: 8), Text(s.checkSymptoms),
        ]),
        actions: [
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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _step == -1
          ? _IntroView(s: s, onStart: () => setState(() => _step = 0), key: const ValueKey("intro"))
          : _step == 7
            ? _ResultView(
                key: const ValueKey("result"),
                score: _score,
                level: _riskLevel,
                s: s,
                bn: p.isBengali,
                onRetake: _reset,
                onDial: _dialDoctor,
              )
            : _QuestionView(
                key: ValueKey(_step),
                step: _step,
                total: 7,
                question: _questions[_step],
                bn: p.isBengali,
                s: s,
                onAnswer: _answer,
                onBack: () => setState(() => _step = _step > 0 ? _step - 1 : -1),
              ),
      ),
    );
  }
}

class _IntroView extends StatelessWidget {
  final dynamic s;
  final VoidCallback onStart;
  const _IntroView({required this.s, required this.onStart, super.key});

  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("🦟", style: TextStyle(fontSize: 64)),
      const SizedBox(height: 20),
      Text(s.checkSymptoms,
        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.navy),
        textAlign: TextAlign.center),
      const SizedBox(height: 12),
      Text(s.sympIntro,
        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.slate),
        textAlign: TextAlign.center),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.goldLight, borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.gold),
          const SizedBox(width: 8),
          Expanded(child: Text(s.disclaimer,
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gold))),
        ]),
      ),
      const SizedBox(height: 28),
      SizedBox(width: double.infinity,
        child: ElevatedButton(
          onPressed: onStart,
          child: Text(s.next, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)))),
    ]),
  ));
}

class _QuestionView extends StatelessWidget {
  final int step, total;
  final _Question question;
  final bool bn;
  final dynamic s;
  final void Function(bool) onAnswer;
  final VoidCallback onBack;
  const _QuestionView({required this.step, required this.total, required this.question,
    required this.bn, required this.s, required this.onAnswer, required this.onBack, super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(children: [
      const SizedBox(height: 8),
      Row(children: [
        Text("${step + 1}/$total",
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.slate)),
        const SizedBox(width: 12),
        Expanded(child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (step + 1) / total,
            backgroundColor: AppColors.lightGray,
            valueColor: const AlwaysStoppedAnimation(AppColors.teal),
            minHeight: 7,
          ),
        )),
      ]),
      const SizedBox(height: 40),
      Text(question.icon, style: const TextStyle(fontSize: 56)),
      const SizedBox(height: 20),
      Text(bn ? question.bn : question.en,
        style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w600, color: AppColors.navy),
        textAlign: TextAlign.center),
      const Spacer(),
      Row(children: [
        Expanded(child: OutlinedButton(
          onPressed: () => onAnswer(false),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            side: const BorderSide(color: AppColors.danger),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(s.no, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
        )),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton(
          onPressed: () => onAnswer(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(s.yes, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        )),
      ]),
      const SizedBox(height: 12),
      TextButton(onPressed: onBack,
        child: Text(s.back, style: GoogleFonts.poppins(color: AppColors.slate))),
    ]),
  );
}

class _ResultView extends StatelessWidget {
  final int score;
  final RiskLevel level;
  final dynamic s;
  final bool bn;
  final VoidCallback onRetake;
  final VoidCallback onDial;
  const _ResultView({required this.score, required this.level, required this.s,
    required this.bn, required this.onRetake, required this.onDial, super.key});

  Color get bgColor {
    if (level == RiskLevel.high) return AppColors.danger;
    if (level == RiskLevel.medium) return AppColors.warning;
    return AppColors.success;
  }

  String get recommendation {
    if (level == RiskLevel.high) return bn ? "অনুগ্রহ করে এখনই চিকিৎসা নিন।" : "Please seek medical care immediately.";
    if (level == RiskLevel.medium) return bn ? "২৪ ঘণ্টার মধ্যে ডাক্তারের পরামর্শ নিন।" : "Consult a doctor within 24 hours.";
    return bn ? "স্বাস্থ্য পর্যবেক্ষণ করুন। পানি পান করুন।" : "Monitor your health. Stay hydrated.";
  }

  bool get showDial => level == RiskLevel.high || level == RiskLevel.medium;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(children: [
      const Text("📋", style: TextStyle(fontSize: 56)),
      const SizedBox(height: 16),
      Text(s.result,
        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.navy)),
      const SizedBox(height: 20),

      // Score card
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: bgColor.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Column(children: [
          Text("$score / 7",
            style: GoogleFonts.poppins(fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 4),
          Text(level == RiskLevel.high ? s.highRisk : level == RiskLevel.medium ? s.mediumRisk : s.lowRisk,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        ]),
      ),
      const SizedBox(height: 14),

      // Recommendation box
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.goldLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.info_outline, color: AppColors.gold),
          const SizedBox(width: 10),
          Expanded(child: Text(recommendation,
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.navy))),
        ]),
      ),
      const SizedBox(height: 10),

      // Consult within 24 hours box
      if (level == RiskLevel.medium)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withOpacity(0.4)),
          ),
          child: Row(children: [
            const Icon(Icons.access_time, color: AppColors.warning, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(
              bn ? "২৪ ঘণ্টার মধ্যে ডাক্তারের সাথে যোগাযোগ করুন" : "Please consult a doctor within 24 hours",
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.w500))),
          ]),
        ),

      // Dial 16263 button
      if (showDial) ...[
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onDial,
            icon: const Icon(Icons.call, color: Colors.white),
            label: Text(
              bn ? "ডাক্তারের সাথে কথা বলুন · ১৬২৬৩ ডায়াল করুন" : "Talk to a Doctor · Dial 16263",
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],

      const SizedBox(height: 10),
      // Disclaimer
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(10)),
        child: Text(s.disclaimer,
          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.slate),
          textAlign: TextAlign.center),
      ),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity,
        child: OutlinedButton(
          onPressed: onRetake,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.teal,
            side: const BorderSide(color: AppColors.teal),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(s.retake, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        )),
    ]),
  );
}
