import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import 'api_config.dart';

class WeatherService {
  final String baseUrl;

  WeatherService({this.baseUrl = ApiConfig.environmentalBaseUrl});

  Future<List<Map<String, String>>> getLocations() async {
    final base = Uri.parse(baseUrl);
    var path = base.path.replaceFirst(RegExp(r'/+$'), "");
    if (!path.endsWith('/api')) path = '$path/api';
    final url = base.replace(
      path: '$path/mobile/environmental-data/locations',
      queryParameters: const {},
      fragment: '',
    );
    final response = await http
        .get(url, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception('Environmental locations: HTTP ${response.statusCode}');
    }
    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic> || body['items'] is! List) {
      throw const FormatException('Invalid region catalog');
    }
    final result = <String, Map<String, String>>{};
    for (final item in body['items'] as List) {
      if (item is! Map<String, dynamic>) continue;
      final code = item['region'];
      final name = item['region_name'];
      final location = item['reference_location'];
      if (code is! String ||
          code.isEmpty ||
          name is! String ||
          location is! Map<String, dynamic> ||
          location['name'] is! String) {
        continue;
      }
      result[code] = {
        'code': code,
        'name': name,
        'city': location['name'] as String,
      };
    }
    if (result.isEmpty) throw const FormatException('No supported regions');
    return result.values.toList();
  }

  Future<WeatherModel> getWeather({String region = 'NCR'}) =>
      _fetch(region: region, airQuality: false);

  Future<WeatherModel> getAirQuality({String region = 'NCR'}) =>
      _fetch(region: region, airQuality: true);

  Future<WeatherModel> _fetch({
    required String region,
    required bool airQuality,
  }) async {
    final base = Uri.parse(baseUrl);

    if (!['http', 'https'].contains(base.scheme) || base.host.isEmpty) {
      throw const FormatException('Invalid environmental API base URL');
    }

    var path = base.path.replaceFirst(RegExp(r'/+$'), '');
    if (!path.endsWith('/api')) path = '$path/api';

    final resource = airQuality ? 'air-quality' : 'weather';
    final url = base.replace(
      path: '$path/mobile/environmental-data/$resource',
      queryParameters: {'region': region},
      fragment: '',
    );

    // Both endpoints are public. No Authorization header is needed.
    final response = await http
        .get(url, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Environmental $resource: HTTP ${response.statusCode}');
    }

    final json = jsonDecode(response.body);
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Expected environmental response object');
    }

    return WeatherModel.fromJson(json, airQuality: airQuality);
  }
}
