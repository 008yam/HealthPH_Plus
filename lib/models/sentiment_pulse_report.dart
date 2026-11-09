import 'sentiment_report_filters.dart';

Never _invalidReport() =>
    throw const FormatException('Invalid sentiment report');
int? _reportCount(
  Map<String, dynamic> json,
  String key, {
  bool nullable = false,
}) {
  final value = json[key];
  if (!json.containsKey(key)) {
    _invalidReport();
  }
  if (nullable && value == null) return null;
  if (value is! int || value < 0) {
    _invalidReport();
  }
  return value;
}

double? _reportNumber(
  Map<String, dynamic> json,
  String key, {
  bool signed = false,
}) {
  if (!json.containsKey(key)) {
    _invalidReport();
  }
  final value = json[key];
  if (value == null) return null;
  if (value is! num ||
      !value.isFinite ||
      value > 100 ||
      value < (signed ? -100 : 0)) {
    _invalidReport();
  }
  return value.toDouble();
}

SentimentSummary _summary(Map<String, dynamic> json) {
  if (!['configured', 'not_configured'].contains(json['status']) ||
      !json.containsKey('dominantCategory') ||
      ![null, 'calm', 'worried', 'tie'].contains(json['dominantCategory'])) {
    _invalidReport();
  }
  for (final key in [
    'eligibleAnswers',
    'predictedAnswers',
    'answersWithoutResults',
  ]) {
    _reportCount(json, key);
  }
  _reportNumber(json, 'dominantShare');
  _reportNumber(json, 'analysisCoverage');
  return SentimentSummary.fromJson(json);
}

List<SentimentDistributionItem> _distribution(Object? raw) {
  final list = (raw as List).map((item) {
    final json = item as Map<String, dynamic>;
    _reportCount(json, 'answers');
    _reportNumber(json, 'share');
    return SentimentDistributionItem.fromJson(json);
  }).toList();
  if (list.length != 2 ||
      list[0].category != 'calm' ||
      list[1].category != 'worried') {
    _invalidReport();
  }
  return List.unmodifiable(list);
}

class SentimentChange {
  final double? calm, worried;
  const SentimentChange(this.calm, this.worried);
  factory SentimentChange.fromJson(Map<String, dynamic> json) =>
      SentimentChange(
        _reportNumber(json, 'calm', signed: true),
        _reportNumber(json, 'worried', signed: true),
      );
}

class SurveySentimentComparison {
  final String surveyId, title;
  final SentimentSummary sentiment, previousSentiment;
  final List<SentimentDistributionItem> sentimentDistribution,
      previousSentimentDistribution;
  final SentimentChange changeFromOverviewBaseline, changeFromPreviousPeriod;
  SurveySentimentComparison.fromJson(Map<String, dynamic> json)
    : surveyId = json['surveyId'] as String,
      title = json['title'] as String,
      sentiment = _summary(json['sentiment'] as Map<String, dynamic>),
      previousSentiment = _summary(
        json['previousSentiment'] as Map<String, dynamic>,
      ),
      sentimentDistribution = _distribution(json['sentimentDistribution']),
      previousSentimentDistribution = _distribution(
        json['previousSentimentDistribution'],
      ),
      changeFromOverviewBaseline = SentimentChange.fromJson(
        json['changeFromOverviewBaseline'] as Map<String, dynamic>,
      ),
      changeFromPreviousPeriod = SentimentChange.fromJson(
        json['changeFromPreviousPeriod'] as Map<String, dynamic>,
      );
}

class SentimentComparisons {
  final String baselineStart, baselineEnd;
  final SentimentSummary baselineSentiment;
  final List<SentimentDistributionItem> baselineDistribution;
  final SentimentChange overviewChange;
  final List<SurveySentimentComparison> surveys;
  SentimentComparisons.fromJson(Map<String, dynamic> json)
    : baselineStart =
          (json['baseline'] as Map<String, dynamic>)['startDate'] as String,
      baselineEnd =
          (json['baseline'] as Map<String, dynamic>)['endDate'] as String,
      baselineSentiment = _summary(
        (json['baseline'] as Map<String, dynamic>)['sentiment']
            as Map<String, dynamic>,
      ),
      baselineDistribution = _distribution(
        (json['baseline'] as Map<String, dynamic>)['sentimentDistribution'],
      ),
      overviewChange = SentimentChange.fromJson(
        json['overviewChange'] as Map<String, dynamic>,
      ),
      surveys = List.unmodifiable(
        (json['surveys'] as List).map(
          (row) =>
              SurveySentimentComparison.fromJson(row as Map<String, dynamic>),
        ),
      ) {
    if (json['comparison'] != 'previous-equal-calendar-period' ||
        json['changeUnit'] != 'percentage-points' ||
        reportDate(baselineStart).isAfter(reportDate(baselineEnd))) {
      _invalidReport();
    }
  }
}

