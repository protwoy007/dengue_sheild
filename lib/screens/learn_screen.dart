import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:google_fonts/google_fonts.dart";
import "../providers/app_provider.dart";
import "../theme/app_theme.dart";

class _Item {
  final String titleEn, titleBn, bodyEn, bodyBn;
  const _Item(this.titleEn, this.titleBn, this.bodyEn, this.bodyBn);
}

const _facts = [
  _Item("How dengue spreads", "ডেঙ্গু কীভাবে ছড়ায়",
    "Dengue spreads through the bite of an infected Aedes mosquito. It does not spread by touching, coughing or sharing food. Aedes bites mostly in the daytime — early morning and late afternoon.",
    "ডেঙ্গু সংক্রমিত এডিস মশার কামড়ে ছড়ায়। ছোঁয়া, কাশি বা একসাথে খাবার খেলে ছড়ায় না। এডিস মশা মূলত দিনের বেলায় — সকাল ও বিকালে — কামড়ায়।"),
  _Item("Common symptoms", "সাধারণ উপসর্গ",
    "Usually 4–10 days after a bite: sudden high fever, severe headache, pain behind the eyes, muscle and joint pain, nausea, and sometimes a rash.",
    "কামড়ের সাধারণত ৪–১০ দিন পর হঠাৎ উচ্চ জ্বর, তীব্র মাথাব্যথা, চোখের পেছনে ব্যথা, পেশী ও জয়েন্টে ব্যথা, বমি বমি ভাব এবং কখনো ফুসকুড়ি দেখা দেয়।"),
  _Item("Where mosquitoes breed", "মশা কোথায় বংশবিস্তার করে",
    "Aedes lay eggs in still water, often clean water in small containers: buckets, flower pots, tyres, AC trays, tanks and discarded containers. Empty and scrub containers at least once a week to break the life cycle.",
    "এডিস মশা জমে থাকা পানিতে — প্রায়ই ছোট পাত্রের পরিষ্কার পানিতে — ডিম পাড়ে: বালতি, ফুলের টব, টায়ার, এসির ট্রে, ট্যাংক ও ফেলে দেওয়া পাত্র। অন্তত সপ্তাহে একবার পাত্র খালি করে ঘষে ধুয়ে ফেলুন।"),
  _Item("Protect yourself", "নিজেকে রক্ষা করুন",
    "Use mosquito repellent, wear long sleeves in the morning and late afternoon, fit window screens, and sleep under a net — also when you are sick, so you don't pass the virus on.",
    "মশা তাড়ানোর ক্রিম ব্যবহার করুন, সকাল ও বিকালে লম্বা হাতার জামা পরুন, জানালায় জাল লাগান এবং মশারির নিচে ঘুমান — অসুস্থ অবস্থায়ও, যাতে অন্যদের মধ্যে না ছড়ায়।"),
  _Item("Treatment at home", "বাড়িতে করণীয়",
    "There is no specific antiviral medicine. Most people recover with rest, plenty of fluids and paracetamol for fever at a doctor-advised dose. Avoid aspirin and NSAIDs such as ibuprofen or diclofenac. See a doctor early.",
    "ডেঙ্গুর নির্দিষ্ট কোনো অ্যান্টিভাইরাল ওষুধ নেই। বেশিরভাগ রোগী বিশ্রাম, প্রচুর তরল এবং ডাক্তারের নির্দেশিত মাত্রায় প্যারাসিটামলে সেরে ওঠেন। অ্যাসপিরিন এবং আইবুপ্রোফেন/ডাইক্লোফেনাকের মতো NSAID এড়িয়ে চলুন। আগেভাগে ডাক্তার দেখান।"),
  _Item("Can you get it twice?", "দুইবার কি হতে পারে?",
    "Yes. There are four dengue virus types. Recovering from one doesn't protect you from the others, and a second infection can be more severe.",
    "হ্যাঁ। ডেঙ্গু ভাইরাস চার ধরনের। একটি থেকে সেরে উঠলে অন্যগুলো থেকে সুরক্ষা মেলে না, এবং দ্বিতীয়বার সংক্রমণ আরও গুরুতর হতে পারে।"),
];

class _Stage {
  final String daysEn, daysBn, nameEn, nameBn, bodyEn, bodyBn;
  final int level; // 0 calm, 1 danger, 2 recovery
  const _Stage(this.daysEn, this.daysBn, this.nameEn, this.nameBn, this.bodyEn, this.bodyBn, this.level);
}

