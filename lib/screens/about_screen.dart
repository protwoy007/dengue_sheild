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
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.navy)),
            Text(bn ? "পূর্বাভাস। সুরক্ষা। প্রতিরোধ।" : "Predict. Protect. Prevent.",
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.slate)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(20)),
              child: Text("v1.0.0 · 2026",
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.teal, fontWeight: FontWeight.w600)),
            ),
          ])),

          const SizedBox(height: 12),

          _SectionTitle(bn ? "এই অ্যাপ কী করে?" : "What does this app do?"),
          _Card(child: _Para(
            bn
              ? "DengueShield BD বাংলাদেশে ডেঙ্গু জ্বরের প্রাদুর্ভাব আসার ৭-১৪ দিন আগে পূর্বাভাস দেয়। আবহাওয়া ডেটা, হাসপাতালের কেস রিপোর্ট এবং ভৌগোলিক তথ্য মিলিয়ে একটি AI মডেল প্রতিটি উপজেলার জন্য ঝুঁকির স্কোর তৈরি করে।"
              : "DengueShield BD predicts dengue fever outbreaks in Bangladesh 7–14 days in advance. By combining weather data, hospital case reports, and geographic information, an AI model generates a daily risk score for each upazila across Bangladesh.",
          )),

          const SizedBox(height: 8),

          _SectionTitle(bn ? "AI মডেল" : "AI Model"),
          _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _InfoRow(Icons.auto_graph, bn ? "মডেল টাইপ" : "Model Type", "XGBoost + LSTM Ensemble"),
            _InfoRow(Icons.dataset_outlined, bn ? "ট্রেনিং ডেটা" : "Training Data", "DGHS 2010–2023 + BMD Weather"),
            _InfoRow(Icons.input_outlined, bn ? "ইনপুট ফিচার" : "Input Features",
              bn ? "বৃষ্টিপাত, তাপমাত্রা, আর্দ্রতা, কেস ট্রেন্ড" : "Rainfall, Temperature, Humidity, Case trend"),
            _InfoRow(Icons.output_outlined, bn ? "আউটপুট" : "Output",
              bn ? "প্রতি উপজেলায় ০-১০০ ঝুঁকি স্কোর" : "Risk score 0–100 per upazila"),
            _InfoRow(Icons.insights, bn ? "ব্যাখ্যাযোগ্যতা" : "Explainability", "SHAP (SHapley Additive exPlanations)"),
            _InfoRow(Icons.track_changes, bn ? "নির্ভুলতা লক্ষ্য" : "Accuracy Target",
              bn ? "উচ্চ ঝুঁকি জোনে ≥৮০% নির্ভুলতা" : "≥80% precision for High-risk zones"),
          ])),

          const SizedBox(height: 8),

          _SectionTitle(bn ? "ডেটা সোর্স" : "Data Sources"),
          _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _InfoRow(Icons.cloud_outlined, bn ? "আবহাওয়া" : "Weather", "Open-Meteo API (Free, No Key)"),
            _InfoRow(Icons.medical_information_outlined, bn ? "ডেঙ্গু কেস" : "Dengue Cases", "DGHS Bangladesh (dghs.gov.bd)"),
            _InfoRow(Icons.biotech_outlined, bn ? "রোগতত্ত্ব" : "Epidemiology", "IEDCR Bangladesh (iedcr.gov.bd)"),
            _InfoRow(Icons.map_outlined, bn ? "মানচিত্র" : "Map", "OpenStreetMap (Free)"),
            _InfoRow(Icons.location_on_outlined, bn ? "লোকেশন" : "Location", "Device GPS (Optional)"),
          ])),

          const SizedBox(height: 8),

          _SectionTitle(bn ? "নৈতিক কাঠামো" : "Ethics Framework"),
          _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _EthicsItem(Icons.privacy_tip_outlined, bn ? "কোনো ব্যক্তিগত তথ্য সংগ্রহ করা হয় না" : "No personal data collected (PII-free)"),
            _EthicsItem(Icons.gpp_good_outlined, bn ? "এটি রোগ নির্ণয়ের সরঞ্জাম নয়" : "Not a diagnostic tool — risk awareness only"),
            _EthicsItem(Icons.visibility_outlined, bn ? "SHAP দিয়ে প্রতিটি পূর্বাভাস ব্যাখ্যা করা হয়" : "Every prediction explained via SHAP"),
            _EthicsItem(Icons.manage_accounts_outlined, bn ? "DGHS কর্মকর্তারা যেকোনো সতর্কতা বাতিল করতে পারেন" : "DGHS officials can override any alert"),
            _EthicsItem(Icons.language_outlined, bn ? "বাংলা ভাষায় সম্পূর্ণ সমর্থন" : "Full Bengali language support"),
            _EthicsItem(Icons.wifi_off_outlined, bn ? "অফলাইন মোড — ২জি নেটওয়ার্কে কাজ করে" : "Offline mode — works on 2G networks"),
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
              const Icon(Icons.info_outline, color: AppColors.gold, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(
                bn
                  ? "এই অ্যাপটি শুধুমাত্র ঝুঁকি সচেতনতার জন্য। এটি কোনো চিকিৎসা নির্ণয়ের সরঞ্জাম নয়। সর্বদা একজন যোগ্য ডাক্তারের পরামর্শ নিন।"
                  : "This app is for risk awareness only. It is not a medical diagnostic tool. Always consult a qualified doctor for medical advice.",
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.navy),
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
    child: Text(text, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navy)),
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
      color: Colors.white, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFECEFF1), width: 0.8),
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
        Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.navy)),
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
        Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.navy)),
        Text(value, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.teal)),
      ])),
      const Icon(Icons.chevron_right, color: AppColors.slate, size: 18),
    ]),
  );
}
