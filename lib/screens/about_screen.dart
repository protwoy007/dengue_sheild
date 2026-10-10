import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:url_launcher/url_launcher.dart";
import "../theme/app_theme.dart";

class AboutScreen extends StatelessWidget {
  final bool bn;
  const AboutScreen({super.key, required this.bn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: Text(bn ? "অ্যাপ সম্পর্কে" : "About DengueShield BD",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [

          // Logo card
          _Card(child: Column(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset("assets/app_icon.png", width: 90, height: 90, fit: BoxFit.contain),
            ),
            const SizedBox(height: 12),
            Text("DengueShield BD",
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.ink)),
            Text(bn ? "পূর্বাভাস। সুরক্ষা। প্রতিরোধ।" : "Predict. Protect. Prevent.",
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.slate)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(20)),
              child: Text("v1.2.0 · 2026",
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.teal, fontWeight: FontWeight.w600)),
            ),
          ])),

          const SizedBox(height: 12),

          _SectionTitle(bn ? "এই অ্যাপ কী করে?" : "What does this app do?"),
          _Card(child: _Para(
            bn
              ? "DengueShield BD বাংলাদেশের ডেঙ্গু ঝুঁকি সম্পর্কে সচেতনতা বাড়ায়। রিয়েল-টাইম আবহাওয়া (গত ও আগামী ৭ দিনের বৃষ্টিপাত সহ) ও কেসের তথ্য মিলিয়ে প্রতিটি জেলার জন্য ০–১০০ ঝুঁকি সূচক দেখায়, কাছের হাসপাতাল খুঁজে দেয় এবং উপসর্গ যাচাই করতে সাহায্য করে।"
              : "DengueShield BD raises awareness of dengue risk across Bangladesh. It combines live weather (including rainfall for the past and coming 7 days) with case data into a 0–100 risk index per district, helps you find nearby hospitals, and guides a symptom check.",
          )),

          const SizedBox(height: 8),

          _SectionTitle(bn ? "ঝুঁকি সূচক কীভাবে কাজ করে" : "How the risk index works"),
          _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _InfoRow(Icons.rule, bn ? "পদ্ধতি" : "Method",
              bn ? "নিয়ম-ভিত্তিক ওজনযুক্ত সূচক (মেশিন লার্নিং নয়)" : "Rule-based weighted index (not machine learning)"),
            _InfoRow(Icons.input_outlined, bn ? "ইনপুট" : "Inputs",
              bn ? "৭ দিনের বৃষ্টিপাত (৩৫), আর্দ্রতা (২৫), রিপোর্টকৃত কেস (২৫), তাপমাত্রার উপযোগিতা (১৫)"
                 : "7-day rainfall (35), humidity (25), reported cases (25), temperature suitability (15)"),
            _InfoRow(Icons.output_outlined, bn ? "আউটপুট" : "Output",
              bn ? "প্রতি জেলায় ০-১০০ স্কোর: ≥৬০ উচ্চ, ৩০–৫৯ মাঝারি" : "0–100 score per district: ≥60 high, 30–59 medium, <30 low"),
            _InfoRow(Icons.insights, bn ? "ব্যাখ্যা" : "Explainability",
              bn ? "হোম স্ক্রিনে প্রতিটি উপাদানের অবদান দেখানো হয়" : "The Home screen shows each factor's contribution"),
            _InfoRow(Icons.science_outlined, bn ? "সীমাবদ্ধতা" : "Limitations",
              bn ? "ক্লিনিক্যালি যাচাই করা হয়নি; জেলাভিত্তিক কেসের সংখ্যা বর্তমানে নমুনা ডেটা" : "Not clinically validated; district-level case counts are currently sample data"),
          ])),

          const SizedBox(height: 8),

          _SectionTitle(bn ? "ডেটা সোর্স" : "Data Sources"),
          _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _InfoRow(Icons.cloud_outlined, bn ? "আবহাওয়া" : "Weather", "Open-Meteo API (free, no key)"),
            _InfoRow(Icons.medical_information_outlined, bn ? "ডেঙ্গু কেস" : "Dengue Cases",
              bn ? "জাতীয় সংখ্যা: DGHS/IEDCR থেকে স্বয়ংক্রিয় পাঠ (ব্যর্থ হলে নমুনা)" : "National figures: auto-read from DGHS / IEDCR (sample if unavailable)"),
            _InfoRow(Icons.biotech_outlined, bn ? "রোগতত্ত্ব" : "Epidemiology", "IEDCR Bangladesh (iedcr.gov.bd)"),
            _InfoRow(Icons.map_outlined, bn ? "মানচিত্র" : "Map", "OpenStreetMap (Free)"),
            _InfoRow(Icons.location_on_outlined, bn ? "লোকেশন" : "Location", "Device GPS (Optional)"),
          ])),

          const SizedBox(height: 8),

          _SectionTitle(bn ? "নৈতিক কাঠামো" : "Ethics Framework"),
          _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _EthicsItem(Icons.privacy_tip_outlined, bn ? "কোনো ব্যক্তিগত তথ্য সংগ্রহ করা হয় না" : "No personal data collected (PII-free)"),
            _EthicsItem(Icons.gpp_good_outlined, bn ? "এটি রোগ নির্ণয়ের সরঞ্জাম নয়" : "Not a diagnostic tool — risk awareness only"),
            _EthicsItem(Icons.visibility_outlined, bn ? "প্রতিটি স্কোরের কারণ দেখানো হয়" : "Every score shows the factors behind it"),
            _EthicsItem(Icons.manage_accounts_outlined, bn ? "অফিসিয়াল ঘোষণার জন্য DGHS/IEDCR-কে অনুসরণ করুন" : "For official announcements, follow DGHS / IEDCR"),
            _EthicsItem(Icons.language_outlined, bn ? "বাংলা ভাষায় সম্পূর্ণ সমর্থন" : "Full Bengali language support"),
            _EthicsItem(Icons.wifi_off_outlined, bn ? "অফলাইনে সর্বশেষ সংরক্ষিত ডেটা দেখা যায়" : "Works offline using the last saved data"),
          ])),

          const SizedBox(height: 8),

          _SectionTitle(bn ? "জরুরি যোগাযোগ" : "Emergency Contact"),
          _Card(child: Column(children: [
            _ContactRow("🏥", bn ? "স্বাস্থ্য বাতায়ন" : "Health Hotline", "16263",
              onTap: () async {
                final uri = Uri(scheme: "tel", path: "16263");
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              }),
            const Divider(height: 16),
            _ContactRow("🌐", "DGHS Bangladesh", "dghs.gov.bd",
              onTap: () async {
                final uri = Uri.parse("https://dghs.gov.bd");
                if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
              }),
            const Divider(height: 16),
            _ContactRow("🔬", "IEDCR Bangladesh", "iedcr.gov.bd",
              onTap: () async {
                final uri = Uri.parse("https://www.iedcr.gov.bd");
                if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
              }),
          ])),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.goldLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_outline, color: AppColors.gold, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(
                bn
                  ? "এই অ্যাপটি শুধুমাত্র ঝুঁকি সচেতনতার জন্য। এটি কোনো চিকিৎসা নির্ণয়ের সরঞ্জাম নয়। সর্বদা একজন যোগ্য ডাক্তারের পরামর্শ নিন।"
                  : "This app is for risk awareness only. It is not a medical diagnostic tool. Always consult a qualified doctor for medical advice.",
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.ink),
              )),
            ]),
          ),

          const SizedBox(height: 20),
          Text("Made by Team Void · 2026",
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.slate, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6, left: 2),
    child: Text(text, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
  );
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 4),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.cardBg, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border, width: 0.8),
    ),
    child: child,
  );
}

class _Para extends StatelessWidget {
  final String text;
  const _Para(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.slate, height: 1.6));
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 16, color: AppColors.teal),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.slate)),
        Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.ink)),
      ])),
    ]),
  );
}

class _EthicsItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EthicsItem(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Icon(icon, size: 16, color: AppColors.teal),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.slate))),
    ]),
  );
}

class _ContactRow extends StatelessWidget {
  final String emoji, label, value;
  final VoidCallback onTap;
  const _ContactRow(this.emoji, this.label, this.value, {required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 20)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.ink)),
        Text(value, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.teal)),
      ])),
      Icon(Icons.chevron_right, color: AppColors.slate, size: 18),
    ]),
  );
}
