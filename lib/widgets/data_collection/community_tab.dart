import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../models/surveillance_pin.dart';
import '../../services/api_config.dart';
import '../../services/healthph_api_services.dart';
import '../../theme/app_theme.dart';
import '../animated_state_view.dart';

class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  late Future<List<SurveillancePin>> pinsFuture;

  static const diseaseLabels = <String, String>{
    'TB': 'Tuberculosis',
    'PN': 'Pneumonia',
    'COVID': 'COVID-19',
    'AURI': 'Acute Upper Respiratory Infection',
  };

  @override
  void initState() {
    super.initState();
    pinsFuture = _loadCommunityData();
  }

  Future<List<SurveillancePin>> _loadCommunityData() {
    return HealthPhApiService(
      baseUrl: ApiConfig.baseUrl,
    ).fetchSurveillanceMapPins(days: 30);
  }

  void _retry() {
    setState(() {
      pinsFuture = _loadCommunityData();
    });
  }

  String _regionLabel(String code) {
    if (code == 'NCR') return 'National Capital Region';
    return code.startsWith('Region ') ? code : 'Region $code';
  }

  Widget _metricRow({
    required String label,
    required int value,
    required int total,
    required Color color,
  }) {
    final percentage = total == 0 ? 0 : ((value / total) * 100).round();
    final progress = total == 0
        ? 0.0
        : (value / total).clamp(0.0, 1.0).toDouble();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr(label),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '$value ($percentage%)',
                style: const TextStyle(
                  color: AppTheme.mutedText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SurveillancePin>>(
      future: pinsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return AnimatedStateView(
            animation: StateAnimationKind.empty,
            title: context.tr('Unable to load community trends.'),
            actionLabel: context.tr('Retry'),
            onAction: _retry,
          );
        }

        final pins = snapshot.data ?? const <SurveillancePin>[];

        if (pins.isEmpty) {
          return AnimatedStateView(
            animation: StateAnimationKind.empty,
            title: context.tr(
              'No processed community signals are available for the last 30 days.',
            ),
          );
        }

        final diseaseCounts = <String, int>{
          for (final code in SurveillancePin.diseases) code: 0,
        };
        final regionCounts = <String, int>{};

        for (final pin in pins) {
          for (final entry in pin.diseaseCounts.entries) {
            diseaseCounts.update(
              entry.key,
              (current) => current + entry.value,
              ifAbsent: () => entry.value,
            );
          }

          final region = pin.region?.trim() ?? '';
          if (region.isNotEmpty) {
            regionCounts.update(
              region,
              (current) => current + pin.processedEntryCount,
              ifAbsent: () => pin.processedEntryCount,
            );
          }
        }

        final diseaseRows =
            diseaseCounts.entries.where((entry) => entry.value > 0).toList()
              ..sort((a, b) => b.value.compareTo(a.value));

        final regionRows = regionCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        final diseaseTotal = diseaseRows.fold<int>(
          0,
          (total, entry) => total + entry.value,
        );
        final regionTotal = regionRows.fold<int>(
          0,
          (total, entry) => total + entry.value,
        );

        return RefreshIndicator(
          onRefresh: () async {
            final refreshed = _loadCommunityData();
            setState(() => pinsFuture = refreshed);
            await refreshed;
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              Text(
                context.tr('Community Trends'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                context.tr(
                  'Anonymous processed health signals from the community.',
                ),
                style: const TextStyle(color: AppTheme.mutedText),
              ),
              const SizedBox(height: 22),
              Text(
                context.tr('Top Disease Signals'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              ...diseaseRows
                  .take(4)
                  .map(
                    (entry) => _metricRow(
                      label: diseaseLabels[entry.key] ?? entry.key,
                      value: entry.value,
                      total: diseaseTotal,
                      color: AppTheme.primary,
                    ),
                  ),
              const SizedBox(height: 12),
              Text(
                context.tr('Processed Reports by Region'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              ...regionRows
                  .take(5)
                  .map(
                    (entry) => _metricRow(
                      label: _regionLabel(entry.key),
                      value: entry.value,
                      total: regionTotal,
                      color: AppTheme.success,
                    ),
                  ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.privacy_tip_outlined,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.tr(
                          'Community data is anonymized and aggregated to protect privacy. Disease signals are not confirmed diagnoses.',
                        ),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
