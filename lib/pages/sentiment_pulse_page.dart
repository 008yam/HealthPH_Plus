import 'package:healthphplus/main_page.dart';
import 'package:flutter/material.dart';
import '../localization/app_translations.dart';
import '../login_page.dart';
import '../models/sentiment_pulse_report.dart';
import '../models/sentiment_report_filters.dart';
import '../services/api_config.dart';
import '../services/sentiment_reporting_service.dart';
import '../services/sentiment_reporting_controller.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../widgets/sentiment_report_filter_sheet.dart';
import '../widgets/animated_state_view.dart';
import '../widgets/sentiment_report_tabs.dart';
import '../widgets/sentiment_survey/survey_tab.dart';

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

    if (!_external && _controller?.authenticationRequired == true) {
      return AnimatedStateView(
        animation: StateAnimationKind.login,
        title: context.tr('Sign in to view reporting data.'),
        actionLabel: context.tr('Login'),
        onAction: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const LoginPage()));
        },
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
              if (_retry != null) ...[
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
                        SizedBox(height: Responsive.verticalGap(context, 8)),
                        Image.asset(
                          'assets/images/healthphplusbarlogo.png',
                          height: Responsive.logoHeight(context),
                        ),
                        SizedBox(height: Responsive.verticalGap(context, 8)),
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
                      _reportTab(context, OverviewTab(report: _report)),
                      _reportTab(context, TrendsTab(report: _report)),
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
