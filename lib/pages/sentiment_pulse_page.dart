import '../localization/app_translations.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:healthphplus/main_page.dart';
import '../theme/responsive.dart';
import '../models/mobile_survey.dart';
import '../services/api_config.dart';
import '../services/profile_store.dart';
import '../services/sentiment_survey_service.dart';
import '../models/sentiment_pulse_report.dart';
import '../models/sentiment_report_filters.dart';
import '../widgets/sentiment_report_filter_sheet.dart';
import '../widgets/satisfaction_trend_chart.dart';

class SentimentPulsePage extends StatefulWidget {
  final int initialTabIndex;
  final SentimentPulseReport? report;
  final bool reportLoading;
  final String? reportError;
  final VoidCallback? onRetryReport;
  final ValueChanged<SentimentReportFilters>? onReportFiltersChanged;

  const SentimentPulsePage({
    super.key,
    this.initialTabIndex = 0,
    this.report,
    this.reportLoading = false,
    this.reportError,
    this.onRetryReport,
    this.onReportFiltersChanged,
  });

  @override
  State<SentimentPulsePage> createState() => _SentimentPulsePageState();
}

class _SentimentPulsePageState extends State<SentimentPulsePage> {
  SentimentReportFilters _filters = const SentimentReportFilters();

  Future<void> _chooseFilters() async {
    final selected = await showModalBottomSheet<SentimentReportFilters>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => SentimentReportFilterSheet(initial: _filters),
    );
    if (!mounted || selected == null) return;
    setState(() => _filters = selected);
    widget.onReportFiltersChanged?.call(selected);
  }

  Widget _reportTab(BuildContext context, Widget content) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              '${context.tr(SentimentReportFilters.ranges[_filters.timeRange]!)}'
              ' · ${_filters.region ?? context.tr('All regions')}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          IconButton(
            onPressed: _chooseFilters,
            tooltip: context.tr('Reporting filters'),
            icon: const Icon(Icons.filter_list),
          ),
          if (widget.onRetryReport != null)
            IconButton(
              onPressed: widget.reportLoading ? null : widget.onRetryReport,
              tooltip: context.tr('Refresh'),
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      if (_filters.timeRange == 'custom')
        Align(
          alignment: Alignment.centerLeft,
          child: Text('${_filters.startDate} - ${_filters.endDate}'),
        ),
      Expanded(child: _reportContent(context, content)),
    ],
  );

  Widget _reportContent(BuildContext context, Widget content) {
    if (widget.reportLoading) {
      return Center(
        child: CircularProgressIndicator(
          semanticsLabel: context.tr('Loading report'),
        ),
      );
    }
    if (widget.reportError != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                context.tr(widget.reportError!),
                textAlign: TextAlign.center,
              ),
              if (widget.onRetryReport != null) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: widget.onRetryReport,
                  icon: const Icon(Icons.refresh),
                  label: Text(context.tr('Retry')),
                ),
              ],
            ],
          ),
        ),
      );
    }
    if (widget.report != null && !_filters.matches(widget.report!.filters)) {
      return Center(
        child: Text(
          context.tr('Selected filters have not been loaded yet.'),
          textAlign: TextAlign.center,
        ),
      );
    }
    return content;
  }

  @override
  Widget build(BuildContext context) {
    final safeInitialIndex = widget.initialTabIndex.clamp(0, 3).toInt();
    final pagePadding = Responsive.pagePadding(context);
    final headerRadius = Responsive.isLandscapePhone(context) ? 24.0 : 45.0;
    final contentMargin = Responsive.isLandscapePhone(context)
        ? EdgeInsets.fromLTRB(pagePadding, 8, pagePadding, 8)
        : EdgeInsets.all(pagePadding * 0.8);

    return DefaultTabController(
      length: 4,
      initialIndex: safeInitialIndex,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Column(
              children: [
                // HEADER
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(headerRadius),
                      bottomRight: Radius.circular(headerRadius),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        pagePadding,
                        10,
                        pagePadding,
                        Responsive.verticalGap(context, 25, compact: 12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MainPage(),
                                  ),
                                );
                              }
                            },
                            child: Text(context.tr("Back")),
                          ),
                          SizedBox(
                            height: Responsive.verticalGap(
                              context,
                              10,
                              compact: 6,
                            ),
                          ),

                          if (!Responsive.isLandscapePhone(context))
                            Image.asset(
                              'assets/images/healthphplusbarlogo.png',
                              height: Responsive.logoHeight(context),
                            ),

                          Text(
                            context.tr("Sentiment Pulse"),
                            style: TextStyle(
                              fontSize: Responsive.isLandscapePhone(context)
                                  ? 20
                                  : 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),

                          if (!Responsive.isLandscapePhone(context))
                            Text(
                              context.tr(
                                "Community sentiment and survey satisfaction",
                              ),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.indigo,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: contentMargin,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppTheme.border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Theme(
                      data: AppTheme.lightTheme,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TabBar(
                              isScrollable: true,
                              tabAlignment: TabAlignment.start,
                              labelColor: Colors.black,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: Colors.indigo,
                              tabs: [
                                Tab(text: context.tr("Overview")),
                                Tab(text: context.tr("Trends")),
                                Tab(text: context.tr("Regional")),
                                Tab(text: context.tr("Survey")),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          Expanded(
                            child: TabBarView(
                              children: [
                                _reportTab(
                                  context,
                                  OverviewTab(report: widget.report),
                                ),
                                _reportTab(
                                  context,
                                  TrendsTab(report: widget.report),
                                ),
                                RegionalTab(),
                                SurveyTab(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OverviewTab extends StatelessWidget {
  final SentimentPulseReport? report;
  const OverviewTab({super.key, this.report});

  String _percent(double? value) =>
      value == null ? '—' : '${value.toStringAsFixed(1)}%';

  @override
  Widget build(BuildContext context) {
    final data = report;
    if (data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(context.tr('Reporting data is not connected yet.')),
        ),
      );
    }
    final sentiment = data.sentiment;
    final satisfaction = data.satisfaction;
    final String dominant;
    if (sentiment.status == 'not_configured') {
      dominant = context.tr('Not configured');
    } else if (sentiment.eligibleAnswers == 0) {
      dominant = context.tr('No eligible answers');
    } else if (sentiment.dominantCategory == null) {
      dominant = context.tr('No results yet');
    } else if (sentiment.dominantCategory == 'tie') {
      dominant = context.tr('Calm / Worried: 50% each');
    } else {
      final category = sentiment.dominantCategory == 'calm'
          ? context.tr('Calm')
          : context.tr('Worried');
      dominant = '$category · ${_percent(sentiment.dominantShare)}';
    }
    Widget summary(String title, String value, String detail) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(title),
            style: const TextStyle(color: AppTheme.mutedText),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(detail, style: const TextStyle(color: AppTheme.text)),
          const Divider(height: 24),
        ],
      ),
    );
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        summary(
          'Overall Sentiment',
          dominant,
          context.tr('Shares are based on classified answers.'),
        ),
        summary(
          'Analysis coverage',
          sentiment.status == 'not_configured'
              ? context.tr('Not configured')
              : sentiment.eligibleAnswers == 0
              ? context.tr('No eligible answers')
              : _percent(sentiment.analysisCoverage),
          context.tr(
            '{analyzed}/{total} analyzed; {missing} without results',
            parameters: {
              'analyzed': sentiment.predictedAnswers,
              'total': sentiment.eligibleAnswers,
              'missing': sentiment.answersWithoutResults,
            },
          ),
        ),
        summary(
          'Satisfaction',
          satisfaction.status == 'not_configured'
              ? context.tr('Not configured')
              : satisfaction.satisfactionAnswers == 0
              ? context.tr('No scored answers')
              : _percent(satisfaction.satisfactionShare),
          context.tr(
            '{satisfied}/{total} answers satisfied',
            parameters: {
              'satisfied': satisfaction.satisfiedAnswers,
              'total': satisfaction.satisfactionAnswers,
            },
          ),
        ),
      ],
    );
  }
}

class TrendsTab extends StatelessWidget {
  final SentimentPulseReport? report;
  const TrendsTab({super.key, this.report});

  @override
  Widget build(BuildContext context) {
    final data = report;
    if (data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(context.tr('Reporting data is not connected yet.')),
        ),
      );
    }
    String percentage(double? value) => value == null
        ? context.tr('Unavailable')
        : '${value.toStringAsFixed(1)}%';
    Widget heading(String title) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        context.tr(title),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
    Widget category(String label, int? count, double? share) {
      const colors = {
        'Calm': Color(0xFF2572A5),
        'Worried': Color(0xFFB45309),
        'Satisfied': Color(0xFF15803D),
        'Neutral': Color(0xFF687582),
        'Dissatisfied': Color(0xFFD82727),
      };
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 12,
              children: [Text(context.tr(label)), Text(percentage(share))],
            ),
            Text(
              count == null
                  ? context.tr('Unavailable')
                  : context.tr('{count} answers', parameters: {'count': count}),
            ),
            if (share != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: LinearProgressIndicator(
                  value: share / 100,
                  color: colors[label],
                  backgroundColor: const Color(0xFFE5E7EB),
                  semanticsLabel: context.tr(label),
                  semanticsValue: percentage(share),
                ),
              ),
          ],
        ),
      );
    }

    final sentiments = {
      for (final item in data.sentimentDistribution) item.category: item,
    };
    final satisfaction = {
      for (final item in data.satisfactionDistribution) item.category: item,
    };
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        heading('Sentiment distribution'),
        if (data.sentiment.status == 'not_configured')
          Text(context.tr('Not configured'))
        else
          for (final entry in {'calm': 'Calm', 'worried': 'Worried'}.entries)
            category(
              entry.value,
              sentiments[entry.key]?.answers,
              sentiments[entry.key]?.share,
            ),
        heading('Satisfaction distribution'),
        if (data.satisfaction.status == 'not_configured')
          Text(context.tr('Not configured'))
        else
          for (final entry in {
            'satisfied': 'Satisfied',
            'neutral': 'Neutral',
            'dissatisfied': 'Dissatisfied',
          }.entries)
            category(
              entry.value,
              satisfaction[entry.key]?.answers,
              satisfaction[entry.key]?.share,
            ),
        heading('Daily satisfied share'),
        if (data.satisfaction.status != 'not_configured' &&
            data.satisfactionTrend.isNotEmpty)
          SatisfactionTrendChart(points: data.satisfactionTrend),
        if (data.satisfaction.status == 'not_configured')
          Text(context.tr('Not configured'))
        else if (data.satisfactionTrend.isEmpty)
          Text(context.tr('No daily observations'))
        else
          for (final point in data.satisfactionTrend)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${point.date} · ${percentage(point.satisfactionShare)}',
                  ),
                  Text(
                    context.tr(
                      '{satisfied}/{total} answers satisfied',
                      parameters: {
                        'satisfied': point.satisfiedAnswers,
                        'total': point.satisfactionAnswers,
                      },
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

class RegionalTab extends StatelessWidget {
  const RegionalTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Text(
          context.tr("Regional Sentiment"),
          style: TextStyle(
            color: AppTheme.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        Text(
          context.tr("Dominant sentiment by region"),
          style: TextStyle(color: AppTheme.mutedText, fontSize: 12),
        ),

        SizedBox(height: 12),

        RegionalSentimentCard(
          region: "NCR",
          sentiment: "Concerned",
          percent: 45,
          color: Colors.amber,
        ),

        RegionalSentimentCard(
          region: "Region III",
          sentiment: 'Neutral',
          percent: 38,
          color: Colors.green,
        ),

        RegionalSentimentCard(
          region: "Region IV-A",
          sentiment: "Proactive",
          percent: 38,
          color: Colors.blue,
        ),

        RegionalSentimentCard(
          region: "Region VII",
          sentiment: "Concerned",
          percent: 48,
          color: Colors.amber,
        ),
      ],
    );
  }
}

class SurveyTab extends StatefulWidget {
  const SurveyTab({super.key});

  @override
  State<SurveyTab> createState() => _SurveyTabState();
}

class _SurveyTabState extends State<SurveyTab> {
  late Future<List<MobileSurvey>> surveyFuture;

  final surveyService = SentimentSurveyService(baseUrl: ApiConfig.baseUrl);

  @override
  void initState() {
    super.initState();
    surveyFuture = surveyService.fetchPublicSurveys();
  }

  void _refreshSurveys() {
    setState(() {
      surveyFuture = surveyService.fetchPublicSurveys();
    });
  }

  void _openSurvey(MobileSurvey survey) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Theme(
          data: AppTheme.lightTheme,
          child: SurveyResponseSheet(
            survey: survey,
            surveyService: surveyService,
            onSubmitted: _refreshSurveys,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MobileSurvey>>(
      future: surveyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              context.tr("Unable to load surveys."),
              style: TextStyle(
                color: AppTheme.text,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        final surveys = snapshot.data ?? [];

        if (surveys.isEmpty) {
          return Center(
            child: Text(
              context.tr("No active mobile surveys currently available."),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: surveys.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final survey = surveys[index];
            final progress = survey.target <= 0
                ? 0.0
                : (survey.responses / survey.target).clamp(0.0, 1.0);

            return InkWell(
              onTap: () => _openSurvey(survey),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      survey.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    if (survey.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        survey.subtitle,
                        style: const TextStyle(
                          color: AppTheme.mutedText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    LinearProgressIndicator(value: progress),
                    const SizedBox(height: 6),
                    Text(
                      context.tr(
                        "{survey.responses} / {survey.target} responses",
                        parameters: {
                          "survey.responses": survey.responses,
                          "survey.target": survey.target,
                        },
                      ),
                      style: const TextStyle(
                        color: AppTheme.mutedText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class SurveyResponseSheet extends StatefulWidget {
  final MobileSurvey survey;
  final SentimentSurveyService surveyService;
  final VoidCallback onSubmitted;

  const SurveyResponseSheet({
    super.key,
    required this.survey,
    required this.surveyService,
    required this.onSubmitted,
  });

  @override
  State<SurveyResponseSheet> createState() => _SurveyResponseSheetState();
}

class _SurveyResponseSheetState extends State<SurveyResponseSheet> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> answers = {};
  bool isSubmitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cleanedAnswers = Map<String, dynamic>.from(answers)
      ..removeWhere(
        (_, value) => value == null || value.toString().trim().isEmpty,
      );

    if (cleanedAnswers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr("Please answer at least one question.")),
        ),
      );
      return;
    }

    final profile = ProfileStore.instance.profile;

    final userLocation = <String, dynamic>{
      "regionCode": profile?.regionCode,
      "regionLabel": profile?.regionLabel,
      "province": profile?.province,
      "city": profile?.city,
      "barangay": profile?.barangay,
    }..removeWhere((_, value) => value == null || value == "");

    final metadata = <String, dynamic>{"roleId": profile?.roleId}
      ..removeWhere((_, value) => value == null || value == "");

    setState(() => isSubmitting = true);

    try {
      await widget.surveyService.submitSurveyResponse(
        surveyId: widget.survey.id,
        answers: cleanedAnswers,
        region: profile?.regionLabel,
        userId: profile?.id,
        userLocation: userLocation,
        metadata: metadata,
      );

      if (!mounted) return;
      Navigator.pop(context);
      widget.onSubmitted();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr("Survey response submitted."))),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr("Unable to submit survey response.")),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          18,
          16,
          18,
          MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.survey.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              if (widget.survey.subtitle.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  widget.survey.subtitle,
                  style: const TextStyle(color: AppTheme.mutedText),
                ),
              ],
              const SizedBox(height: 16),
              ...List.generate(widget.survey.questions.length, (index) {
                return _QuestionCard(
                  number: index + 1,
                  question: widget.survey.questions[index],
                  answers: answers,
                  isSubmitting: isSubmitting,
                  onChanged: () => setState(() {}),
                );
              }),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: isSubmitting ? null : _submit,
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    isSubmitting
                        ? context.tr("Submitting...")
                        : context.tr("Submit"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int number;
  final MobileSurveyQuestion question;
  final Map<String, dynamic> answers;
  final bool isSubmitting;
  final VoidCallback onChanged;

  const _QuestionCard({
    required this.number,
    required this.question,
    required this.answers,
    required this.isSubmitting,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final answer = answers[question.id];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$number. ${question.title}${question.isRequired ? " *" : ""}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: 10),
          _buildQuestionInput(context, answer),
        ],
      ),
    );
  }

  Widget _buildQuestionInput(BuildContext context, dynamic answer) {
    switch (question.type) {
      case "multipleChoice":
        return Column(
          children: question.choices.map((choice) {
            final isSelected = answer?.toString() == choice;

            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: isSubmitting
                  ? null
                  : () {
                      answers[question.id] = choice;
                      onChanged();
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isSelected ? AppTheme.primary : AppTheme.mutedText,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        choice,
                        style: const TextStyle(color: AppTheme.text),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );

      case "rating":
        final min = question.rateMin;
        final max = question.rateMax;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(max - min + 1, (index) {
            final value = min + index;
            final isSelected = answer == value;

            return ChoiceChip(
              label: Text(
                "$value",
                style: const TextStyle(color: AppTheme.text),
              ),
              selected: isSelected,
              onSelected: isSubmitting
                  ? null
                  : (_) {
                      answers[question.id] = value;
                      onChanged();
                    },
            );
          }),
        );

      case "text":
      default:
        return TextFormField(
          enabled: !isSubmitting,
          style: const TextStyle(color: AppTheme.text),
          cursorColor: AppTheme.primary,
          minLines: 2,
          maxLines: 4,
          initialValue: answer?.toString(),
          decoration: InputDecoration(
            hintText: context.tr("Type your answer"),
            hintStyle: TextStyle(color: AppTheme.mutedText),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (question.isRequired &&
                (value == null || value.trim().isEmpty)) {
              return context.tr("This question is required.");
            }
            return null;
          },
          onChanged: (value) {
            answers[question.id] = value;
          },
        );
    }
  }
}

class SentimentBox extends StatelessWidget {
  final String percent;
  final String label;
  final IconData icon;
  final Color color;
  //final count = apiData['count']; // Babalikan

  const SentimentBox({
    super.key,
    required this.percent,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 95,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    percent,
                    style: const TextStyle(
                      color: AppTheme.text,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    context.tr(label),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ),
            Icon(icon, size: 42, color: Colors.indigo),
          ],
        ),
      ),
    );
  }
}

class BarGraphCard extends StatelessWidget {
  const BarGraphCard({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      {"label": "Concerned", "value": 45, "color": AppTheme.concerned},
      {"label": "Misinfomred", "value": 28, "color": AppTheme.misinformed},
      {"label": "Neutral", "value": 18, "color": AppTheme.neutral},
      {"label": "Proactive", "value": 9, "color": AppTheme.proactive},
    ];

    return Container(
      height: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((item) {
          final int value = item["value"] as int;
          final Color color = item["color"] as Color;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("$value%", style: const TextStyle(color: AppTheme.text)),
                Container(
                  height: value * 3,
                  width: 34,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr(item["label"].toString()),
                  style: const TextStyle(color: AppTheme.text, fontSize: 10),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class TrendLineCard extends StatelessWidget {
  const TrendLineCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 178,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _trendRow(context, "Concerned", "45% → 52%", AppTheme.concerned),
          _trendRow(context, "Neutral", "35% → 44%", AppTheme.neutral),
          _trendRow(context, "Proactive", "26% → 33%", AppTheme.proactive),
          _trendRow(context, "Misinformed", "16% → 24%", AppTheme.misinformed),
        ],
      ),
    );
  }

  static Widget _trendRow(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(width: 14, height: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.tr(label),
              style: const TextStyle(color: AppTheme.text),
            ),
          ),
          Text(value, style: const TextStyle(color: AppTheme.text)),
        ],
      ),
    );
  }
}

class InsightCard extends StatelessWidget {
  final String title;
  final String value;
  final String description;
  final Color color;

  const InsightCard({
    super.key,
    required this.title,
    required this.value,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.45),
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              context.tr(title),
              style: const TextStyle(
                color: AppTheme.text,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.text,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              context.tr(description),
              style: const TextStyle(color: AppTheme.text, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class RegionMiniCard extends StatelessWidget {
  final String region;
  final String sentiment;
  final String change;

  const RegionMiniCard({
    super.key,
    required this.region,
    required this.sentiment,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.surface,
      child: ListTile(
        dense: true,
        title: Text(region, style: const TextStyle(color: AppTheme.text)),
        subtitle: Text(
          context.tr(sentiment),
          style: const TextStyle(color: AppTheme.mutedText),
        ),
        trailing: Text(
          change,
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class RegionalSentimentCard extends StatelessWidget {
  final String region;
  final String sentiment;
  final int percent;
  final Color color;

  const RegionalSentimentCard({
    super.key,
    required this.region,
    required this.sentiment,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              region,
              style: const TextStyle(
                color: AppTheme.text,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Stack(
              children: [
                Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percent / 100,
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    context.tr(sentiment),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Spacer(),

                Text(
                  context.tr(
                    "{percent}% of the population",
                    parameters: {"percent": percent},
                  ),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
