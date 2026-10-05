import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../theme/app_theme.dart';

class WeatherWidget extends StatefulWidget {
  final bool compact;
  const WeatherWidget({
    super.key,
    this.compact = false,
  });

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  late Future<WeatherModel> weatherFuture;

  @override
  void initState() {
    super.initState();
    weatherFuture = WeatherService().getWeather();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: weatherFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: widget.compact ? 78 : 120,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            height: widget.compact ? 78 : 120,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child:  const Text(
              "Wearher unavailable",
              style: TextStyle(color: AppTheme.mutedText),

            ),
          );
        }

        final weather = snapshot.data!;

        if (widget.compact) {
          return _CompactWeatherCard(weather: weather);
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weather.city,
                style: const TextStyle(
                  color: AppTheme.text,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Text(
                "Today",
                style: TextStyle(color: AppTheme.mutedText, fontSize: 10),
              ),

              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.wb_sunny,
                          color: Colors.orange,
                          size: 50,
                        ),

                        const SizedBox(width: 12),

                        Text(
                          "${weather.temperature.toInt()}°C",
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Color(0XFF243B8F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    const Text(
                      "Sunny",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: WeatherInfoItem(
                            icon: Icons.water_drop,
                            value: "${weather.humidity}%",
                            label: "Humidity",
                          ),
                        ),
                        Expanded(
                          child: WeatherInfoItem(
                            icon: Icons.water_drop,
                            value: "${weather.humidity}%",
                            label: "Humidity",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: WeatherInfoItem(
                            icon: Icons.speed,
                            value: "${weather.pressure}",
                            label: "Pressure",
                          ),
                        ),

                        Expanded(
                          child: WeatherInfoItem(
                            icon: Icons.blur_on,
                            value: "${weather.aqi}",
                            label: "AQI",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CompactWeatherCard extends StatelessWidget {
  final WeatherModel weather;

  const _CompactWeatherCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 78),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wb_sunny_rounded,
              color: Colors.orange,
              size: 28,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weather.city,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${weather.temperature.round()}°C · Today",
                  style: const TextStyle(
                    color: AppTheme.navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _CompactMetric(
                icon: Icons.water_drop_outlined,
                value: "${weather.humidity}%",
              ),
              _CompactMetric(
                icon: Icons.blur_on_rounded,
                value: "AQI ${weather.aqi}",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactMetric extends StatelessWidget {
  final IconData icon;
  final String value;

  const _CompactMetric({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.primary),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.text,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class WeatherInfoItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const WeatherInfoItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.navy),

        const SizedBox(width: 8),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.text,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),

            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
