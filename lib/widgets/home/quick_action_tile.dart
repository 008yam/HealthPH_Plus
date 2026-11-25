import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

import '../../localization/app_translations.dart';
import '../../theme/app_theme.dart';
import '../../theme/responsive.dart';

class QuickActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const QuickActionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final titleSize = isTablet ? 17.0 : 15.0;
    final subtitleSize = isTablet ? 16.0 : 14.0;
    final scaler = MediaQuery.textScalerOf(context);

    final titleHeight = scaler.scale(titleSize) * 1.3;
    final subtitleHeight = scaler.scale(subtitleSize) * 1.3;
    final iconExtent = titleHeight + 3 + subtitleHeight;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 14,
            vertical: isTablet ? 16 : 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: iconExtent,
                height: iconExtent,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: iconExtent * 0.60, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: titleHeight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          context.tr(title),
                          maxLines: 1,
                          softWrap: false,
                          style: TextStyle(
                            color: AppTheme.text,
                            fontWeight: FontWeight.bold,
                            fontSize: titleSize,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    SizedBox(
                      height: subtitleHeight,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final text = context.tr(subtitle);
                          final direction = Directionality.of(context);

                          final style = DefaultTextStyle.of(context).style
                              .copyWith(
                                color: AppTheme.mutedText,
                                fontSize: subtitleSize,
                                height: 1.3,
                              );

                          final painter = TextPainter(
                            text: TextSpan(text: text, style: style),
                            textDirection: direction,
                            textScaler: scaler,
                            maxLines: 1,
                          )..layout();

                          final overflows =
                              painter.width > constraints.maxWidth;

                          painter.dispose();

                          final reduceMotion = MediaQuery.of(
                            context,
                          ).disableAnimations;

                          return Tooltip(
                            message: text,
                            child: !overflows || reduceMotion
                                ? Text(
                                    text,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: style,
                                  )
                                : Semantics(
                                    label: text,
                                    excludeSemantics: true,
                                    child: Marquee(
                                      key: ValueKey((
                                        text,
                                        constraints.maxWidth,
                                        scaler.scale(subtitleSize),
                                        direction,
                                      )),
                                      text: text,
                                      style: style,
                                      textDirection: direction,
                                      textScaleFactor:
                                          scaler.scale(subtitleSize) /
                                          subtitleSize,
                                      velocity: 25,
                                      blankSpace: 40,
                                      startAfter: const Duration(seconds: 1),
                                      pauseAfterRound: Duration.zero,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
