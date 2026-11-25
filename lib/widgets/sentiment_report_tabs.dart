import 'package:flutter/material.dart';

import '../localization/app_translations.dart';
import '../models/sentiment_pulse_report.dart';
import 'sentiment_report_sections.dart';

class OverviewTab extends StatelessWidget {
  final SentimentPulseReport? report;

  const OverviewTab({super.key, this.report});

  @override
  Widget build(BuildContext context) {
    if (report == null) {
      return Center(
        child: Text(context.tr('Reporting data is not connected yet.')),
      );
    }

    return ReportingOverview(report: report!);
  }
}

class TrendsTab extends StatelessWidget {
  final SentimentPulseReport? report;

  const TrendsTab({super.key, this.report});

  @override
  Widget build(BuildContext context) {
    if (report == null) {
      return Center(
        child: Text(context.tr('Reporting data is not connected yet.')),
      );
    }

    return ReportingTrends(report: report!);
  }
}

class RegionalTab extends StatelessWidget {
  final SentimentPulseReport? report;
  final VoidCallback? onChooseRegion;

  const RegionalTab({super.key, this.report, this.onChooseRegion});

  @override
  Widget build(BuildContext context) {
    if (report == null) {
      return Center(
        child: Text(context.tr('Reporting data is not connected yet.')),
      );
    }

    return ReportingRegional(report: report!, onChooseRegion: onChooseRegion);
  }
}
