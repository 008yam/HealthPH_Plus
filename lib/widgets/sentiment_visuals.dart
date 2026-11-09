import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../localization/app_translations.dart';
import '../models/sentiment_pulse_report.dart';

const calmColor = Color(0xFF2874E8);
const worriedColor = Color(0xFFDC6803);
const reportingInk = Color(0xFF172033);
const reportingMuted = Color(0xFF637187);

class SentimentTiles extends StatelessWidget {
  final List<SentimentDistributionItem> items;
  const SentimentTiles({super.key, required this.items});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final twoColumns =
          box.maxWidth >= 280 &&
          MediaQuery.textScalerOf(context).scale(14) <= 20;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: items.map((item) {
          final calm = item.category == 'calm';
          final color = calm ? calmColor : worriedColor;
          return Container(
            width: twoColumns ? (box.maxWidth - 12) / 2 : box.maxWidth,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.22)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      calm
                          ? Icons.sentiment_satisfied_alt
                          : Icons.sentiment_dissatisfied,
                      color: color,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.tr(calm ? 'Calm' : 'Worried'),
                        style: const TextStyle(
                          color: reportingInk,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.share == null
                      ? context.tr('Unavailable')
                      : '${item.share!.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: item.share == null ? 16 : 26,
                    fontWeight: FontWeight.w700,
                    color: reportingInk,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(
                    '{count} answers',
                    parameters: {'count': item.answers},
                  ),
                  style: const TextStyle(fontSize: 12, color: reportingMuted),
                ),
              ],
            ),
          );
        }).toList(),
      );
    },
  );
}

class SentimentRing extends StatelessWidget {
  final List<SentimentDistributionItem> items;
  const SentimentRing({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final available =
        items.isNotEmpty &&
        items.every((e) => e.share != null) &&
        items.fold<double>(0, (sum, e) => sum + (e.share ?? 0)) > 0;
    if (!available) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Semantics(
            label: items
                .map(
                  (e) =>
                      '${context.tr(e.category == 'calm' ? 'Calm' : 'Worried')}: ${e.share!.toStringAsFixed(1)}%',
                )
                .join(', '),
            image: true,
            child: SizedBox.square(
              dimension: 216,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _RingPainter(items)),
                  ),
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: 120,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${items.fold<int>(0, (sum, e) => sum + e.answers)}',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: reportingInk,
                              ),
                            ),
                            Text(
                              context.tr('Overall Sentiment'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: reportingMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const SentimentLegend(),
        ],
      ),
    );
  }
}

/// Current and previous calendar periods, not synthetic weekly measurements.
class SentimentComparisonColumns extends StatelessWidget {
  final List<SentimentDistributionItem> previous, current;
  const SentimentComparisonColumns({
    super.key,
    required this.previous,
    required this.current,
  });

