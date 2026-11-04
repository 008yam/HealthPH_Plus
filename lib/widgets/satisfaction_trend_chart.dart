import 'package:flutter/material.dart';
import '../localization/app_translations.dart';
import '../models/sentiment_pulse_report.dart';
import '../models/sentiment_report_filters.dart';

/// Split at null readings AND omitted calendar days; never interpolate a gap.
List<List<SatisfactionTrendPoint>> satisfactionSegments(
  List<SatisfactionTrendPoint> points,
) {
  final sorted = [...points]..sort((a, b) => a.date.compareTo(b.date));
  final segments = <List<SatisfactionTrendPoint>>[];
  DateTime? previous;
  for (final point in sorted) {
    final day = reportDate(point.date);
    if (point.satisfactionShare == null) {
      previous = null;
      continue;
    }
    if (previous == null || day.difference(previous).inDays != 1) {
      segments.add([]);
    }
    segments.last.add(point);
    previous = day;
  }
  return segments;
}

class SatisfactionTrendChart extends StatelessWidget {
  final List<SatisfactionTrendPoint> points;
  const SatisfactionTrendChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final segments = satisfactionSegments(points);
    if (segments.isEmpty) return Text(context.tr('No daily observations'));
    final dates = points.map((p) => p.date).toList()..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: SizedBox(
            height: 180,
            child: Row(
              children: [
                const Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('100%'), Text('50%'), Text('0%')],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomPaint(
                    painter: SatisfactionTrendPainter(
                      segments,
                      dates.first,
                      dates.last,
                      Theme.of(context).colorScheme.outlineVariant,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 16,
          children: [
            Text(dates.first),
            if (dates.last != dates.first) Text(dates.last),
          ],
        ),
      ],
    );
  }
}

class SatisfactionTrendPainter extends CustomPainter {
  final List<List<SatisfactionTrendPoint>> segments;
  final String start, end;
  final Color gridColor;
  SatisfactionTrendPainter(this.segments, this.start, this.end, this.gridColor);

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    final line = Paint()
      ..color = const Color(0xFF15803D)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final dot = Paint()..color = const Color(0xFF15803D);
    final first = reportDate(start);
    final days = reportDate(end).difference(first).inDays;
    for (final share in [0.0, 0.5, 1.0]) {
      final y = 4 + (size.height - 8) * share;
      canvas.drawLine(Offset(4, y), Offset(size.width - 4, y), grid);
    }
    for (final segment in segments) {
      final path = Path();
      for (var i = 0; i < segment.length; i++) {
        final point = segment[i];
        final x = days == 0
            ? size.width / 2
            : 4 +
                  (size.width - 8) *
                      reportDate(point.date).difference(first).inDays /
                      days;
        final y = 4 + (size.height - 8) * (1 - point.satisfactionShare! / 100);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
        canvas.drawCircle(Offset(x, y), 3, dot);
      }
      canvas.drawPath(path, line);
    }
  }

  @override
  bool shouldRepaint(covariant SatisfactionTrendPainter oldDelegate) => true;
}
