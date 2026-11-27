import '../localization/app_translations.dart';
import 'package:flutter/material.dart';
import '../models/self_report_history_models.dart';
import '../data/app_taxonomy.dart';
import '../services/api_config.dart';
import '../services/app_settings_store.dart';
import '../services/healthph_api_services.dart';
import '../services/profile_store.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../widgets/animated_state_view.dart';
import '../widgets/self_report_history/contribution_summary.dart';
import '../widgets/self_report_history/contribution_card.dart';
import '../widgets/self_report_history/history_state_cards.dart';

class SelfReportHistoryPage extends StatefulWidget {
  final HealthPhApiService? service;
  final bool embedded;

  const SelfReportHistoryPage({super.key, this.service, this.embedded = false});

  @override
  State<SelfReportHistoryPage> createState() => _SelfReportHistoryPageState();
}

class _SelfReportHistoryPageState extends State<SelfReportHistoryPage> {
  late Future<ContributionLoadResult> reportsFuture;

  @override
  void initState() {
    super.initState();
    reportsFuture = _loadReports();
  }

  Future<ContributionLoadResult> _loadReports() async {
    final profile = ProfileStore.instance.profile;
    final isGuest =
        profile == null ||
        AppTaxonomy.isGuestRole(profile.roleId) ||
        profile.email == AppTaxonomy.guestEmail;

    if (isGuest) {
      return const ContributionLoadResult(
        reports: [],
        isLocalFallback: false,
        warning:
            "Login with a registered account to view your account self-reports.",
        authenticationRequired: true,
      );
    }

    try {
      final rows =
          await (widget.service ??
                  HealthPhApiService(baseUrl: ApiConfig.baseUrl))
              .fetchMySelfReports(accessToken: profile.accessToken);
      return ContributionLoadResult(
        reports: rows.map(ContributionReport.fromJson).toList(),
      );
    } on SelfReportAuthenticationException catch (error) {
      return ContributionLoadResult(
        reports: [],
        warning: error.message,
        authenticationRequired: true,
      );
    } catch (_) {
      return const ContributionLoadResult(
        reports: [],
        error: 'Unable to load self-reports. Check your backend connection.',
      );
    }
  }

  Future<void> _refresh() async {
    setState(() {
      reportsFuture = _loadReports();
    });

    await reportsFuture;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final visualMode = AppSettingsStore.instance.visualMode;

    final animationViewportHeight = widget.embedded
        ? (MediaQuery.sizeOf(context).height *
                  (Responsive.isLandscapePhone(context) ? 0.55 : 0.52))
              .clamp(260.0, 520.0)
              .toDouble()
        : 420.0;

    final historyContent = RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<ContributionLoadResult>(
        future: reportsFuture,
        builder: (context, snapshot) {
          final result = snapshot.data;
          final reports = result?.reports ?? [];

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              widget.embedded ? 0 : Responsive.pagePadding(context),
              widget.embedded ? 0 : 16,
              widget.embedded ? 0 : Responsive.pagePadding(context),
              widget.embedded ? 88 : 28,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 680 : Responsive.formMaxWidth(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!widget.embedded) ...[
                      _HistoryHeader(
                        isTablet: isTablet,
                        titleColor: visualMode.onBackground,
                        subtitleColor: visualMode.onBackgroundMuted,
                      ),
                      const SizedBox(height: 18),
                    ],
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const HistoryLoadingCard()
                    else if (snapshot.hasError || result?.error != null)
                      HistoryErrorCard(
                        message:
                            result?.error ??
                            'Unable to load self-reports. '
                                'Check your backend connection.',
                        onRetry: _refresh,
                      )
                    else if (result?.authenticationRequired == true)
                      SizedBox(
                        height: animationViewportHeight,
                        child: AnimatedStateView(
                          animation: StateAnimationKind.login,
                          title: context.tr(result!.warning!),
                          actionLabel: context.tr('Login'),
                          onAction: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                          },
                        ),
                      )
                    else ...[
                      if (result?.warning != null) ...[
                        HistoryNoticeCard(message: result!.warning!),
                        const SizedBox(height: 12),
                      ],
                      ContributionSummary(
                        reports: reports,
                        isLocalFallback: result?.isLocalFallback ?? false,
                      ),
                      const SizedBox(height: 14),
                      if (reports.isEmpty)
                        const EmptyContributionCard()
                      else
                        ...reports.map(
                          (report) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ContributionCard(report: report),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    if (widget.embedded) {
      return historyContent;
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: SafeArea(child: historyContent),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  final bool isTablet;
  final Color titleColor;
  final Color subtitleColor;

  const _HistoryHeader({
    required this.isTablet,
    required this.titleColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton.filled(
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primary,
          ),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(height: 20),
        Text(
          context.tr("My Self-Reports"),
          style: TextStyle(
            color: titleColor,
            fontSize: isTablet ? 34 : 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          context.tr(
            "Review the symptoms and possible conditions you contributed.",
          ),
          style: TextStyle(
            color: subtitleColor,
            fontSize: isTablet ? 17 : 14,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
