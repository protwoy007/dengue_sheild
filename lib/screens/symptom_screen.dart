import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:google_fonts/google_fonts.dart";
import "package:url_launcher/url_launcher.dart";
import "../providers/app_provider.dart";
import "../theme/app_theme.dart";
import "../models/district.dart";
import "hospital_screen.dart";

/// kind: 0 = ordinary symptom, 1 = fever, 2 = WARNING SIGN (needs urgent care)
class _Question {
  final String en, bn, icon;
  final int kind;
  const _Question(this.en, this.bn, this.icon, this.kind);
}

const _questions = [
  _Question("Do you have a fever (≥38°C / 100.4°F)?", "আপনার কি জ্বর আছে (≥38°C)?", "🌡️", 1),
  _Question("Do you have a severe headache?", "আপনার কি তীব্র মাথাব্যথা আছে?", "🤯", 0),
  _Question("Do you have pain behind the eyes?", "চোখের পেছনে কি ব্যথা আছে?", "👁️", 0),
  _Question("Do you have severe muscle or joint pain?", "পেশী বা জয়েন্টে তীব্র ব্যথা আছে?", "🦴", 0),
  _Question("Do you have a skin rash?", "ত্বকে কি ফুসকুড়ি আছে?", "🔴", 0),
  _Question("Do you feel nauseous?", "বমি বমি ভাব আছে?", "🤢", 0),
  _Question("Do you have severe, continuous stomach pain?", "পেটে কি তীব্র ও একটানা ব্যথা আছে?", "⚠️", 2),
  _Question("Are you vomiting repeatedly or unable to keep fluids down?", "বারবার বমি হচ্ছে বা পানি পান করে রাখতে পারছেন না?", "⚠️", 2),
  _Question("Any bleeding (nose, gums, black stool, vomit, or heavy bruising)?", "কোনো রক্তপাত আছে (নাক, মাড়ি, কালো পায়খানা, বমি বা ত্বকে কালশিটে)?", "🩸", 2),
  _Question("Do you feel very drowsy, restless, dizzy, or have cold clammy skin?", "খুব ঘুম ঘুম, অস্থির, মাথা ঘোরা বা ঠান্ডা ঘামযুক্ত ত্বক?", "😵", 2),
];

enum _Triage { urgent, soon, monitor }

class SymptomScreen extends StatefulWidget {
  const SymptomScreen({super.key});
  @override
  State<SymptomScreen> createState() => _SymptomScreenState();
}

class _SymptomScreenState extends State<SymptomScreen> {
  int _step = -1; // -1 intro, 0.._questions.length-1 questions, == length => result
  final List<bool?> _answers = List<bool?>.filled(_questions.length, null);

  bool _yes(int i) => _answers[i] == true;

  bool get _fever => [for (int i = 0; i < _questions.length; i++) if (_questions[i].kind == 1 && _yes(i)) i].isNotEmpty;
  int get _otherSymptoms =>
      [for (int i = 0; i < _questions.length; i++) if (_questions[i].kind == 0 && _yes(i)) i].length;
  List<_Question> get _warnings =>
      [for (int i = 0; i < _questions.length; i++) if (_questions[i].kind == 2 && _yes(i)) _questions[i]];

  _Triage get _triage {
    if (_warnings.isNotEmpty) return _Triage.urgent;           // any warning sign => urgent
    if (_fever && _otherSymptoms >= 2) return _Triage.soon;
    if (_otherSymptoms >= 4) return _Triage.soon;
    return _Triage.monitor;
  }

  void _answer(bool val) {
    setState(() {
      _answers[_step] = val;
      _step++;
    });
  }

  void _reset() => setState(() {
    _step = -1;
    for (int i = 0; i < _answers.length; i++) { _answers[i] = null; }
  });

