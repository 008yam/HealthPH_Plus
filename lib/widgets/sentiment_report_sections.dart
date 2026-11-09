import 'package:flutter/material.dart';
import '../localization/app_translations.dart';
import '../models/sentiment_pulse_report.dart';
import 'satisfaction_trend_chart.dart';
import 'sentiment_visuals.dart';

String reportingPercent(double? value) =>
    value == null ? '' : '${value.toStringAsFixed(1)}%';
String reportingChange(double? value) {
  if (value == null) return '';
  final rounded = double.parse(value.toStringAsFixed(1));
  return '${rounded > 0 ? '+' : ''}${(rounded == 0 ? 0.0 : rounded).toStringAsFixed(1)} pp';
}

class ReportingPeriods extends StatelessWidget {
  final SentimentPulseReport report;
  const ReportingPeriods({super.key, required this.report});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DefaultTextStyle.merge(
      style: const TextStyle(fontSize: 11, color: reportingMuted, height: 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${context.tr('Current period')}: ${report.filters['startDate']} - ${report.filters['endDate']}',
          ),
          Text(
            '${context.tr('Previous period')}: ${report.sentimentTrends.baselineStart} - ${report.sentimentTrends.baselineEnd}',
          ),
          Text('${context.tr('Observed through')}: ${report.asOf}'),
        ],
      ),
    ),
  );
}

class ReportingHeading extends StatelessWidget {
  final String label;
  const ReportingHeading(this.label, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(
      context.tr(label),
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: reportingInk,
      ),
    ),
  );
}

class ReportingDistributionRow extends StatelessWidget {
  final String category;
  final int? count;
  final double? share;
  const ReportingDistributionRow(
    this.category,
    this.count,
    this.share, {
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    const names = {
      'calm': 'Calm',
      'worried': 'Worried',
      'satisfied': 'Satisfied',
      'neutral': 'Neutral',
      'dissatisfied': 'Dissatisfied',
    };
    const colors = {
      'calm': calmColor,
      'worried': worriedColor,
      'satisfied': Color(0xFF15803D),
      'neutral': Color(0xFF687582),
      'dissatisfied': Color(0xFFD82727),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            children: [
              Text(context.tr(names[category] ?? category)),
              Text(
                share == null
                    ? context.tr('Unavailable')
                    : reportingPercent(share),
              ),
            ],
          ),
          Text(
            count == null
                ? context.tr('Unavailable')
                : context.tr('{count} answers', parameters: {'count': count!}),
          ),
          if (share != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: LinearProgressIndicator(
                minHeight: 7,
                borderRadius: BorderRadius.circular(4),
                value: share! / 100,
                color: colors[category],
                backgroundColor: const Color(0xFFE5E7EB),
                semanticsLabel: context.tr(names[category] ?? category),
                semanticsValue: reportingPercent(share),
              ),
            ),
        ],
      ),
    );
  }
}

class ReportingSentiment extends StatelessWidget {
  final SentimentSummary summary;
  final List<SentimentDistributionItem> distribution;
  final bool visual;
  final bool showDistribution;
  const ReportingSentiment(
    this.summary,
    this.distribution, {
    super.key,
    this.visual = false,
    this.showDistribution = true,
  });
  @override
  Widget build(BuildContext context) {
    if (summary.status == 'not_configured') {
      return Text(context.tr('Not configured'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (summary.eligibleAnswers == 0)
          Text(context.tr('No eligible answers'))
        else if (summary.predictedAnswers == 0)
          Text(context.tr('No results yet')),
        if (summary.dominantCategory == 'tie')
          Text(context.tr('Calm / Worried: 50% each')),
        if (visual) ...[
          SentimentTiles(items: distribution),
          SentimentRing(items: distribution),
        ],
        Text(
          context.tr(
            '{analyzed}/{total} analyzed; {missing} without results',
            parameters: {
              'analyzed': summary.predictedAnswers,
              'total': summary.eligibleAnswers,
              'missing': summary.answersWithoutResults,
            },
          ),
        ),
        Text(
          '${context.tr('Analysis coverage')}: ${summary.analysisCoverage == null ? context.tr('Unavailable') : reportingPercent(summary.analysisCoverage)}',
        ),
        if (summary.analysisCoverage != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: LinearProgressIndicator(
              value: (summary.analysisCoverage! / 100).clamp(0, 1),
              minHeight: 5,
              color: calmColor,
              backgroundColor: const Color(0xFFE0E6EF),
              semanticsLabel: context.tr('Analysis coverage'),
              semanticsValue: reportingPercent(summary.analysisCoverage),
            ),
          ),
        if (!visual && showDistribution)
          for (final item in distribution)
            ReportingDistributionRow(item.category, item.answers, item.share),
      ],
    );
  }
}

class ReportingSatisfaction extends StatelessWidget {
  final SatisfactionSummary summary;
  final List<SatisfactionDistributionItem> distribution;
  const ReportingSatisfaction(this.summary, this.distribution, {super.key});
  @override
  Widget build(BuildContext context) {
    if (summary.status == 'not_configured') {
      return Text(context.tr('Not configured'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          summary.satisfactionAnswers == 0
              ? context.tr('No scored answers')
              : reportingPercent(summary.satisfactionShare),
        ),
        Text(
          context.tr(
            '{satisfied}/{total} answers satisfied',
            parameters: {
              'satisfied': summary.satisfiedAnswers,
              'total': summary.satisfactionAnswers,
            },
          ),
        ),
        for (final item in distribution)
          ReportingDistributionRow(item.category, item.answers, item.share),
      ],
    );
  }
}

class ReportingChange extends StatelessWidget {
  final String label;
  final SentimentChange change;
  const ReportingChange(this.label, this.change, {super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ReportingHeading(label),
      Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          for (final entry in {
            'Calm': change.calm,
            'Worried': change.worried,
          }.entries)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  entry.value == null || entry.value == 0
                      ? Icons.remove
                      : entry.value! > 0
                      ? Icons.north_east
                      : Icons.south_east,
                  size: 16,
                  color: entry.key == 'Calm' ? calmColor : worriedColor,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${context.tr(entry.key)}: ${entry.value == null ? context.tr('No comparable results') : reportingChange(entry.value)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    ],
  );
}

class ReportingOverview extends StatelessWidget {
  final SentimentPulseReport report;
  const ReportingOverview({super.key, required this.report});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
    children: [
      const ReportingHeading('Overall Sentiment'),
      ReportingSentiment(
        report.sentiment,
        report.sentimentDistribution,
        visual: true,
      ),
      ReportingChange(
        'vs previous Overview',
        report.sentimentTrends.overviewChange,
      ),
      const SizedBox(height: 16),
      ReportingPeriods(report: report),
      const Divider(height: 24, color: Color(0xFFD7DEEA)),
      const ReportingHeading('Satisfaction'),
      ReportingSatisfaction(
        report.satisfaction,
        report.satisfactionDistribution,
      ),
      if (report.satisfaction.status != 'not_configured')
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(context.tr('Daily satisfied share')),
          children: [
            SatisfactionTrendChart(points: report.satisfactionTrend),
            for (final point in report.satisfactionTrend)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${point.date}: ${point.satisfactionShare == null ? context.tr('Unavailable') : reportingPercent(point.satisfactionShare)}\n'
                    '${context.tr('{satisfied}/{total} answers satisfied', parameters: {'satisfied': point.satisfiedAnswers, 'total': point.satisfactionAnswers})}',
                  ),
                ),
              ),
          ],
        ),
    ],
  );
}

