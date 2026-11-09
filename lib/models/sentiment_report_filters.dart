/// Dates are Manila calendar dates, represented at UTC midnight without shifting.
DateTime reportDate(String value) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
    throw const FormatException('Invalid reporting date');
  }
  final date = DateTime.parse('${value}T00:00:00Z');
  if (date.toIso8601String().substring(0, 10) != value) {
    throw const FormatException('Invalid reporting date');
  }
  return date;
}

class SentimentReportFilters {
  static const ranges = {
    'last-7-days': 'Last 7 days',
    'last-30-days': 'Last 30 days',
    'last-90-days': 'Last 90 days',
    'custom': 'Custom dates',
  };
  static const regions = [
    'NCR',
    'CAR',
    'I',
    'II',
    'III',
    'IVA',
    'IVB',
    'V',
    'VI',
    'VII',
    'VIII',
    'IX',
    'X',
    'XI',
    'XII',
    'XIII',
    'BARMM',
  ];
  final String timeRange;
  final String? region;
  final String? startDate;
  final String? endDate;
  final String? regionalRegion;
  final String? surveyId;
  const SentimentReportFilters({
    this.timeRange = 'last-30-days',
    this.region,
    this.startDate,
    this.endDate,
    this.regionalRegion,
    this.surveyId,
  });

  Map<String, String> toQuery() {
    if (!ranges.containsKey(timeRange) ||
        (region != null && !regions.contains(region)) ||
        (regionalRegion != null && !regions.contains(regionalRegion)) ||
        (surveyId != null && surveyId!.trim().isEmpty)) {
      throw const FormatException('Invalid reporting filters');
    }
    if (timeRange == 'custom') {
      if (startDate == null ||
          endDate == null ||
          reportDate(startDate!).isAfter(reportDate(endDate!))) {
        throw const FormatException('Invalid reporting date range');
      }
    }
    return {
      'timeRange': timeRange,
      'regions': ?region,
      'regionalRegion': ?regionalRegion,
      'surveyId': ?surveyId,
      if (timeRange == 'custom') ...{
        'startDate': startDate!,
        'endDate': endDate!,
      },
    };
  }

  bool matches(Map<String, dynamic> applied) {
    final appliedRegions = applied['regions'];
    return applied['timeRange'] == timeRange &&
        applied['surveyId'] == surveyId &&
        applied['timezone'] == 'Asia/Manila' &&
        appliedRegions is List &&
        (region == null
            ? appliedRegions.isEmpty
            : appliedRegions.length == 1 && appliedRegions.single == region) &&
        (timeRange != 'custom' ||
            applied['startDate'] == startDate && applied['endDate'] == endDate);
  }
}
