import '../models/weather_model.dart';

class WeatherService {
  Future<WeatherModel> getWeather() async {
    //To be replaced with API call for weather widget later on
    return WeatherModel(
      city: "Quezon City",
      temperature: 30,
      humidity: 71,
      windSpeed: 12,
      pressure: 1012,
      aqi: 39,
    );
  }
}
