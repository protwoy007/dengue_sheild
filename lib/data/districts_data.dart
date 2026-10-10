import "../models/district.dart";

/// Baseline / offline data. Weather values are replaced by live Open-Meteo
/// data when available. `casesThisWeek` is SAMPLE data until a real
/// district-level case feed is connected.
final List<District> allDistricts = [
  District(
    id: "dhaka", nameEn: "Dhaka", nameBn: "ঢাকা",
    divisionEn: "Dhaka Division", divisionBn: "ঢাকা বিভাগ",
    lat: 23.8103, lng: 90.4125,
    temperature: 32.4, humidity: 82.0, rainfall: 18.5, casesThisWeek: 1240,
  ),
  District(
    id: "narayanganj", nameEn: "Narayanganj", nameBn: "নারায়ণগঞ্জ",
    divisionEn: "Dhaka Division", divisionBn: "ঢাকা বিভাগ",
    lat: 23.6238, lng: 90.5000,
    temperature: 32.1, humidity: 80.0, rainfall: 16.2, casesThisWeek: 420,
  ),
  District(
    id: "chittagong", nameEn: "Chittagong", nameBn: "চট্টগ্রাম",
    divisionEn: "Chittagong Division", divisionBn: "চট্টগ্রাম বিভাগ",
    lat: 22.3569, lng: 91.7832,
    temperature: 31.8, humidity: 85.0, rainfall: 22.0, casesThisWeek: 890,
  ),
  District(
    id: "coxsbazar", nameEn: "Cox's Bazar", nameBn: "কক্সবাজার",
    divisionEn: "Chittagong Division", divisionBn: "চট্টগ্রাম বিভাগ",
    lat: 21.4272, lng: 92.0058,
    temperature: 30.5, humidity: 88.0, rainfall: 28.0, casesThisWeek: 310,
  ),
  District(
    id: "sylhet", nameEn: "Sylhet", nameBn: "সিলেট",
    divisionEn: "Sylhet Division", divisionBn: "সিলেট বিভাগ",
    lat: 24.8949, lng: 91.8687,
    temperature: 29.8, humidity: 79.0, rainfall: 14.0, casesThisWeek: 280,
  ),
  District(
    id: "comilla", nameEn: "Comilla", nameBn: "কুমিল্লা",
    divisionEn: "Chittagong Division", divisionBn: "চট্টগ্রাম বিভাগ",
    lat: 23.4607, lng: 91.1809,
    temperature: 31.2, humidity: 78.0, rainfall: 12.5, casesThisWeek: 195,
  ),
  District(
    id: "gazipur", nameEn: "Gazipur", nameBn: "গাজীপুর",
    divisionEn: "Dhaka Division", divisionBn: "ঢাকা বিভাগ",
    lat: 24.0022, lng: 90.4264,
    temperature: 31.9, humidity: 77.0, rainfall: 13.0, casesThisWeek: 340,
  ),
  District(
    id: "khulna", nameEn: "Khulna", nameBn: "খুলনা",
    divisionEn: "Khulna Division", divisionBn: "খুলনা বিভাগ",
    lat: 22.8456, lng: 89.5403,
    temperature: 30.1, humidity: 74.0, rainfall: 8.0, casesThisWeek: 95,
  ),
  District(
    id: "rajshahi", nameEn: "Rajshahi", nameBn: "রাজশাহী",
    divisionEn: "Rajshahi Division", divisionBn: "রাজশাহী বিভাগ",
    lat: 24.3745, lng: 88.6042,
    temperature: 33.2, humidity: 65.0, rainfall: 4.5, casesThisWeek: 45,
  ),
  District(
    id: "barisal", nameEn: "Barisal", nameBn: "বরিশাল",
    divisionEn: "Barisal Division", divisionBn: "বরিশাল বিভাগ",
    lat: 22.7010, lng: 90.3535,
    temperature: 30.8, humidity: 80.0, rainfall: 15.0, casesThisWeek: 130,
  ),
  District(
    id: "rangpur", nameEn: "Rangpur", nameBn: "রংপুর",
    divisionEn: "Rangpur Division", divisionBn: "রংপুর বিভাগ",
    lat: 25.7439, lng: 89.2752,
    temperature: 28.5, humidity: 68.0, rainfall: 6.0, casesThisWeek: 18,
  ),
  District(
    id: "mymensingh", nameEn: "Mymensingh", nameBn: "ময়মনসিংহ",
    divisionEn: "Mymensingh Division", divisionBn: "ময়মনসিংহ বিভাগ",
    lat: 24.7471, lng: 90.4203,
    temperature: 30.5, humidity: 76.0, rainfall: 11.0, casesThisWeek: 160,
  ),
];

District districtById(String id) =>
    allDistricts.firstWhere((d) => d.id == id, orElse: () => allDistricts.first);
