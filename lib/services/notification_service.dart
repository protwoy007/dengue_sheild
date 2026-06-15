
import "package:flutter/material.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "../models/district.dart";

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings("@mipmap/ic_launcher");
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  static Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ── 1. Personal alert for user's GPS district ──────────────
  static Future<void> showPersonalAlert({
    required District district,
    required bool bn,
  }) async {
    if (district.riskLevel == RiskLevel.low) return;

    final isHigh = district.riskLevel == RiskLevel.high;

    final title = isHigh
        ? (bn ? "⚠️ উচ্চ ঝুঁকি — আপনার এলাকা ${district.nameBn}" : "⚠️ High Risk — Your Area: ${district.nameEn}")
        : (bn ? "🟡 মাঝারি ঝুঁকি — আপনার এলাকা ${district.nameBn}" : "🟡 Medium Risk — Your Area: ${district.nameEn}");

    final body = isHigh
        ? (bn
            ? "ডেঙ্গু ঝুঁকি ${district.riskScore}/100। এখনই সতর্কতা নিন। মশার কামড় থেকে বাঁচুন।"
            : "Dengue risk is ${district.riskScore}/100 in your area. Take precautions now.")
        : (bn
            ? "ডেঙ্গু ঝুঁকি ${district.riskScore}/100। সচেতন থাকুন।"
            : "Dengue risk is ${district.riskScore}/100 in your area. Stay cautious.");

    await _plugin.show(
      0, // ID 0 = personal alert (always replaces previous)
      title,
      body,
      NotificationDetails(android: AndroidNotificationDetails(
        "personal_risk_channel",
        "Your District Risk Alert",
        channelDescription: "Personalized dengue risk alert for your GPS location",
        importance: isHigh ? Importance.max : Importance.defaultImportance,
        priority: isHigh ? Priority.max : Priority.defaultPriority,
        icon: "@mipmap/ic_launcher",
        color: isHigh ? const Color(0xFFC62828) : const Color(0xFFF9A825),
        enableVibration: isHigh,
        playSound: true,
        styleInformation: BigTextStyleInformation(body),
      )),
    );
  }

  // ── 2. National alerts for ALL High risk districts ─────────
  static Future<void> showNationalAlerts({
    required List<District> districts,
    required bool bn,
  }) async {
    final highRisk = districts.where((d) => d.riskLevel == RiskLevel.high).toList();
    if (highRisk.isEmpty) return;

    final names = highRisk.map((d) => d.name(bn)).join(", ");
    final count = highRisk.length;

    final title = bn
        ? "🔴 $count টি জেলায় উচ্চ ডেঙ্গু ঝুঁকি"
        : "🔴 High Dengue Risk in $count Districts";

    final body = bn
        ? "উচ্চ ঝুঁকিপূর্ণ এলাকা: $names"
        : "High risk areas: $names";

    await _plugin.show(
      1, // ID 1 = national alert (always replaces previous)
      title,
      body,
      NotificationDetails(android: AndroidNotificationDetails(
        "national_risk_channel",
        "National Dengue Alerts",
        channelDescription: "Dengue outbreak alerts across Bangladesh",
        importance: Importance.high,
        priority: Priority.high,
        icon: "@mipmap/ic_launcher",
        color: const Color(0xFFC62828),
        enableVibration: true,
        playSound: true,
        styleInformation: BigTextStyleInformation(body),
      )),
    );
  }
}