  Future<void> _dial(String number) async {
    final uri = Uri(scheme: "tel", path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final s = p.s;
    final bn = p.isBengali;
    final total = _questions.length;

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
              child: Text(bn ? "EN" : "বাং",
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.gold, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _step == -1
          ? _IntroView(key: const ValueKey("intro"), bn: bn, onStart: () => setState(() => _step = 0))
          : _step >= total
            ? _ResultView(
                key: const ValueKey("result"),
                triage: _triage, bn: bn,
                warnings: _warnings,
                areaName: p.myDistrict?.name(bn),
                areaHigh: p.myDistrict?.riskLevel == RiskLevel.high,
                onRetake: _reset,
                onDial: _dial,
                onHospitals: () {
                  final d = p.focusDistrict;
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => HospitalScreen(
                      district: d, bn: bn,
                      userLat: p.userLocation?.lat, userLng: p.userLocation?.lng)));
                },
              )
            : _QuestionView(
                key: ValueKey(_step),
                step: _step, total: total,
                question: _questions[_step],
                bn: bn, s: s,
                onAnswer: _answer,
                onBack: () => setState(() => _step = _step > 0 ? _step - 1 : -1),
              ),
      ),
    );
  }
}

class _IntroView extends StatelessWidget {
  final bool bn;
  final VoidCallback onStart;
  const _IntroView({required this.bn, required this.onStart, super.key});

  @override
  Widget build(BuildContext context) => Center(child: SingleChildScrollView(child: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("🦟", style: TextStyle(fontSize: 64)),
      const SizedBox(height: 16),
      Text(bn ? "আপনার উপসর্গ পরীক্ষা করুন" : "Check Your Symptoms",
        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.ink),
        textAlign: TextAlign.center),
      const SizedBox(height: 12),
      Text(bn ? "${_questions.length}টি সহজ প্রশ্ন — প্রায় ১ মিনিট লাগবে।"
              : "${_questions.length} quick yes/no questions — about a minute.",
        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.slate), textAlign: TextAlign.center),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(10)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.danger),
          const SizedBox(width: 8),
          Expanded(child: Text(
            bn ? "তীব্র পেটব্যথা, বারবার বমি, রক্তপাত বা অতিরিক্ত দুর্বলতা থাকলে প্রশ্নের জন্য অপেক্ষা না করে এখনই হাসপাতালে যান।"
               : "If you have severe stomach pain, repeated vomiting, bleeding or extreme weakness, go to a hospital now — don't wait to finish this check.",
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.danger))),
        ]),
      ),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.goldLight, borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          Icon(Icons.info_outline, size: 16, color: AppColors.gold),
          const SizedBox(width: 8),
          Expanded(child: Text(
            bn ? "এটি রোগ নির্ণয়ের সরঞ্জাম নয়। সর্বদা ডাক্তারের পরামর্শ নিন।"
               : "This is not a diagnostic tool. Always consult a doctor.",
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gold))),
        ]),
      ),
      const SizedBox(height: 24),
      SizedBox(width: double.infinity, child: ElevatedButton(
        onPressed: onStart,
        child: Text(bn ? "শুরু করুন" : "Start",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
      )),
    ]),
  )));
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
  Widget build(BuildContext context) {
    final isWarn = question.kind == 2;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Row(children: [
          Text("${step + 1} / $total",
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.slate, fontWeight: FontWeight.w500)),
          const SizedBox(width: 12),
          Expanded(child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (step + 1) / total,
              backgroundColor: AppColors.tealMid,
              valueColor: AlwaysStoppedAnimation(isWarn ? AppColors.danger : AppColors.teal),
              minHeight: 6),
          )),
        ]),
        const Spacer(),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.cardBg, borderRadius: BorderRadius.circular(20),
            border: isWarn ? Border.all(color: AppColors.danger.withOpacity(0.5)) : null,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 6))],
          ),
          child: Column(children: [
            if (isWarn)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(10)),
                child: Text(bn ? "সতর্কতা লক্ষণ" : "WARNING SIGN",
                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.danger)),
              ),
            Text(question.icon, style: const TextStyle(fontSize: 52)),
            const SizedBox(height: 18),
            Text(bn ? question.bn : question.en,
              style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.ink),
              textAlign: TextAlign.center),
          ]),
        ),
        const Spacer(),
        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: () => onAnswer(false),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 52),
              side: BorderSide(color: AppColors.slate),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: Text(s.no, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.slate)),
          )),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(
            onPressed: () => onAnswer(true),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 52),
              backgroundColor: isWarn ? AppColors.danger : AppColors.teal),
            child: Text(s.yes, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
          )),
        ]),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onBack,
          child: Text(step == 0 ? (bn ? "বাতিল" : "Cancel") : s.back,
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.slate)),
        ),
      ]),
    );
  }
}