const _stages = [
  _Stage("Days 1–3", "১–৩ দিন", "Fever phase", "জ্বরের পর্যায়",
    "High fever, headache, body pain. Rest, drink fluids and see a doctor — ask about a dengue test.",
    "উচ্চ জ্বর, মাথাব্যথা, শরীর ব্যথা। বিশ্রাম নিন, তরল পান করুন, ডাক্তার দেখান এবং ডেঙ্গু পরীক্ষা সম্পর্কে জিজ্ঞাসা করুন।", 0),
  _Stage("Days 3–7", "৩–৭ দিন", "Critical phase", "সংকটকালীন পর্যায়",
    "The fever may drop — but this is when severe dengue can start. Go to a hospital immediately for severe stomach pain, repeated vomiting, bleeding, or drowsiness/restlessness.",
    "জ্বর কমে গেলেও এ সময়েই গুরুতর ডেঙ্গু শুরু হতে পারে। তীব্র পেটব্যথা, বারবার বমি, রক্তপাত বা অতিরিক্ত ঘুম/অস্থিরতা হলে এখনই হাসপাতালে যান।", 1),
  _Stage("Days 7–10", "৭–১০ দিন", "Recovery phase", "সেরে ওঠার পর্যায়",
    "Appetite returns and you feel better. Tiredness can last for weeks — keep resting and drinking fluids.",
    "ক্ষুধা ফিরে আসে ও ভালো লাগে। দুর্বলতা কয়েক সপ্তাহ থাকতে পারে — বিশ্রাম ও তরল পান চালিয়ে যান।", 2),
];

const _myths = [
  _Item("Dengue spreads by touching or sharing food.", "ছোঁয়া বা একসাথে খাবার খেলে ডেঙ্গু ছড়ায়।",
    "No. It spreads only through bites from infected mosquitoes. (A sick person can infect mosquitoes that bite them — so use a net.)",
    "না। এটি শুধু সংক্রমিত মশার কামড়ে ছড়ায়। (অসুস্থ ব্যক্তিকে কামড়ানো মশা অন্যকে সংক্রমিত করতে পারে — তাই মশারি ব্যবহার করুন।)"),
  _Item("Aedes only breed in dirty drains.", "এডিস শুধু নোংরা নর্দমায় বংশবিস্তার করে।",
    "They prefer still water in small containers — often clean water. Check pots, buckets, tyres and trays at home.",
    "তারা ছোট পাত্রের জমে থাকা — প্রায়ই পরিষ্কার — পানি পছন্দ করে। বাসার টব, বালতি, টায়ার ও ট্রে পরীক্ষা করুন।"),
  _Item("Aedes bite at night, so daytime is safe.", "এডিস রাতে কামড়ায়, তাই দিনে নিরাপদ।",
    "Aedes bite mainly in the daytime, especially early morning and late afternoon.",
    "এডিস মূলত দিনের বেলায়, বিশেষ করে সকাল ও বিকালে কামড়ায়।"),
  _Item("Once the fever is gone, the danger is over.", "জ্বর চলে গেলেই বিপদ কেটে গেছে।",
    "The days right after the fever drops (about days 3–7) are when severe dengue can develop. Keep watching for warning signs.",
    "জ্বর কমার ঠিক পরের দিনগুলোতে (প্রায় ৩–৭ দিন) গুরুতর ডেঙ্গু দেখা দিতে পারে। সতর্কতা লক্ষণের দিকে নজর রাখুন।"),
  _Item("Papaya leaf juice cures dengue.", "পেঁপে পাতার রস ডেঙ্গু সারায়।",
    "There is no proven cure. Some small studies looked at papaya leaf and platelet counts, but it is not a substitute for medical care — never delay seeing a doctor.",
    "প্রমাণিত কোনো নিরাময় নেই। পেঁপে পাতা ও প্লেটলেট নিয়ে কিছু ছোট গবেষণা হয়েছে, কিন্তু এটি চিকিৎসার বিকল্প নয় — ডাক্তার দেখাতে দেরি করবেন না।"),
  _Item("Ibuprofen or aspirin will help the fever.", "আইবুপ্রোফেন বা অ্যাসপিরিন জ্বরে সাহায্য করবে।",
    "Avoid them in suspected dengue — they can increase bleeding risk. Use paracetamol as a doctor advises.",
    "সন্দেহজনক ডেঙ্গুতে এগুলো এড়িয়ে চলুন — রক্তক্ষরণের ঝুঁকি বাড়াতে পারে। ডাক্তারের পরামর্শমতো প্যারাসিটামল নিন।"),
  _Item("If I've had dengue, I'm immune forever.", "একবার ডেঙ্গু হলে আজীবন নিরাপদ।",
    "You may be protected against that virus type, but there are four types and a repeat infection can be more severe.",
    "ওই ধরনের ভাইরাস থেকে সুরক্ষা পেতে পারেন, কিন্তু ধরন চারটি এবং দ্বিতীয়বার সংক্রমণ আরও গুরুতর হতে পারে।"),
];

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bn = context.watch<AppProvider>().isBengali;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: Text(bn ? "ডেঙ্গু: তথ্য ও ভুল ধারণা" : "Dengue facts & myths",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
        children: [
          _Heading(bn ? "জানা দরকার" : "Good to know", Icons.lightbulb_outline),
          ..._facts.map((f) => _Expand(
            title: bn ? f.titleBn : f.titleEn,
            body: bn ? f.bodyBn : f.bodyEn,
            leading: Icon(Icons.check_circle_outline, color: AppColors.teal, size: 20))),

          _Heading(bn ? "অসুস্থতার ধাপ (জ্বরের প্রথম দিন = ১ম দিন)" : "Stages of illness (day 1 = first day of fever)",
            Icons.timeline),
          ..._stages.map((s) => _StageCard(stage: s, bn: bn)),
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 4),
            child: Text(bn ? "সময়সীমা ব্যক্তিভেদে ভিন্ন হতে পারে।" : "Timing varies from person to person.",
              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.slate)),
          ),

          _Heading(bn ? "ভুল ধারণা বনাম সত্য" : "Myths vs facts", Icons.rule),
          ..._myths.map((m) => _MythCard(item: m, bn: bn)),

          const SizedBox(height: 14),
          Text(
            bn ? "এটি সাধারণ সচেতনতামূলক তথ্য, চিকিৎসা পরামর্শ নয়। WHO-এর সাধারণ নির্দেশনার ভিত্তিতে; সর্বদা আপনার ডাক্তারের পরামর্শ মানুন।"
               : "General awareness information, not medical advice. Based on general WHO dengue guidance — always follow your doctor's advice.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.slate)),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;
  final IconData icon;
  const _Heading(this.text, this.icon);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 8),
    child: Row(children: [
      Icon(icon, size: 18, color: AppColors.teal),
      const SizedBox(width: 8),
      Expanded(child: Text(text,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink))),
    ]),
  );
}