class RegionalReport {
  final String status, regionSource;
  final String? regionCode, regionLabel;
  final Map<String, dynamic> filters;
  final SentimentSummary? sentiment;
  final List<SentimentDistributionItem> sentimentDistribution;
  final SatisfactionSummary? satisfaction;
  final List<SatisfactionDistributionItem> satisfactionDistribution;
  final int? analyzedSubmissions, linkedAnalyzedSubmissions;
  final String? submissionCountStatus, satisfactionScope;
  RegionalReport.fromJson(Map<String, dynamic> json)
    : status = json['status'] as String,
      regionSource = json['regionSource'] as String,
      regionCode = json['regionCode'] as String?,
      regionLabel = json['regionLabel'] as String?,
      filters = Map.unmodifiable(json['filters'] as Map<String, dynamic>),
      sentiment = json['status'] == 'region_required'
          ? null
          : _summary(json['sentiment'] as Map<String, dynamic>),
      sentimentDistribution = json['status'] == 'region_required'
          ? const []
          : _distribution(json['sentimentDistribution']),
      satisfaction = json['status'] == 'region_required'
          ? null
          : SatisfactionSummary.fromJson(
              json['satisfaction'] as Map<String, dynamic>,
            ),
      satisfactionDistribution = json['status'] == 'region_required'
          ? const []
          : List.unmodifiable(
              (json['satisfactionDistribution'] as List).map(
                (item) => SatisfactionDistributionItem.fromJson(
                  item as Map<String, dynamic>,
                ),
              ),
            ),
      analyzedSubmissions = json['status'] == 'region_required'
          ? null
          : _reportCount(json, 'analyzedSubmissions', nullable: true),
      linkedAnalyzedSubmissions = json['status'] == 'region_required'
          ? null
          : _reportCount(json, 'linkedAnalyzedSubmissions'),
      submissionCountStatus = json['submissionCountStatus'] as String?,
      satisfactionScope = json['satisfactionScope'] as String? {
    if (!['available', 'region_required'].contains(status) ||
        !['selection', 'profile'].contains(regionSource) ||
        filters['timezone'] != 'Asia/Manila' ||
        filters['participants'] != 'all' ||
        filters['surveyVisibility'] != 'all-existing-surveys' ||
        filters['surveyId'] != null ||
        filters['unknownRegionIncluded'] != false ||
        reportDate(
          filters['startDate'] as String,
        ).isAfter(reportDate(filters['endDate'] as String))) {
      _invalidReport();
    }
    final regions = filters['regions'] as List;
    if (status == 'region_required') {
      if (regionCode != null || regionLabel != null || regions.isNotEmpty) {
        _invalidReport();
      }
    } else {
      if (regionCode == null ||
          regionLabel == null ||
          regions.length != 1 ||
          regions.single != regionCode ||
          !['exact', 'incomplete'].contains(submissionCountStatus) ||
          satisfactionScope != 'linked_analyzed_submissions') {
        _invalidReport();
      }
      final scored = json['satisfaction'] as Map<String, dynamic>;
      if (!['configured', 'not_configured'].contains(scored['status'])) {
        _invalidReport();
      }
      _reportCount(scored, 'satisfactionAnswers');
      _reportCount(scored, 'satisfiedAnswers');
      _reportNumber(scored, 'satisfactionShare');
      final categories = <String>{};
      for (final raw in json['satisfactionDistribution'] as List) {
        final item = raw as Map<String, dynamic>;
        if (![
              'satisfied',
              'neutral',
              'dissatisfied',
            ].contains(item['category']) ||
            !categories.add(item['category'] as String)) {
          _invalidReport();
        }
        _reportCount(item, 'answers', nullable: true);
        _reportNumber(item, 'share');
      }
      if (categories.length != 3) {
        _invalidReport();
      }
    }
  }
}

class SentimentSummary {
  final String status;
  final String? dominantCategory;
  final double? dominantShare;
  final int eligibleAnswers;
  final int predictedAnswers;
  final int answersWithoutResults;
  final double? analysisCoverage;

  const SentimentSummary({
    required this.status,
    required this.dominantCategory,
    required this.dominantShare,
    required this.eligibleAnswers,
    required this.predictedAnswers,
    required this.answersWithoutResults,
    required this.analysisCoverage,
  });

