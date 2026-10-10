import "package:flutter/material.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "../models/district.dart";
import "package:timezone/data/latest.dart" as tzdata;
import "package:timezone/timezone.dart" as tz;
import "storage_service.dart";

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      const android = AndroidInitializationSettings("@mipmap/ic_launcher");
      const ios = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      try {
        tzdata.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation("Asia/Dhaka")); // Bangladesh: UTC+6, no DST
      } catch (_) {}
      await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));
      _initialized = true;
    } catch (_) {}
  }

  static Future<void> requestPermission() async {
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (_) {}
  }

  // ── 3. Daily morning reminder (repeats every day at the chosen time) ──
  // The text is generic on purpose: a scheduled notification can't know tomorrow's risk,
  // so it invites the user to open the app instead of showing numbers that may be stale.
  static Future<void> scheduleDailyReminder({
    required int hour, required int minute, required bool bn, String? areaName,
  }) async {
    if (!_initialized) return;
    try {
      final title = bn ? "আজকের ডেঙ্গু ঝুঁকি দেখুন" : "Check today's dengue risk";
      final body = areaName != null
          ? (bn ? "$areaName এলাকার সর্বশেষ ঝুঁকি ও পূর্বাভাস দেখতে অ্যাপ খুলুন।"
                : "Open DengueShield BD for the latest risk and forecast in $areaName.")
          : (bn ? "আপনার এলাকার সর্বশেষ ঝুঁকি ও পূর্বাভাস দেখতে অ্যাপ খুলুন।"
                : "Open DengueShield BD for the latest risk and forecast in your area.");

      final now = tz.TZDateTime.now(tz.local);
      var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (!when.isAfter(now)) when = when.add(const Duration(days: 1));

      await _plugin.zonedSchedule(
        2, title, body, when,
        NotificationDetails(
          android: AndroidNotificationDetails(
            "daily_reminder_channel", "Daily Risk Reminder",
            channelDescription: "A daily morning reminder to check dengue risk",
            importance: Importance.defaultImportance, priority: Priority.defaultPriority,
            icon: "@mipmap/ic_launcher", styleInformation: BigTextStyleInformation(body),
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }

  static Future<void> cancelDailyReminder() async {
    try { await _plugin.cancel(2); } catch (_) {}
  }

  static String _today() {
    final n = DateTime.now();
    return "${n.year}-${n.month}-${n.day}";
  }

  /// True if this exact alert was already shown today (prevents spam on every refresh).
  static bool _alreadySent(String key, String signature) =>
      StorageService.getString(key) == "${_today()}|$signature";

  static Future<void> _mark(String key, String signature) =>
      StorageService.setString(key, "${_today()}|$signature");

  // ── 1. Personal alert for the user's district (max once/day per risk level) ──
  static Future<void> showPersonalAlert({required District district, required bool bn}) async {
    if (!_initialized || district.riskLevel == RiskLevel.low) return;
    final sig = "${district.id}:${district.riskLevel.name}";
    if (_alreadySent("n_personal", sig)) return;

    final isHigh = district.riskLevel == RiskLevel.high;
    final title = isHigh
        ? (bn ? "⚠️ উচ্চ ঝুঁকি — আপনার এলাকা ${district.nameBn}" : "⚠️ High Risk — Your Area: ${district.nameEn}")
        : (bn ? "🟡 মাঝারি ঝুঁকি — আপনার এলাকা ${district.nameBn}" : "🟡 Medium Risk — Your Area: ${district.nameEn}");
    final body = isHigh
        ? (bn ? "ডেঙ্গু ঝুঁকি ${district.riskScore}/100। এখনই সতর্কতা নিন। জমে থাকা পানি সরান।"
              : "Dengue risk is ${district.riskScore}/100 in your area. Clear standing water and take precautions.")
        : (bn ? "ডেঙ্গু ঝুঁকি ${district.riskScore}/100। সচেতন থাকুন।"
              : "Dengue risk is ${district.riskScore}/100 in your area. Stay cautious.");

    try {
      await _plugin.show(0, title, body, NotificationDetails(
        android: AndroidNotificationDetails(
          "personal_risk_channel", "Your District Risk Alert",
          channelDescription: "Personalized dengue risk alert for your area",
          importance: isHigh ? Importance.max : Importance.defaultImportance,
          priority: isHigh ? Priority.max : Priority.defaultPriority,
          icon: "@mipmap/ic_launcher",
          color: isHigh ? const Color(0xFFC62828) : const Color(0xFFF9A825),
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(),
      ));
      await _mark("n_personal", sig);
    } catch (_) {}
  }

  // ── 2. National alert for High-risk districts (max once/day if list unchanged) ──
  static Future<void> showNationalAlerts({required List<District> districts, required bool bn}) async {
    if (!_initialized) return;
    final highRisk = districts.where((d) => d.riskLevel == RiskLevel.high).toList();
    if (highRisk.isEmpty) return;
    final sig = (highRisk.map((d) => d.id).toList()..sort()).join(",");
    if (_alreadySent("n_national", sig)) return;

    final names = highRisk.map((d) => d.name(bn)).join(", ");
    final count = highRisk.length;
    final title = bn ? "🔴 $count টি জেলায় উচ্চ ডেঙ্গু ঝুঁকি" : "🔴 High Dengue Risk in $count Districts";
    final body = bn ? "উচ্চ ঝুঁকিপূর্ণ এলাকা: $names" : "High risk areas: $names";

    try {
      await _plugin.show(1, title, body, NotificationDetails(
        android: AndroidNotificationDetails(
          "national_risk_channel", "National Dengue Alerts",
          channelDescription: "Dengue outbreak alerts across Bangladesh",
          importance: Importance.high, priority: Priority.high,
          icon: "@mipmap/ic_launcher", color: const Color(0xFFC62828),
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(),
      ));
      await _mark("n_national", sig);
    } catch (_) {}
  }
}
