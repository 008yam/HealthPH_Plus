import 'dart:convert';
import 'package:http/http.dart' as http;

class HealthPhApiService {
  final String baseUrl;

  HealthPhApiService({required this.baseUrl});

  Future<Map<String, dynamic>> fetchDiseasePoints() async {
    final response = await http.get(Uri.parse('$baseUrl/api/points/disease'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to loaod disease points');
  }
}