class _Expand extends StatelessWidget {
  final String title, body;
  final Widget leading;
  const _Expand({required this.title, required this.body, required this.leading});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: AppColors.cardBg, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border, width: 0.8)),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ExpansionTile(
        shape: const Border(), collapsedShape: const Border(),
        leading: leading,
        title: Text(title, style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.ink)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(body, style: GoogleFonts.poppins(fontSize: 12.5, height: 1.5, color: AppColors.slate))],
      ),
    ),
  );
}

class _StageCard extends StatelessWidget {
  final _Stage stage;
  final bool bn;
  const _StageCard({required this.stage, required this.bn});

  @override
  Widget build(BuildContext context) {
    final color = stage.level == 1 ? AppColors.danger : (stage.level == 2 ? AppColors.success : AppColors.warning);
    final bg = stage.level == 1 ? AppColors.dangerLight : (stage.level == 2 ? AppColors.successLight : AppColors.warningLight);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(bn ? stage.daysBn : stage.daysEn,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(width: 8),
          Expanded(child: Text(bn ? stage.nameBn : stage.nameEn,
            style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.ink))),
        ]),
        const SizedBox(height: 6),
        Text(bn ? stage.bodyBn : stage.bodyEn,
          style: GoogleFonts.poppins(fontSize: 12.5, height: 1.45, color: AppColors.ink)),
      ]),
    );
  }
}

class _MythCard extends StatelessWidget {
  final _Item item;
  final bool bn;
  const _MythCard({required this.item, required this.bn});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.cardBg, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border, width: 0.8)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Tag(bn ? "ভুল ধারণা" : "MYTH", AppColors.danger, AppColors.dangerLight),
      const SizedBox(height: 4),
      Text(bn ? item.titleBn : item.titleEn,
        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
      const SizedBox(height: 10),
      _Tag(bn ? "সত্য" : "FACT", AppColors.success, AppColors.successLight),
      const SizedBox(height: 4),
      Text(bn ? item.bodyBn : item.bodyEn,
        style: GoogleFonts.poppins(fontSize: 12.5, height: 1.45, color: AppColors.slate)),
    ]),
  );
}

class _Tag extends StatelessWidget {
  final String text;
  final Color fg, bg;
  const _Tag(this.text, this.fg, this.bg);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
    child: Text(text, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w800, color: fg)),
  );
}
