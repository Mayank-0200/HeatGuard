import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000";

  // Get weather and heat risk for current location
  static Future<Map<String, dynamic>> getWeather(
      double latitude,
      double longitude) async {
    final url = Uri.parse(
      "$baseUrl/weather?latitude=$latitude&longitude=$longitude",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Backend error: ${response.statusCode}",
      );
    }
  }

  // Get heat-risk data for all demo districts/cities
  static Future<List<dynamic>> getDistricts() async {
    final url = Uri.parse("$baseUrl/districts");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data["locations"] ?? [];
    } else {
      throw Exception(
        "District API error: ${response.statusCode}",
      );
    }
  }
}