  factory SentimentSummary.fromJson(Map<String, dynamic> json) {
    return SentimentSummary(
      status: json['status'] as String,
      dominantCategory: json['dominantCategory'] as String?,
      dominantShare: (json['dominantShare'] as num?)?.toDouble(),
      eligibleAnswers: json['eligibleAnswers'] as int,
      predictedAnswers: json['predictedAnswers'] as int,
      answersWithoutResults: json['answersWithoutResults'] as int,
      analysisCoverage: (json['analysisCoverage'] as num?)?.toDouble(),
    );
  }
}

class SatisfactionSummary {
  final String status;
  final int satisfactionAnswers;
  final int satisfiedAnswers;
  final double? satisfactionShare;

  const SatisfactionSummary({
    required this.status,
    required this.satisfactionAnswers,
    required this.satisfiedAnswers,
    required this.satisfactionShare,
  });

  factory SatisfactionSummary.fromJson(Map<String, dynamic> json) {
    return SatisfactionSummary(
      status: json['status'] as String,
      satisfactionAnswers: json['satisfactionAnswers'] as int,
      satisfiedAnswers: json['satisfiedAnswers'] as int,
      satisfactionShare: (json['satisfactionShare'] as num?)?.toDouble(),
    );
  }
}

class SentimentDistributionItem {
  final String category;
  final int answers;
  final double? share;

  const SentimentDistributionItem({
    required this.category,
    required this.answers,
    required this.share,
  });

  factory SentimentDistributionItem.fromJson(Map<String, dynamic> json) {
    return SentimentDistributionItem(
      category: json['category'] as String,
      answers: json['answers'] as int,
      share: (json['share'] as num?)?.toDouble(),
    );
  }
}

class SatisfactionDistributionItem {
  final String category;
  final int? answers;
  final double? share;

  const SatisfactionDistributionItem({
    required this.category,
    required this.answers,
    required this.share,
  });

  factory SatisfactionDistributionItem.fromJson(Map<String, dynamic> json) {
    return SatisfactionDistributionItem(
      category: json['category'] as String,
      answers: json['answers'] as int?,
      share: (json['share'] as num?)?.toDouble(),
    );
  }
}

class SatisfactionTrendPoint {
  final String date;
  final int satisfactionAnswers;
  final int satisfiedAnswers;
  final double? satisfactionShare;

  const SatisfactionTrendPoint({
    required this.date,
    required this.satisfactionAnswers,
    required this.satisfiedAnswers,
    required this.satisfactionShare,
  });

  factory SatisfactionTrendPoint.fromJson(Map<String, dynamic> json) {
    return SatisfactionTrendPoint(
      date: json['date'] as String,
      satisfactionAnswers: json['satisfactionAnswers'] as int,
      satisfiedAnswers: json['satisfiedAnswers'] as int,
      satisfactionShare: (json['satisfactionShare'] as num?)?.toDouble(),
    );
  }
}

class SentimentPulseReport {
  final List<String> sources;
  final Map<String, dynamic> filters;
  final SentimentSummary sentiment;
  final SatisfactionSummary satisfaction;
  final List<SentimentDistributionItem> sentimentDistribution;
  final List<SatisfactionDistributionItem> satisfactionDistribution;
  final List<SatisfactionTrendPoint> satisfactionTrend;
  final String asOf;
  final SentimentComparisons sentimentTrends;
  final RegionalReport regional;

  const SentimentPulseReport({
    required this.sources,
    required this.filters,
    required this.sentiment,
    required this.satisfaction,
    required this.sentimentDistribution,
    required this.satisfactionDistribution,
    required this.satisfactionTrend,
    required this.asOf,
    required this.sentimentTrends,
    required this.regional,
  });

