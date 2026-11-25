import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../models/mobile_alert.dart';
import '../../services/mobile_alert_service.dart';
import '../../theme/app_theme.dart';
import 'alert_card.dart';
import 'home_surface.dart';
import 'recent_alerts_skeleton.dart';

class HomeRecentAlerts extends StatelessWidget {
  final Future<MobileAlertsPage> alertsFuture;
  final ValueChanged<MobileAlert> onOpenAlert;

  const HomeRecentAlerts({
    super.key,
    required this.alertsFuture,
    required this.onOpenAlert,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MobileAlertsPage>(
      future: alertsFuture,
      builder: (context, snapshot) {
        final alerts = snapshot.data?.items ?? [];

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: homeCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('Recent Alerts ⓘ'),
                style: const TextStyle(
                  color: AppTheme.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              if (snapshot.connectionState == ConnectionState.waiting)
                const RecentAlertsSkeleton()
              else if (snapshot.hasError)
                Text(
                  snapshot.error is MobileAlertAuthenticationException
                      ? context.tr(snapshot.error.toString())
                      : context.tr('Unable to load alerts.'),
                  style: const TextStyle(
                    color: AppTheme.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else if (alerts.isEmpty)
                Text(
                  context.tr('No recent alerts right now.'),
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                )
              else
                ...alerts
                    .take(3)
                    .map(
                      (alert) => AlertCard(
                        title: alert.title,
                        location: alert.locationLabel,
                        percent: '${alert.reportCount}',
                        metricLabel: alert.countLabel,
                        progress: alert.progress,
                        onTap: () => onOpenAlert(alert),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
