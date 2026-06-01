class WeatherModel {
  final String city;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final int aqi;

  WeatherModel({
    required this.city,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.aqi,
  });
}
