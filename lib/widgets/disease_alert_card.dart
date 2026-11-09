import 'package:flutter/material.dart';
import '../localization/app_translations.dart';
import '../models/mobile_alert.dart';
import '../theme/app_theme.dart';

class DiseaseAlertCard extends StatelessWidget {
  final MobileAlert alert;
  final VoidCallback? onOpen;
  const DiseaseAlertCard({super.key, required this.alert, this.onOpen});

  @override
  Widget build(BuildContext context) {
    final unread = alert.readAt == null;
    final accent = unread ? const Color(0xFFDC4949) : AppTheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: .1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.health_and_safety_outlined,
                        color: accent,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        alert.title,
                        style: const TextStyle(
                          color: AppTheme.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 17,
                      color: AppTheme.mutedText,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        alert.regionName.isEmpty
                            ? alert.region
                            : alert.regionName,
                        style: const TextStyle(
                          color: AppTheme.mutedText,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                if (alert.message.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    alert.message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.text,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        context.tr(unread ? 'Unread' : 'Read'),
                        style: TextStyle(
                          color: accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      context.tr(
                        '{reports} reports',
                        parameters: {'reports': alert.reportCount},
                      ),
                      style: const TextStyle(
                        color: AppTheme.mutedText,
                        fontSize: 12,
                      ),
                    ),
                    if (alert.publishedAt != null)
                      Text(
                        MaterialLocalizations.of(
                          context,
                        ).formatMediumDate(alert.publishedAt!.toLocal()),
                        style: const TextStyle(
                          color: AppTheme.mutedText,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const Divider(height: 20, color: AppTheme.border),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onOpen,
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: Text(context.tr('View Details')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
