# DengueShield BD 🦟

A bilingual (English / বাংলা) Flutter app that raises awareness of dengue risk across Bangladesh.
It combines live weather with case data into a simple risk index for 12 districts, helps you find
hospitals, and guides a safe symptom check.

> **Version 1.2.0** · See [CHANGELOG.md](CHANGELOG.md)
> **Not a medical device.** The app gives general awareness information only. If you feel unwell, see a doctor
> or call the national health helpline **16263**. For emergencies call **999**.

---

## Features

| | |
|---|---|
| 🗺️ **Risk map & list** | 0–100 dengue risk index for 12 districts, with search, sorting and a map (optional hospital layer). |
| 📍 **Your area** | Uses GPS, or lets you pick your district manually (remembered). |
| 🌧️ **Rainfall outlook** | Past 7 + next 7 days of rain per district, with plain-language prevention hints. |
| 📈 **14-day trend** | Risk history recorded on your phone each time live data loads. |
| 🩺 **Symptom checker** | Yes/no questions with WHO-style warning signs. Any warning sign gives a "go to hospital now" result with call buttons. Includes do / don't advice. |
| 📝 **Report a case** | Prototype form. Reports are saved **only on your phone** (never sent anywhere); copy or delete them in "My reports". |
| 📚 **Facts & myths** | How dengue spreads, symptoms, breeding sites, illness stages, and myth-vs-fact cards. |
| 🏥 **Hospitals** | Nearest hospitals for a district, sorted by distance. |
| 🔔 **Alerts** | Alerts generated from current district data, plus optional notifications (max once a day per situation). |
| ⏰ **Daily reminder** | Optional morning reminder at a time you choose (Android/iOS). |
| 🌙 **Dark mode** | System / Light / Dark, remembered. |
| 📴 **Offline use** | Last saved weather and national data are shown without a connection. |

---

## Quick start

### Windows (easiest)

Double-click **`run_dengueshield_web.bat`** (it must stay next to `pubspec.yaml`). It will:

1. Check for **Git** (installs it with winget if missing, then asks you to run it again).
2. Check for **Flutter** (downloads the SDK to `%USERPROFILE%\flutter` if missing).
3. Enable Flutter web, add the `web` folder if needed, and run `flutter pub get`.
4. Launch the app in **Chrome** (falls back to **Edge**).

The first run downloads several GB of tools, so it can take a while.

### Manual

Requirements: [Flutter](https://docs.flutter.dev/get-started/install) (Dart SDK ≥ 3.0) and Git.

```bash
git clone https://github.com/protwoy007/dengue_sheild.git
cd dengue_sheild
flutter pub get
flutter run -d chrome        # web
flutter run                  # Android / iOS device or emulator
```

After pulling a new version, run `flutter clean` once if you see Android build errors (Gradle settings changed in v1.2.0).

### What works where

| Feature | Android / iOS | Web (Chrome / Edge) |
|---|---|---|
| Risk, map, hospitals, symptom check, report case, facts & myths, dark mode | ✅ | ✅ |
| Live weather (Open-Meteo) | ✅ | ✅ |
| GPS location | ✅ | ✅ if you allow it in the browser |
| Notifications & daily reminder | ✅ | ❌ not supported |
| National DGHS / IEDCR figures | ✅ best effort | ⚠️ usually blocked by the browser, so sample numbers are shown |

For the complete experience, test on an Android phone or emulator.

---

## How the risk index works

It is a transparent, **rule-based awareness index**, not a trained machine-learning model.

| Factor | Max points |
|---|---|
| Rainfall over the past 7 days | 35 |
| Humidity | 25 |
| Reported cases this week | 25 |
| Temperature suitability for *Aedes* mosquitoes (about 26–32 °C) | 15 |

Score levels: **≥ 60 high**, **30–59 medium**, **< 30 low**. The Home screen shows each factor's contribution
to the current score. The index is not clinically validated.

### Data sources and limitations

- **Weather:** [Open-Meteo](https://open-meteo.com/) (free, no key): current conditions, 7 past days and 7 forecast days.
- **National figures:** read on a best-effort basis from public DGHS / IEDCR pages. Layouts change, so treat them as
  indicative. When unavailable, the app clearly labels the numbers as sample or saved data.
- **District case counts are currently sample data** (marked "sample" in the app) until a real district-level feed is connected.
- **Case reports and risk history** stay on your device (SharedPreferences) and are not uploaded.
- Map tiles: OpenStreetMap.

---

## Project structure

```
lib/
├── main.dart              App entry, theme switching
├── data/                  Districts and hospitals (baseline data)
├── l10n/                  English / Bengali strings
├── models/                District, daily weather, case report
├── providers/             AppProvider (state, caching, settings)
├── screens/               Home, Map, Alerts, Symptoms, Hospitals, Report,
│                          Facts & myths, Settings, About, Splash
├── services/              Weather, dengue scraper, risk model, notifications,
│                          location, local storage
├── theme/                 Light and dark theme and colours
├── utils/                 Geo helpers
└── widgets/               Shared UI components
```

Main packages: `provider`, `flutter_map`, `http`, `geolocator`, `permission_handler`,
`flutter_local_notifications`, `timezone`, `shared_preferences`, `google_fonts`, `url_launcher`.

---

## Helpful numbers (Bangladesh)

- **16263**: national health helpline (DGHS)
- **999**: national emergency service

## Disclaimer

DengueShield BD provides general awareness information from weather and sample case data. It is not a diagnostic tool and
does not replace professional medical advice. For official announcements, follow DGHS and IEDCR.