class ReportingTrends extends StatelessWidget {
  final SentimentPulseReport report;
  const ReportingTrends({super.key, required this.report});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
    children: [
      const ReportingHeading('Sentiment Trends'),
      if (report.sentimentTrends.surveys.isEmpty)
        Text(context.tr('No eligible surveys')),
      for (final survey in report.sentimentTrends.surveys)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD7DEEA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  survey.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  survey.surveyId,
                  style: const TextStyle(fontSize: 12, color: reportingMuted),
                ),
                const SizedBox(height: 12),
                SentimentComparisonColumns(
                  previous: survey.previousSentimentDistribution,
                  current: survey.sentimentDistribution,
                ),
                const SizedBox(height: 12),
                ReportingSentiment(
                  survey.sentiment,
                  survey.sentimentDistribution,
                  showDistribution: false,
                ),
                ReportingChange(
                  'vs previous Overview',
                  survey.changeFromOverviewBaseline,
                ),
                ReportingChange(
                  "vs this survey's previous period",
                  survey.changeFromPreviousPeriod,
                ),
              ],
            ),
          ),
        ),
      ReportingPeriods(report: report),
    ],
  );
}

class ReportingRegional extends StatelessWidget {
  final SentimentPulseReport report;
  final VoidCallback? onChooseRegion;
  const ReportingRegional({
    super.key,
    required this.report,
    this.onChooseRegion,
  });
  @override
  Widget build(BuildContext context) {
    final region = report.regional;
    if (region.status == 'region_required') {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.tr('Choose a region to view Regional analysis.')),
              TextButton(
                onPressed: onChooseRegion,
                child: Text(context.tr('Choose region')),
              ),
            ],
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
      children: [
        Row(
          children: [
            const Icon(Icons.location_on_outlined, color: calmColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                region.regionLabel!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: onChooseRegion,
              tooltip: context.tr('Choose region'),
              icon: const Icon(Icons.tune),
            ),
          ],
        ),
        Text('${region.filters['startDate']} - ${region.filters['endDate']}'),
        Text(context.tr('Regional includes all existing surveys.')),
        const ReportingHeading('Regional Sentiment'),
        if (region.sentiment!.status != 'not_configured')
          RegionalSentimentSplit(
            items: region.sentimentDistribution,
            dominantCategory: region.sentiment!.dominantCategory,
          ),
        const SizedBox(height: 16),
        ReportingSentiment(
          region.sentiment!,
          region.sentimentDistribution,
          showDistribution: false,
        ),
        const ReportingHeading('Analyzed submissions'),
        Text(
          region.analyzedSubmissions == null
              ? context.tr(
                  'Exact count unavailable; {count} linked submissions',
                  parameters: {'count': region.linkedAnalyzedSubmissions!},
                )
              : '${region.analyzedSubmissions}',
        ),
        if (region.submissionCountStatus == 'incomplete')
          Text(context.tr('Submission links are incomplete.')),
        const Divider(height: 24, color: Color(0xFFD7DEEA)),
        const ReportingHeading('Satisfaction'),
        Text(context.tr('Scored answers linked to analyzed submissions only.')),
        if (region.satisfaction!.status != 'not_configured')
          SatisfactionDonut(
            items: region.satisfactionDistribution,
            share: region.satisfaction!.satisfactionShare,
          ),
        ReportingSatisfaction(
          region.satisfaction!,
          region.satisfactionDistribution,
        ),
      ],
    );
  }
}
