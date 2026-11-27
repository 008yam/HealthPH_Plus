class ContributionLoadResult {
  final List<ContributionReport> reports;
  final bool isLocalFallback;
  final String? warning;
  final String? error;
  final bool authenticationRequired;

  const ContributionLoadResult({
    required this.reports,
    this.isLocalFallback = false,
    this.warning,
    this.error,
    this.authenticationRequired = false,
  });
}

class ContributionReport {
  final String id;
  final String status;
  final String condition;
  final String location;
  final String language;
  final String notes;
  final DateTime? createdAt;
  final List<String> symptoms;

  const ContributionReport({
    required this.id,
    required this.status,
    required this.condition,
    required this.location,
    required this.language,
    required this.notes,
    required this.createdAt,
    required this.symptoms,
  });

  factory ContributionReport.fromJson(Map<String, dynamic> json) {
    final location = _asMap(json['location']);
    final createdAt = DateTime.tryParse(_text(json['createdAt']));

    return ContributionReport(
      id: _text(json['id'], fallback: 'Mongo report'),
      status: _text(json['status'], fallback: 'submitted'),
      condition: _text(
        json['possibleConditionLabel'],
        fallback: 'Respiratory symptoms',
      ),
      location: _joinLocation([
        location['barangayName'],
        location['cityName'],
        location['provinceName'],
      ]),
      language: _text(json['language']),
      notes: _text(json['notes']),
      createdAt: createdAt,
      symptoms: _stringList(json['symptomLabels']),
    );
  }

  String get dateLabel {
    final date = createdAt?.toLocal();

    if (date == null) return 'Date unavailable';

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '${date.month}/${date.day}/${date.year} at $hour:$minute';
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  static List<String> _stringList(Object? value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    final text = _text(value);
    return text.isEmpty ? [] : [text];
  }

  static String _text(Object? value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static String _joinLocation(List<Object?> parts) {
    final location = parts
        .map(_text)
        .where((part) => part.isNotEmpty)
        .join(', ');

    return location.isEmpty ? 'Location unavailable' : location;
  }
}
