class OutbreakPoint {
  final String province;
  final String region;
  final double lat;
  final double lng;

  final List<String> annotations;

  OutbreakPoint({
    required this.province,
    required this.region,
    required this.lat,
    required this.lng,
    required this.annotations,
  });

  factory OutbreakPoint.fromJson(Map<String, dynamic> json) {
    return OutbreakPoint(
      province: json['province'] ?? '',
      region: json['region'] ?? '',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['long'] as num).toDouble(),
      annotations: List<String>.from(json['annotations'] ?? []),
    );
  }
}
