import 'package:flutter/material.dart';

import '../data/app_taxonomy.dart';
import '../services/api_config.dart';
import '../services/app_settings_store.dart';
import '../services/healthph_api_services.dart';
import '../services/profile_store.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../widgets/app_skeleton.dart';

class SelfReportHistoryPage extends StatefulWidget {
  const SelfReportHistoryPage({super.key});

  @override
  State<SelfReportHistoryPage> createState() => _SelfReportHistoryPageState();
}

class _SelfReportHistoryPageState extends State<SelfReportHistoryPage> {
  late Future<_ContributionLoadResult> reportsFuture;

  @override
  void initState() {
    super.initState();
    reportsFuture = _loadReports();
  }

  Future<_ContributionLoadResult> _loadReports() async {
    final profile = ProfileStore.instance.profile;
    final userId = profile?.id?.trim() ?? "";
    final isGuest =
        profile == null ||
        AppTaxonomy.isGuestRole(profile.roleId) ||
        profile.email == AppTaxonomy.guestEmail;

    if (isGuest || userId.isEmpty) {
      return const _ContributionLoadResult(
        reports: [],
        isLocalFallback: false,
        warning:
            "Login with a registered account to view your account self-reports.",
      );
    }

    final rows = await HealthPhApiService(
      baseUrl: ApiConfig.baseUrl,
    ).fetchMySelfReports(userId: userId);

    return _ContributionLoadResult(
      reports: rows.map(_ContributionReport.fromJson).toList(),
      isLocalFallback: false,
    );
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

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<_ContributionLoadResult>(
            future: reportsFuture,
            builder: (context, snapshot) {
              final result = snapshot.data;
              final reports = result?.reports ?? [];

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  Responsive.pagePadding(context),
                  16,
                  Responsive.pagePadding(context),
                  28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet
                          ? 680
                          : Responsive.formMaxWidth(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HistoryHeader(
                          isTablet: isTablet,
                          titleColor: visualMode.onBackground,
                          subtitleColor: visualMode.onBackgroundMuted,
                        ),
                        const SizedBox(height: 18),
                        if (snapshot.connectionState == ConnectionState.waiting)
                          const _LoadingCard()
                        else if (snapshot.hasError)
                          _ErrorCard(
                            message:
                                "Unable to load self-reports. Check your backend connection.",
                            onRetry: _refresh,
                          )
                        else ...[
                          if (result?.warning != null) ...[
                            _NoticeCard(message: result!.warning!),
                            const SizedBox(height: 12),
                          ],
                          _ContributionSummary(
                            reports: reports,
                            isLocalFallback: result?.isLocalFallback ?? false,
                          ),
                          const SizedBox(height: 14),
                          if (reports.isEmpty)
                            const _EmptyContributionCard()
                          else
                            ...reports.map(
                              (report) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ContributionCard(report: report),
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
        ),
      ),
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
          "My Self-Reports",
          style: TextStyle(
            color: titleColor,
            fontSize: isTablet ? 34 : 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Review the symptoms and possible conditions you contributed.",
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

class _ContributionSummary extends StatelessWidget {
  final List<_ContributionReport> reports;
  final bool isLocalFallback;

  const _ContributionSummary({
    required this.reports,
    required this.isLocalFallback,
  });

  @override
  Widget build(BuildContext context) {
    final latest = reports.isEmpty ? "No reports yet" : reports.first.dateLabel;
    final topCondition = _topConditionLabel(reports);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    icon: Icons.assignment_turned_in_outlined,
                    value: reports.length.toString(),
                    label: isLocalFallback ? "Local reports" : "Mongo reports",
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryMetric(
                    icon: Icons.monitor_heart_outlined,
                    value: topCondition,
                    label: "Most common concern",
                    color: AppTheme.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SummaryMetric(
              icon: Icons.schedule_outlined,
              value: latest,
              label: "Latest contribution",
              color: AppTheme.info,
            ),
          ],
        ),
      ),
    );
  }

  String _topConditionLabel(List<_ContributionReport> reports) {
    if (reports.isEmpty) return "None";

    final counts = <String, int>{};
    for (final report in reports) {
      counts.update(report.condition, (value) => value + 1, ifAbsent: () => 1);
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.first.key;
  }
}

class _SummaryMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SummaryMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 86),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContributionCard extends StatelessWidget {
  final _ContributionReport report;

  const _ContributionCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showDetails(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.sick_outlined,
                      color: AppTheme.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.condition,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.text,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          report.dateLabel,
                          style: const TextStyle(
                            color: AppTheme.mutedText,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppTheme.mutedText),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                report.location,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: report.symptoms
                    .map((symptom) => _SymptomChip(label: symptom))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.condition,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                _DetailRow(label: "Report ID", value: report.id),
                _DetailRow(label: "Status", value: report.status),
                _DetailRow(label: "Language", value: report.language),
                _DetailRow(label: "Location", value: report.location),
                _DetailRow(label: "Date", value: report.dateLabel),
                if (report.notes.isNotEmpty)
                  _DetailRow(label: "Notes", value: report.notes),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SymptomChip extends StatelessWidget {
  final String label;

  const _SymptomChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.info.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.info.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final String message;

  const _NoticeCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.35)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppTheme.text,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppSkeleton(height: 92, width: double.infinity),
        const SizedBox(height: 14),
        ...List.generate(
          3,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton(height: 18, width: 190),
                SizedBox(height: 10),
                AppSkeleton(height: 13, width: double.infinity),
                SizedBox(height: 7),
                AppSkeleton(height: 13, width: 230),
                SizedBox(height: 12),
                Divider(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.highRisk.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: AppTheme.highRisk,
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text("Try again"),
          ),
        ],
      ),
    );
  }
}

class _EmptyContributionCard extends StatelessWidget {
  const _EmptyContributionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.assignment_late_outlined,
            color: AppTheme.mutedText,
            size: 38,
          ),
          SizedBox(height: 10),
          Text(
            "No self-reports yet",
            style: TextStyle(
              color: AppTheme.text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Submitted self-reports will appear here for review.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.mutedText, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _ContributionLoadResult {
  final List<_ContributionReport> reports;
  final bool isLocalFallback;
  final String? warning;

  const _ContributionLoadResult({
    required this.reports,
    this.isLocalFallback = false,
    this.warning,
  });
}

class _ContributionReport {
  final String id;
  final String status;
  final String condition;
  final String location;
  final String language;
  final String notes;
  final DateTime? createdAt;
  final List<String> symptoms;

  const _ContributionReport({
    required this.id,
    required this.status,
    required this.condition,
    required this.location,
    required this.language,
    required this.notes,
    required this.createdAt,
    required this.symptoms,
  });

  factory _ContributionReport.fromJson(Map<String, dynamic> json) {
    final location = _asMap(json["location"]);
    final createdAt = DateTime.tryParse(_text(json["createdAt"]));

    return _ContributionReport(
      id: _text(json["id"], fallback: "Mongo report"),
      status: _text(json["status"], fallback: "submitted"),
      condition: _text(
        json["possibleConditionLabel"],
        fallback: "Respiratory symptoms",
      ),
      location: _joinLocation([
        location["barangayName"],
        location["cityName"],
        location["provinceName"],
      ]),
      language: _text(json["language"], fallback: "English"),
      notes: _text(json["notes"]),
      createdAt: createdAt,
      symptoms: _stringList(json["symptomLabels"]),
    );
  }

  String get dateLabel {
    final date = createdAt?.toLocal();
    if (date == null) return "Date unavailable";

    final hour = date.hour.toString().padLeft(2, "0");
    final minute = date.minute.toString().padLeft(2, "0");

    return "${date.month}/${date.day}/${date.year} at $hour:$minute";
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  static List<String> _stringList(Object? value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    final text = _text(value);
    return text.isEmpty ? [] : [text];
  }

  static String _text(Object? value, {String fallback = ""}) {
    final text = value?.toString().trim() ?? "";
    return text.isEmpty ? fallback : text;
  }

  static String _joinLocation(List<Object?> parts) {
    final location = parts
        .map((part) => _text(part))
        .where((part) => part.isNotEmpty)
        .join(", ");

    return location.isEmpty ? "Location unavailable" : location;
  }
}