  factory SentimentPulseReport.fromJson(Map<String, dynamic> json) {
    try {
      if (!json.containsKey('asOf') ||
          !json.containsKey('sentimentTrends') ||
          !json.containsKey('regional')) {
        throw const FormatException(
          'The backend reporting build needs updating.',
        );
      }
      final asOf = json['asOf'] as String;
      if (!asOf.endsWith('+08:00') || DateTime.tryParse(asOf) == null) {
        throw const FormatException('Invalid reporting cutoff');
      }
      _validateReport(json);
      final comparisons = SentimentComparisons.fromJson(
        json['sentimentTrends'] as Map<String, dynamic>,
      );
      final currentStart = reportDate(json['filters']['startDate'] as String);
      final currentEnd = reportDate(json['filters']['endDate'] as String);
      if (reportDate(comparisons.baselineEnd).add(const Duration(days: 1)) !=
              currentStart ||
          reportDate(
                comparisons.baselineEnd,
              ).difference(reportDate(comparisons.baselineStart)).inDays !=
              currentEnd.difference(currentStart).inDays) {
        _invalidReport();
      }
      return SentimentPulseReport(
        asOf: asOf,
        sentimentTrends: comparisons,
        regional: RegionalReport.fromJson(
          json['regional'] as Map<String, dynamic>,
        ),
        sources: List<String>.unmodifiable(json['sources'] as List),
        filters: Map<String, dynamic>.unmodifiable(
          json['filters'] as Map<String, dynamic>,
        ),
        sentiment: SentimentSummary.fromJson(
          json['sentiment'] as Map<String, dynamic>,
        ),
        satisfaction: SatisfactionSummary.fromJson(
          json['satisfaction'] as Map<String, dynamic>,
        ),
        sentimentDistribution: List.unmodifiable(
          (json['sentimentDistribution'] as List).map(
            (item) => SentimentDistributionItem.fromJson(
              item as Map<String, dynamic>,
            ),
          ),
        ),
        satisfactionDistribution: List.unmodifiable(
          (json['satisfactionDistribution'] as List).map(
            (item) => SatisfactionDistributionItem.fromJson(
              item as Map<String, dynamic>,
            ),
          ),
        ),
        satisfactionTrend: List.unmodifiable(
          (json['satisfactionTrend'] as List).map(
            (item) =>
                SatisfactionTrendPoint.fromJson(item as Map<String, dynamic>),
          ),
        ),
      );
    } on TypeError {
      throw const FormatException(
        'The sentiment report contains missing or invalid fields.',
      );
    }
  }
}

void _validateReport(Map<String, dynamic> json) {
  Never invalid() => throw const FormatException('Invalid sentiment report');
  void count(Map<String, dynamic> object, String key, {bool nullable = false}) {
    final value = object[key];
    if (!object.containsKey(key) ||
        !(nullable && value == null || value is int && value >= 0)) {
      invalid();
    }
  }

  void share(Map<String, dynamic> object, String key) {
    final value = object[key];
    if (!object.containsKey(key) ||
        !(value == null ||
            value is num && value.isFinite && value >= 0 && value <= 100)) {
      invalid();
    }
  }

  final sentiment = json['sentiment'] as Map<String, dynamic>;
  final satisfaction = json['satisfaction'] as Map<String, dynamic>;
  for (final metric in [sentiment, satisfaction]) {
    if (!['configured', 'not_configured'].contains(metric['status'])) invalid();
  }
  if (!sentiment.containsKey('dominantCategory') ||
      ![
        null,
        'calm',
        'worried',
        'tie',
      ].contains(sentiment['dominantCategory'])) {
    invalid();
  }
  for (final key in [
    'eligibleAnswers',
    'predictedAnswers',
    'answersWithoutResults',
  ]) {
    count(sentiment, key);
  }
  share(sentiment, 'dominantShare');
  share(sentiment, 'analysisCoverage');
  count(satisfaction, 'satisfactionAnswers');
  count(satisfaction, 'satisfiedAnswers');
  share(satisfaction, 'satisfactionShare');
  for (final key in ['sentimentDistribution', 'satisfactionDistribution']) {
    final categories = <String>{};
    for (final raw in json[key] as List) {
      final item = raw as Map<String, dynamic>;
      final category = item['category'] as String;
      final allowed = key == 'sentimentDistribution'
          ? ['calm', 'worried']
          : ['satisfied', 'neutral', 'dissatisfied'];
      if (!allowed.contains(category) || !categories.add(category)) invalid();
      count(item, 'answers', nullable: key == 'satisfactionDistribution');
      share(item, 'share');
    }
    if (categories.length != (key == 'sentimentDistribution' ? 2 : 3)) {
      invalid();
    }
  }
  final dates = <String>{};
  for (final raw in json['satisfactionTrend'] as List) {
    final item = raw as Map<String, dynamic>;
    final date = item['date'] as String;
    reportDate(date);
    if (!dates.add(date)) invalid();
    count(item, 'satisfactionAnswers');
    count(item, 'satisfiedAnswers');
    share(item, 'satisfactionShare');
  }
  final filters = json['filters'] as Map<String, dynamic>;
  if (!SentimentReportFilters.ranges.containsKey(filters['timeRange']) ||
      filters['timezone'] != 'Asia/Manila' ||
      filters['participants'] != 'all' ||
      filters['surveyVisibility'] != 'published-to-mobile' ||
      filters['unknownRegionIncluded'] is! bool ||
      !filters.containsKey('surveyId') ||
      !(filters['surveyId'] == null || filters['surveyId'] is String)) {
    invalid();
  }
  final regions = filters['regions'] as List;
  if (regions.any((region) => region is! String)) invalid();
  if (reportDate(
    filters['startDate'] as String,
  ).isAfter(reportDate(filters['endDate'] as String))) {
    invalid();
  }
}
