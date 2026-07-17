import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'self_report_store.dart';

class SelfReportExportService {
  SelfReportExportService._();

  static final SelfReportExportService instance = SelfReportExportService._();

  Future<bool> shareCsv({
    required BuildContext context,
    required List<SelfReport> reports,
  }) async {
    final csv = buildCsv(reports);
    final fileName = 'healthph_self_reports_${_dateStamp(DateTime.now())}.csv';
    final box = context.findRenderObject() as RenderBox?;

    final result = await SharePlus.instance.share(
      ShareParams(
        title: 'HealthPH+ self-reports export',
        subject: fileName,
        text: 'Exported HealthPH+ self-report records.',
        files: [XFile.fromData(utf8.encode(csv), mimeType: 'text/csv')],
        fileNameOverrides: [fileName],
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );

    return result.status != ShareResultStatus.dismissed;
  }

  String buildCsv(List<SelfReport> reports) {
    final rows = <List<Object?>>[
      [
        'created_at',
        'region_code',
        'province',
        'city',
        'barangay',
        'symptoms',
        'possible_condition',
        'notes',
        'latitude',
        'longitude',
        'geocoded_address',
        'pin_accuracy',
      ],
      ...reports.map((report) {
        return [
          report.createdAt.toIso8601String(),
          report.region,
          report.province,
          report.city,
          report.barangay,
          report.symptoms.join('|'),
          report.possibleCondition,
          report.notes,
          report.latitude,
          report.longitude,
          report.geocodedAddress,
          report.hasCoordinates ? 'geocoded' : 'region_estimate',
        ];
      }),
    ];

    return rows.map(_csvRow).join('\n');
  }

  String _csvRow(List<Object?> values) {
    return values.map(_csvCell).join(',');
  }

  String _csvCell(Object? value) {
    final text = value?.toString() ?? '';
    final escaped = text.replaceAll('"', '""');
    return '"$escaped"';
  }

  String _dateStamp(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$year$month${day}_$hour$minute';
  }
}
