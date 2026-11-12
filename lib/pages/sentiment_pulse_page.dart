import '../localization/app_translations.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:healthphplus/main_page.dart';
import '../models/mobile_survey.dart';
import '../services/api_config.dart';
import '../services/profile_store.dart';
import '../services/sentiment_survey_service.dart';
import '../models/sentiment_pulse_report.dart';
import '../models/sentiment_report_filters.dart';
import '../widgets/sentiment_report_filter_sheet.dart';
import '../widgets/sentiment_report_sections.dart';
import '../services/sentiment_reporting_service.dart';
import '../services/sentiment_reporting_controller.dart';
import '../login_page.dart';
import '../theme/responsive.dart';

class SentimentPulsePage extends StatefulWidget {
  final int initialTabIndex;
  final SentimentPulseReport? report;
  final bool reportLoading;
  final String? reportError;
  final VoidCallback? onRetryReport;
  final ValueChanged<SentimentReportFilters>? onReportFiltersChanged;
  final SentimentReportingService? reportingService;

  const SentimentPulsePage({
    super.key,
    this.initialTabIndex = 0,
    this.report,
    this.reportLoading = false,
    this.reportError,
    this.onRetryReport,
    this.onReportFiltersChanged,
    this.reportingService,
  });

  @override
  State<SentimentPulsePage> createState() => _SentimentPulsePageState();
}

