class WeatherModel {
  final String city;
  final String region;
  final String dataTime;
  final String timezone;
  final String attribution;
  final double? temperature;
  final double? humidity;
  final double? windSpeed;
  final double? aqi;
  final double? pm25;
  final double? heatIndex;
  final double? windDirection;
  final double? precipitation;
  final int? intervalSeconds;
  final int? weatherCode;

  const WeatherModel({
    required this.city,
    required this.region,
    required this.dataTime,
    required this.timezone,
    required this.attribution,
    this.temperature,
    this.humidity,
    this.windSpeed,
    this.aqi,
    this.pm25,
    this.heatIndex,
    this.windDirection,
    this.precipitation,
    this.intervalSeconds,
    this.weatherCode,
  });

  factory WeatherModel.fromJson(
    Map<String, dynamic> json, {
    required bool airQuality,
  }) {
    final data = json[airQuality ? 'air_quality' : 'weather'];
    final location = json['reference_location'];
    final attribution = json['attribution'];

    if (data is! Map<String, dynamic> ||
        location is! Map<String, dynamic> ||
        attribution is! Map<String, dynamic>) {
      throw const FormatException('Invalid environmental response');
    }

    double? number(String key) => (data[key] as num?)?.toDouble();

    return WeatherModel(
      city: location['name'] as String? ?? 'Unknown reference location',
      region: json['region'] as String? ?? '',
      dataTime: data['data_time'] as String? ?? '',
      timezone: data['timezone'] as String? ?? '',
      attribution:
          attribution['label'] as String? ??
          (airQuality ? 'Open-Meteo / CAMS' : 'Open-Meteo'),
      temperature: number('temperature'),
      humidity: number('relative_humidity'),
      windSpeed: number('wind_speed'),
      aqi: number('us_aqi'),
      pm25: number('pm25'),
      heatIndex: number('estimated_heat_index'),
      windDirection: number('wind_direction'),
      precipitation: number('precipitation'),
      intervalSeconds: (data['interval_seconds'] as num?)?.toInt(),
      weatherCode: (data['weather_code'] as num?)?.toInt(),
    );
  }
}
