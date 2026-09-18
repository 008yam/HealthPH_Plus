class MobileAlertsPage {
  final List<MobileAlert> items;
  final String? nextCursor;
  final int unreadCount;

  const MobileAlertsPage({
    required this.items,
    required this.nextCursor,
    required this.unreadCount,
  });

  factory MobileAlertsPage.fromJson(Map<String, dynamic> json) {
    return MobileAlertsPage(
      items: (json["items"] as List? ?? [])
          .whereType<Map>()
          .map((item) => MobileAlert.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      nextCursor: json["nextCursor"]?.toString(),
      unreadCount: _intValue(json["unreadCount"]),
    );
  }
}

class MobileAlert {
  final String id;
  final String type;
  final String region;
  final String regionName;
  final String title;
  final String message;
  final int reportCount;
  final int threshold;
  final int windowMinutes;
  final DateTime? publishedAt;
  final DateTime? readAt;

  const MobileAlert({
    required this.id,
    required this.type,
    required this.region,
    required this.regionName,
    required this.title,
    required this.message,
    required this.reportCount,
    required this.threshold,
    required this.windowMinutes,
    required this.publishedAt,
    required this.readAt,
  });

  factory MobileAlert.fromJson(Map<String, dynamic> json) {
    return MobileAlert(
      id: _textValue(json["id"]),
      type: _textValue(json["type"]),
      region: _textValue(json["region"]),
      regionName: _textValue(json["regionName"]),
      title: _textValue(json["title"], fallback: "HealthAlert"),
      message: _textValue(json["message"]),
      reportCount: _intValue(json["reportCount"]),
      threshold: _intValue(json["threshold"], fallback: 5),
      windowMinutes: _intValue(json["windowMinutes"], fallback: 1440),
      publishedAt: DateTime.tryParse(_textValue(json["publishedAt"])),
      readAt: DateTime.tryParse(_textValue(json["readAt"])),
    );
  }

  String get locationLabel {
    final regionText = regionName.isNotEmpty ? regionName : region;
    return "$regionText . $windowLabel";
  }

  String get windowLabel {
    if (windowMinutes >= 60) return "${windowMinutes ~/ 60}h window";
    return "${windowMinutes}m window";
  }

  String get countLabel => "$reportCount reports";

  double get progress {
    if (threshold <= 0) return 0;
    return (reportCount / threshold).clamp(0.0, 1.0).toDouble();
  }
}

class MobileAlertReadResult {
  final MobileAlert item;
  final int unreadCount;

  const MobileAlertReadResult({required this.item, required this.unreadCount});

  factory MobileAlertReadResult.fromJson(Map<String, dynamic> json) {
    return MobileAlertReadResult(
      item: MobileAlert.fromJson(
        Map<String, dynamic>.from(json["item"] as Map),
      ),
      unreadCount: _intValue(json["unreadCount"]),
    );
  }
}

String _textValue(Object? value, {String fallback = ""}) {
  final text = value?.toString().trim() ?? "";
  return text.isEmpty ? fallback : text;
}

int _intValue(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? "") ?? fallback;
}