class _SentimentPulsePageState extends State<SentimentPulsePage>
    with WidgetsBindingObserver {
  SentimentReportFilters _filters = const SentimentReportFilters();
  SentimentReportingController? _controller;
  SentimentReportingService? _service;
  bool _ownsService = false;
  bool get _external =>
      widget.report != null ||
      widget.reportLoading ||
      widget.reportError != null ||
      widget.onRetryReport != null ||
      widget.onReportFiltersChanged != null;
  SentimentPulseReport? get _report =>
      _external ? widget.report : _controller?.report;
  bool get _loading =>
      _external ? widget.reportLoading : (_controller?.loading ?? false);
  String? get _error => _external ? widget.reportError : _controller?.error;
  VoidCallback? get _retry =>
      _external ? widget.onRetryReport : () => _controller?.refresh();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _configureReporting();
  }

  void _configureReporting() {
    _controller?.removeListener(_reportChanged);
    _controller?.dispose();
    _controller = null;
    if (_ownsService) _service?.dispose();
    _service = null;
    _ownsService = false;
    if (_external) return;
    _service =
        widget.reportingService ??
        SentimentReportingService(baseUrl: ApiConfig.sentimentBaseUrl);
    _ownsService = widget.reportingService == null;
    _controller = SentimentReportingController(_service!);
    _controller!.addListener(_reportChanged);
    _controller!.refresh();
  }

  void _reportChanged() {
    if (mounted) setState(() => _filters = _controller!.filters);
  }

  @override
  void didUpdateWidget(covariant SentimentPulsePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasExternal =
        oldWidget.report != null ||
        oldWidget.reportLoading ||
        oldWidget.reportError != null ||
        oldWidget.onRetryReport != null ||
        oldWidget.onReportFiltersChanged != null;
    if (wasExternal != _external ||
        oldWidget.reportingService != widget.reportingService) {
      _configureReporting();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        ModalRoute.of(context)?.isCurrent == true) {
      _controller?.refresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.removeListener(_reportChanged);
    _controller?.dispose();
    if (_ownsService) _service?.dispose();
    super.dispose();
  }

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
    _controller?.select(selected);
  }

  Widget _reportTab(
    BuildContext context,
    Widget content, {
    bool regional = false,
  }) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              '${context.tr(SentimentReportFilters.ranges[_filters.timeRange]!)}'
              ' · ${regional ? (_filters.regionalRegion ?? context.tr('Account region')) : (_filters.region ?? context.tr('All regions'))}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          IconButton(
            onPressed: _chooseFilters,
            tooltip: context.tr('Reporting filters'),
            icon: const Icon(Icons.filter_list),
          ),
          if (_retry != null)
            IconButton(
              onPressed: _loading ? null : _retry,
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
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(
          semanticsLabel: context.tr('Loading report'),
        ),
      );
    }
    if (_error != null) {
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
              Text(context.tr(_error!), textAlign: TextAlign.center),
              if (!_external && _controller?.authenticationRequired == true)
                FilledButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const LoginPage())),
                  child: Text(context.tr('Login')),
                )
              else if (_retry != null) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh),
                  label: Text(context.tr('Retry')),
                ),
              ],
            ],
          ),
        ),
      );
    }
    if (_report != null && !_filters.matches(_report!.filters)) {
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
    final headerRadius = Responsive.isLandscapePhone(context) ? 24.0 : 35.0;
    final contentMargin = Responsive.isLandscapePhone(context)
        ? EdgeInsets.fromLTRB(pagePadding, 8, pagePadding, 8)
        : EdgeInsets.all(pagePadding * 0.8);

    return Theme(
      data: AppTheme.lightTheme,
      child: DefaultTabController(
        length: 4,
        initialIndex: safeInitialIndex,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
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
                      Responsive.verticalGap(context, 16, compact: 10),
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
                                  builder: (_) => const MainPage(),
                                ),
                              );
                            }
                          },
                          child: Text(context.tr('Back')),
                        ),
                        SizedBox(
                          height: Responsive.verticalGap(context, 8),
                        ),
                        Image.asset(
                          'assets/images/healthphplusbarlogo.png',
                          height: Responsive.logoHeight(context),
                        ),
                        SizedBox(
                          height: Responsive.verticalGap(context, 8),
                        ),
                        Text(
                          context.tr('Sentiment Pulse'),
                          style: TextStyle(
                            color: AppTheme.navy,
                            fontSize: Responsive.isLandscapePhone(context)
                                ? 19
                                : 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          context.tr(
                            'Understand public concern, misinformation, '
                            'and health behavior trends.',
                          ),
                          style: const TextStyle(
                            color: AppTheme.navy,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: Responsive.verticalGap(
                            context,
                            12,
                            compact: 8,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppTheme.border),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TabBar(
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,
                            dividerColor: Colors.transparent,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                              color: AppTheme.surfaceSoft,
                              borderRadius: BorderRadius.circular(6),
                              border: const Border(
                                bottom: BorderSide(
                                  color: AppTheme.primary,
                                  width: 3,
                                ),
                              ),
                            ),
                            labelColor: AppTheme.text,
                            unselectedLabelColor: AppTheme.mutedText,
                            tabs: [
                              Tab(text: context.tr('Overview')),
                              Tab(text: context.tr('Trends')),
                              Tab(text: context.tr('Regional')),
                              Tab(text: context.tr('Survey')),
                            ],
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppTheme.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBarView(
                    children: [
                      _reportTab(
                        context,
                        OverviewTab(report: _report),
                      ),
                      _reportTab(
                        context,
                        TrendsTab(report: _report),
                      ),
                      _reportTab(
                        context,
                        RegionalTab(
                          report: _report,
                          onChooseRegion: _chooseFilters,
                        ),
                        regional: true,
                      ),
                      const SurveyTab(),
                    ],
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

class OverviewTab extends StatelessWidget {
  final SentimentPulseReport? report;
  const OverviewTab({super.key, this.report});
  @override
  Widget build(BuildContext context) => report == null
      ? Center(child: Text(context.tr('Reporting data is not connected yet.')))
      : ReportingOverview(report: report!);
}

class TrendsTab extends StatelessWidget {
  final SentimentPulseReport? report;
  const TrendsTab({super.key, this.report});
  @override
  Widget build(BuildContext context) => report == null
      ? Center(child: Text(context.tr('Reporting data is not connected yet.')))
      : ReportingTrends(report: report!);
}

class RegionalTab extends StatelessWidget {
  final SentimentPulseReport? report;
  final VoidCallback? onChooseRegion;
  const RegionalTab({super.key, this.report, this.onChooseRegion});
  @override
  Widget build(BuildContext context) => report == null
      ? Center(child: Text(context.tr('Reporting data is not connected yet.')))
      : ReportingRegional(report: report!, onChooseRegion: onChooseRegion);
}

class SurveyTab extends StatefulWidget {
  const SurveyTab({super.key});

  @override
  State<SurveyTab> createState() => _SurveyTabState();
}

class _SurveyTabState extends State<SurveyTab> {
  late Future<List<MobileSurvey>> surveyFuture;

  final surveyService = SentimentSurveyService(
    baseUrl: ApiConfig.sentimentBaseUrl,
  );

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
        accessToken: profile?.accessToken,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 18, 8),
            child: Row(
              children: [
                IconButton(
                  tooltip: context.tr('Back'),
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(context).maybePop(),
                  color: AppTheme.primary,
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.survey.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                18,
                0,
                18,
                MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
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
          ),
        ],
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
