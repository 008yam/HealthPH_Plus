class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    "API_BASE_URL",
    defaultValue: "http://127.0.0.1:8000",
  );

  // Leave unset when a single backend hosts all mobile features.
  static const String sentimentBaseUrl = String.fromEnvironment(
    'SENTIMENT_API_BASE_URL',
    defaultValue: baseUrl,
  );

  static const String environmentalBaseUrl = String.fromEnvironment(
    'ENVIRONMENTAL_API_BASE_URL',
    defaultValue: baseUrl,
  );

  static final String healthLiteracyBaseUrl = Uri.parse(
    const String.fromEnvironment(
      "HEALTH_LITERACY_API_BASE_URL",
      defaultValue: "https://healthph.onrender.com/api",
    ),
  ).origin;
}
