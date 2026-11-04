import 'package:flutter/material.dart';
import '../localization/app_translations.dart';
import '../models/sentiment_report_filters.dart';

class SentimentReportFilterSheet extends StatefulWidget {
  final SentimentReportFilters initial;
  const SentimentReportFilterSheet({super.key, required this.initial});
  @override
  State<SentimentReportFilterSheet> createState() => _FilterState();
}

class _FilterState extends State<SentimentReportFilterSheet> {
  late String range = widget.initial.timeRange;
  late String? region = widget.initial.region;
  late String? start = widget.initial.startDate;
  late String? end = widget.initial.endDate;

  Future<void> pickDates() async {
    final manila = DateTime.now().toUtc().add(const Duration(hours: 8));
    final today = DateTime(manila.year, manila.month, manila.day);
    final selection = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: today,
      currentDate: today,
      initialDateRange: start == null || end == null
          ? null
          : DateTimeRange(
              start: DateTime.parse(start!),
              end: DateTime.parse(end!),
            ),
    );
    if (!mounted || selection == null) return;
    setState(() {
      start = selection.start.toIso8601String().substring(0, 10);
      end = selection.end.toIso8601String().substring(0, 10);
    });
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.tr('Reporting filters'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: range,
            isExpanded: true,
            decoration: InputDecoration(labelText: context.tr('Time range')),
            items: SentimentReportFilters.ranges.entries
                .map(
                  (entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text(context.tr(entry.value)),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => range = value!),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: region ?? 'all',
            isExpanded: true,
            decoration: InputDecoration(labelText: context.tr('Region')),
            items: [
              DropdownMenuItem(
                value: 'all',
                child: Text(context.tr('All regions')),
              ),
              for (final code in SentimentReportFilters.regions)
                DropdownMenuItem(value: code, child: Text(code)),
            ],
            onChanged: (value) =>
                setState(() => region = value == 'all' ? null : value),
          ),
          if (range == 'custom')
            TextButton.icon(
              onPressed: pickDates,
              icon: const Icon(Icons.date_range),
              label: Text(
                start == null ? context.tr('Choose dates') : '$start - $end',
              ),
            ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: range == 'custom' && (start == null || end == null)
                ? null
                : () {
                    final filters = SentimentReportFilters(
                      timeRange: range,
                      region: region,
                      startDate: range == 'custom' ? start : null,
                      endDate: range == 'custom' ? end : null,
                    );
                    filters.toQuery();
                    Navigator.pop(context, filters);
                  },
            child: Text(context.tr('Apply')),
          ),
        ],
      ),
    ),
  );
}