class _ResultView extends StatelessWidget {
  final _Triage triage;
  final bool bn, areaHigh;
  final List<_Question> warnings;
  final String? areaName;
  final VoidCallback onRetake, onHospitals;
  final void Function(String) onDial;
  const _ResultView({required this.triage, required this.bn, required this.warnings,
    required this.areaName, required this.areaHigh, required this.onRetake,
    required this.onDial, required this.onHospitals, super.key});

  Color get color => switch (triage) {
    _Triage.urgent => AppColors.danger,
    _Triage.soon => AppColors.warning,
    _Triage.monitor => AppColors.success,
  };
  Color get bg => switch (triage) {
    _Triage.urgent => AppColors.dangerLight,
    _Triage.soon => AppColors.warningLight,
    _Triage.monitor => AppColors.successLight,
  };
  String get icon => switch (triage) { _Triage.urgent => "🚨", _Triage.soon => "⚠️", _Triage.monitor => "✅" };

  String get title => switch (triage) {
    _Triage.urgent => bn ? "এখনই হাসপাতালে যান" : "Go to a hospital now",
    _Triage.soon => bn ? "২৪ ঘণ্টার মধ্যে ডাক্তার দেখান" : "See a doctor within 24 hours",
    _Triage.monitor => bn ? "ঘরে বিশ্রাম নিন ও নজর রাখুন" : "Rest at home and monitor",
  };

  String get body => switch (triage) {
    _Triage.urgent => bn
        ? "আপনি এমন লক্ষণ জানিয়েছেন যা গুরুতর ডেঙ্গুর সতর্কতা হতে পারে। দেরি করবেন না।"
        : "You reported signs that can mean severe dengue. Don't wait — get medical care now.",
    _Triage.soon => bn
        ? "আপনার উপসর্গ ডেঙ্গুর সঙ্গে মিলতে পারে। ডাক্তারকে ডেঙ্গু পরীক্ষা (যেমন NS1 ও CBC/প্লেটলেট) সম্পর্কে জিজ্ঞাসা করুন।"
        : "Your symptoms can fit dengue. Ask a doctor about a dengue test (e.g. NS1 antigen and a CBC / platelet count).",
    _Triage.monitor => bn
        ? "এখন ডেঙ্গুর শক্ত লক্ষণ নেই। জ্বর ২ দিনের বেশি থাকলে বা উপসর্গ বাড়লে ডাক্তার দেখান।"
        : "No strong dengue pattern right now. If fever lasts more than 2 days or symptoms worsen, see a doctor.",
  };