  Widget _column(BuildContext context, List<SentimentDistributionItem> items) {
    final available =
        items.isNotEmpty &&
        items.every((e) => e.share != null) &&
        items.any((e) => (e.share ?? 0) > 0);
    if (!available) {
      return Center(
        child: Text(
          context.tr('Unavailable'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: reportingMuted),
        ),
      );
    }
    final label = items
        .map(
          (e) =>
              '${context.tr(e.category == 'calm' ? 'Calm' : 'Worried')}: ${e.share!.toStringAsFixed(1)}%',
        )
        .join('\n');
    return Tooltip(
      message: label,
      triggerMode: TooltipTriggerMode.tap,
      child: Semantics(
        label: label,
        image: true,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          child: Column(
            children: [
              for (final item in items.reversed)
                if (item.share! > 0)
                  Expanded(
                    flex: (item.share! * 1000).round().clamp(1, 100000),
                    child: Container(
                      width: double.infinity,
                      color: item.category == 'calm' ? calmColor : worriedColor,
                      alignment: Alignment.center,
                      child:
                          item.share! >= 15 &&
                              MediaQuery.textScalerOf(context).scale(12) < 20
                          ? Text(
                              '${item.share!.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : null,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        height: 190,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: math.max(
                34,
                MediaQuery.textScalerOf(context).scale(10) * 4 + 4,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final value in ['100%', '75', '50', '25', '0'])
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 10,
                        color: reportingMuted,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        5,
                        (_) =>
                            const Divider(height: 1, color: Color(0xFFE0E6EF)),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (final items in [previous, current])
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 90),
                                child: _column(context, items),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      Padding(
        padding: EdgeInsets.only(
          left: math.max(
            34,
            MediaQuery.textScalerOf(context).scale(10) * 4 + 4,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final label in ['Previous period', 'Current period'])
              Expanded(
                child: Text(
                  context.tr(label),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: reportingMuted),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      const SentimentLegend(),
    ],
  );
}

class RegionalSentimentSplit extends StatelessWidget {
  final List<SentimentDistributionItem> items;
  final String? dominantCategory;
  const RegionalSentimentSplit({
    super.key,
    required this.items,
    required this.dominantCategory,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (dominantCategory == 'calm' || dominantCategory == 'worried')
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (dominantCategory == 'calm' ? calmColor : worriedColor)
                  .withValues(alpha: .1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              context.tr(dominantCategory == 'calm' ? 'Calm' : 'Worried'),
              style: TextStyle(
                color: dominantCategory == 'calm' ? calmColor : worriedColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      const SizedBox(height: 12),
      if (items.isNotEmpty &&
          items.every((e) => e.share != null) &&
          items.any((e) => e.share! > 0))
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: SizedBox(
            height: 20,
            child: Row(
              children: [
                for (final item in items)
                  if (item.share! > 0)
                    Expanded(
                      flex: (item.share! * 1000).round().clamp(1, 100000),
                      child: ColoredBox(
                        color: item.category == 'calm'
                            ? calmColor
                            : worriedColor,
                        child: const SizedBox.expand(),
                      ),
                    ),
              ],
            ),
          ),
        ),
      const SizedBox(height: 12),
      SentimentTiles(items: items),
    ],
  );
}

class SatisfactionDonut extends StatelessWidget {
  final List<SatisfactionDistributionItem> items;
  final double? share;
  const SatisfactionDonut({
    super.key,
    required this.items,
    required this.share,
  });
  static const colors = {
    'satisfied': Color(0xFF20855A),
    'neutral': Color(0xFF8593A6),
    'dissatisfied': Color(0xFFE14E59),
  };
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty ||
        items.any((e) => e.share == null) ||
        items.every((e) => e.share == 0)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Semantics(
          image: true,
          label: items
              .map(
                (e) =>
                    '${context.tr(_name(e.category))}: ${e.share!.toStringAsFixed(1)}%',
              )
              .join(', '),
          child: SizedBox.square(
            dimension: 188,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _SatisfactionPainter(items)),
                ),
                SizedBox(
                  width: 110,
                  height: 100,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: 110,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            share == null
                                ? context.tr('Unavailable')
                                : '${share!.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: reportingInk,
                            ),
                          ),
                          Text(
                            context.tr('Satisfied'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: reportingMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _name(String category) =>
      const {
        'satisfied': 'Satisfied',
        'neutral': 'Neutral',
        'dissatisfied': 'Dissatisfied',
      }[category] ??
      category;
}

class _SatisfactionPainter extends CustomPainter {
  final List<SatisfactionDistributionItem> items;
  _SatisfactionPainter(this.items);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22;
    final rect = (Offset.zero & size).deflate(14);
    canvas.drawOval(rect, paint..color = const Color(0xFFE6EBF2));
    var start = -math.pi / 2;
    for (final item in items) {
      final sweep = item.share! / 100 * math.pi * 2;
      if (sweep > 0) {
        canvas.drawArc(
          rect,
          start + .012,
          math.max(0, sweep - .024),
          false,
          paint..color = SatisfactionDonut.colors[item.category] ?? Colors.grey,
        );
      }
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _SatisfactionPainter oldDelegate) =>
      oldDelegate.items != items;
}

class SentimentLegend extends StatelessWidget {
  const SentimentLegend({super.key});
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 18,
    runSpacing: 8,
    children: [
      for (final entry in {'Calm': calmColor, 'Worried': worriedColor}.entries)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: entry.value,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              context.tr(entry.key),
              style: const TextStyle(fontSize: 12, color: reportingMuted),
            ),
          ],
        ),
    ],
  );
}

class _RingPainter extends CustomPainter {
  final List<SentimentDistributionItem> items;
  _RingPainter(this.items);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(15);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24;
    canvas.drawOval(rect, paint..color = const Color(0xFFE6EBF2));
    var start = -math.pi / 2;
    for (final item in items) {
      final sweep = (item.share ?? 0) / 100 * math.pi * 2;
      if (sweep > 0) {
        canvas.drawArc(
          rect,
          start + 0.012,
          math.max(0, sweep - 0.024),
          false,
          paint..color = item.category == 'calm' ? calmColor : worriedColor,
        );
      }
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.items != items;
}

class SentimentPeriodBars extends StatelessWidget {
  final List<SentimentDistributionItem> previous, current;
  const SentimentPeriodBars({
    super.key,
    required this.previous,
    required this.current,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final entry in {
        'Previous period': previous,
        'Current period': current,
      }.entries)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr(entry.key),
                style: const TextStyle(fontSize: 12, color: reportingMuted),
              ),
              const SizedBox(height: 6),
              if (entry.value.isEmpty ||
                  entry.value.any((e) => e.share == null) ||
                  entry.value.every((e) => e.share == 0))
                Text(context.tr('No comparable results'))
              else
                Semantics(
                  label: entry.value
                      .map(
                        (e) =>
                            '${context.tr(e.category == 'calm' ? 'Calm' : 'Worried')}: ${e.share!.toStringAsFixed(1)}%',
                      )
                      .join(', '),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 24,
                      child: Row(
                        children: [
                          for (final item in entry.value)
                            if (item.share! > 0)
                              Expanded(
                                flex: (item.share! * 10000).round().clamp(
                                  1,
                                  1000000,
                                ),
                                child: ColoredBox(
                                  color: item.category == 'calm'
                                      ? calmColor
                                      : worriedColor,
                                  child: const SizedBox.expand(),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      const SizedBox(height: 6),
      const SentimentLegend(),
    ],
  );
}
