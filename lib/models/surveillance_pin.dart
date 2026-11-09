class SurveillancePin {
  static const diseases = ['TB', 'PN', 'COVID', 'AURI'];
  final String id;
  final String? region;
  final String? province;
  final double latitude;
  final double longitude;
  final List<String> diseaseCodes;
  final Map<String, int> diseaseCounts;
  final int processedEntryCount;

  const SurveillancePin({
    required this.id,
    this.region,
    this.province,
    required this.latitude,
    required this.longitude,
    required this.diseaseCodes,
    required this.diseaseCounts,
    required this.processedEntryCount,
  });

  factory SurveillancePin.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final lat = json['latitude'];
    final lng = json['longitude'];
    final codes = json['diseaseCodes'];
    final counts = json['diseaseCounts'];
    final total = json['processedEntryCount'];
    bool count(dynamic value) =>
        value is num &&
        value.isFinite &&
        value >= 0 &&
        value == value.roundToDouble();
    if (id is! String ||
        id.isEmpty ||
        lat is! num ||
        lng is! num ||
        !lat.isFinite ||
        !lng.isFinite ||
        lat.abs() > 90 ||
        lng.abs() > 180 ||
        codes is! List ||
        codes.any((c) => !diseases.contains(c)) ||
        counts is! Map<String, dynamic> ||
        !count(total) ||
        counts.entries.any(
          (e) => !diseases.contains(e.key) || !count(e.value),
        ) ||
        codes.any((c) => !counts.containsKey(c))) {
      throw const FormatException('Invalid surveillance pin');
    }
    return SurveillancePin(
      id: id,
      region: json['region'] is String
          ? (json['region'] as String).trim()
          :null,
      province: json['province'] is String
          ? (json['province'] as String).trim()
          : null,
      latitude: lat.toDouble(),
      longitude: lng.toDouble(),
      diseaseCodes: List<String>.unmodifiable(codes),
      diseaseCounts: Map.unmodifiable(
        counts.map((key, value) => MapEntry(key, (value as num).toInt())),
      ),
      processedEntryCount: (total as num).toInt(),
    );
  }
}