  @override
  Widget build(BuildContext context) {
    final dos = bn
      ? ["প্রচুর তরল পান করুন (পানি, ওআরএস, স্যুপ, ডাবের পানি)", "পর্যাপ্ত বিশ্রাম নিন", "জ্বরের জন্য শুধু প্যারাসিটামল — ডাক্তারের নির্দেশিত মাত্রায়", "অসুস্থ অবস্থায়ও মশারির নিচে থাকুন, যাতে অন্যদের মধ্যে না ছড়ায়"]
      : ["Drink plenty of fluids (water, ORS, soups, coconut water)", "Rest as much as you can", "Use only paracetamol for fever, at the dose a doctor advises", "Sleep under a mosquito net even while sick so it doesn't spread"];
    final donts = bn
      ? ["অ্যাসপিরিন, আইবুপ্রোফেন, ডাইক্লোফেনাক বা অন্য ব্যথানাশক (NSAID) খাবেন না — রক্তক্ষরণের ঝুঁকি বাড়ায়", "নিজে নিজে অ্যান্টিবায়োটিক বা স্টেরয়েড খাবেন না"]
      : ["Don't take aspirin, ibuprofen, diclofenac or other NSAID painkillers — they raise bleeding risk", "Don't self-medicate with antibiotics or steroids"];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color, width: 1.5)),
          child: Column(children: [
            Text(icon, style: const TextStyle(fontSize: 44)),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 8),
            Text(body, textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.ink)),
          ]),
        ),

        if (warnings.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(bn ? "আপনার জানানো সতর্কতা লক্ষণ" : "Warning signs you reported",
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.danger)),
          const SizedBox(height: 6),
          ...warnings.map((w) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text("• ${bn ? w.bn : w.en}",
              style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.slate)),
          )),
        ],

        if (triage != _Triage.urgent && areaHigh && areaName != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Icon(Icons.location_on, size: 16, color: AppColors.danger),
              const SizedBox(width: 8),
              Expanded(child: Text(
                bn ? "$areaName এখন উচ্চ ডেঙ্গু ঝুঁকিতে — জ্বর হলে অবহেলা করবেন না।"
                   : "$areaName currently has high dengue risk — don't ignore a fever.",
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.danger))),
            ]),
          ),
        ],

        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          onPressed: onHospitals,
          icon: const Icon(Icons.local_hospital),
          label: Text(bn ? "কাছের হাসপাতাল দেখুন" : "Find nearby hospitals",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(backgroundColor: triage == _Triage.urgent ? AppColors.danger : AppColors.teal),
        )),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: () => onDial("16263"),
            icon: const Icon(Icons.call, size: 18),
            label: Text(bn ? "১৬২৬৩" : "16263",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.teal, side: BorderSide(color: AppColors.teal)),
          )),
          if (triage == _Triage.urgent) ...[
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(
              onPressed: () => onDial("999"),
              icon: const Icon(Icons.emergency, size: 18),
              label: Text("999", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: BorderSide(color: AppColors.danger)),
            )),
          ],
        ]),

        if (triage != _Triage.urgent) ...[
          const SizedBox(height: 18),
          _Section(bn ? "কী করবেন" : "Do", dos, AppColors.success),
          const SizedBox(height: 10),
          _Section(bn ? "কী করবেন না" : "Don't", donts, AppColors.danger),
          const SizedBox(height: 10),
          _Section(
            bn ? "যেকোনো সময় এগুলো হলে এখনই হাসপাতালে যান" : "Go to hospital immediately if any of these appear",
            bn ? ["তীব্র পেটব্যথা", "বারবার বমি", "নাক/মাড়ি দিয়ে রক্ত বা কালো পায়খানা", "অতিরিক্ত দুর্বলতা বা অস্থিরতা", "জ্বর কমে যাওয়ার পর অবস্থার অবনতি (সাধারণত ৩–৭ দিনে)"]
                : ["Severe stomach pain", "Repeated vomiting", "Bleeding from nose/gums or black stool", "Extreme weakness or restlessness", "Feeling worse just as the fever drops (usually days 3–7)"],
            AppColors.warning),
        ],

        const SizedBox(height: 16),
        Center(child: TextButton.icon(
          onPressed: onRetake,
          icon: const Icon(Icons.refresh, size: 18),
          label: Text(bn ? "আবার নিন" : "Retake", style: GoogleFonts.poppins()),
        )),
        Center(child: Text(
          bn ? "এটি রোগ নির্ণয় নয়। সর্বদা চিকিৎসকের পরামর্শ নিন।" : "Not a diagnosis. Always consult a doctor.",
          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.slate))),
        const SizedBox(height: 20),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;
  const _Section(this.title, this.items, this.color);
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.cardBg, borderRadius: BorderRadius.circular(12),
      border: Border(left: BorderSide(color: color, width: 4))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
      const SizedBox(height: 6),
      ...items.map((t) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text("• $t", style: GoogleFonts.poppins(fontSize: 12, color: AppColors.slate)),
      )),
    ]),
  );
}
