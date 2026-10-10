# Changelog

## 1.2.0 — dark mode, case reports, learning, trends, reminders

### New
- **Dark mode** (System / Light / Dark, remembered). All screens, cards, charts and the map adapt;
  the map uses a dark tile filter. Switch in **Settings** (gear icon on Home).
- **Report a case** (prototype): symptoms, onset date, test result, hospitalised, optional note and
  optional GPS. Saved **on this phone only** (clearly labelled, never sent anywhere). "My reports"
  list with copy-to-clipboard (for passing to a health worker) and delete. Warning-sign symptoms show an
  immediate "go to hospital / call 16263" banner.
- **Dengue facts & myths**: how it spreads, symptoms, breeding sites, home care, illness stages
  (fever → critical → recovery) and 7 myth-vs-fact cards, in English and Bangla.
- **14-day risk trend** chart for your district. History is recorded on the phone each time live
  weather loads, so it builds up with use (it is not back-filled with invented numbers).
- **Daily morning reminder** (Settings): pick a time; it nudges you to open the app. The text is
  deliberately generic so it never shows stale risk numbers.
- Settings screen: theme, language, reminder, saved reports.

### Technical
- New dependency: `timezone`. Android: core-library desugaring + scheduled-notification receivers added.
- Run `flutter pub get`, then a full rebuild (`flutter clean` recommended after the Gradle change).

## 1.1.0 — usability & accuracy upgrade

### New
- **Choose your area manually** (bottom sheet) when GPS is off/denied; choice is remembered. "Use GPS" switches back.
- **Rainfall outlook**: past 7 + next 7 days chart per district with a plain-language prevention hint.
- **National picture card** (cases / deaths / this week) with clear source status: live, saved, or *sample*.
- **Quick actions**: symptom check, hospitals, call 16263.
- **Search + sort** for the district list (by risk or A–Z).
- **Hospital layer on the map** + "View hospitals" in the district sheet.
- **Offline support**: last weather & national data are cached and shown when there is no network.
- **Language choice is remembered** between launches.
- Alerts screen is now **generated from live data** (was a hardcoded list), with reasons per district.

### Improved
- Weather: **one request for all 12 districts** (was 6 requests, and only 6 districts got live data).
- Risk index now uses **7-day rainfall** (dengue breeding follows rain) and is recomputed from live weather.
  The factor breakdown on Home shows the *real* contribution of each input.
- Symptom checker: added **WHO-style warning signs** (severe abdominal pain, repeated vomiting, bleeding,
  drowsiness/restlessness). Any warning sign → "go to hospital now" with 999 / 16263 buttons.
  Added do / don't advice (avoid NSAIDs such as aspirin/ibuprofen) and danger signs to watch for.
- Notifications limited to **once per day per situation** (previously fired on every launch/refresh); iOS init added.
- Splash no longer waits on notification permission or network (~1.6 s).
- "Your Area" no longer silently shows the highest-risk district when GPS is unavailable.
- Far-from-district GPS fixes are labelled "Nearest monitored district"; fixes outside Bangladesh are ignored.
- iOS: added missing location usage string (the app would crash when requesting GPS).

### Honesty fixes (important)
- The app previously claimed an "XGBoost + LSTM ensemble", SHAP explanations, an accuracy target and DGHS
  officer overrides. None of these exist in the code: the score is a hand-written weighted formula.
  About screen, badges and comments now describe it accurately as a **rule-based awareness index**.
- Per-district weekly case counts are **sample data** (marked "sample" in the UI) until a real feed is connected.
- The scraper no longer invents a "this week" figure (it used to be 2% of the yearly total).

### Setup
Run `flutter pub get` (new dependency: `shared_preferences`).
