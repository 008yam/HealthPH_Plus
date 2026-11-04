import 'sentiment_report_filters.dart';

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

  const SentimentPulseReport({
    required this.sources,
    required this.filters,
    required this.sentiment,
    required this.satisfaction,
    required this.sentimentDistribution,
    required this.satisfactionDistribution,
    required this.satisfactionTrend,
  });

  factory SentimentPulseReport.fromJson(Map<String, dynamic> json) {
    try {
      _validateReport(json);
      return SentimentPulseReport(
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
