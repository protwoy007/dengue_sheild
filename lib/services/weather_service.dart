import "dart:convert";
import "package:http/http.dart" as http;

class WeatherData {
  final double temperature;
  final double humidity;
  final double rainfall;
  final bool isLive;
  const WeatherData({
    required this.temperature,
    required this.humidity,
    required this.rainfall,
    this.isLive = false,
  });
}

class WeatherService {
  static const String _base = "https://api.open-meteo.com/v1/forecast";

  static Future<WeatherData?> fetchWeather(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        "$_base?latitude=$lat&longitude=$lng"
        "&current=temperature_2m,relative_humidity_2m,precipitation"
        "&timezone=Asia%2FDhaka&forecast_days=1"
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data["current"];
        return WeatherData(
          temperature: (current["temperature_2m"] as num).toDouble(),
          humidity:    (current["relative_humidity_2m"] as num).toDouble(),
          rainfall:    (current["precipitation"] as num).toDouble(),
          isLive: true,
        );
      }
    } catch (_) {}
    return null;
  }
}
