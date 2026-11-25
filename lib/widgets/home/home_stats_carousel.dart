import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/responsive.dart';
import 'carousel_stat_card.dart';

class HomeStatsCarousel extends StatelessWidget {
  final Future<int> activeUserCountFuture;
  final Future<int> surveyCountFuture;
  final Future<int> alertCountFuture;
  final PageController controller;
  final int selectedIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onHealthAlerts;
  final VoidCallback onSurveys;

  const HomeStatsCarousel({
    super.key,
    required this.activeUserCountFuture,
    required this.surveyCountFuture,
    required this.alertCountFuture,
    required this.controller,
    required this.selectedIndex,
    required this.onPageChanged,
    required this.onHealthAlerts,
    required this.onSurveys,
  });

  String _snapshotValue(AsyncSnapshot<int> snapshot) {
    if (snapshot.hasData) {
      return snapshot.data.toString();
    }

    if (snapshot.hasError) {
      return '0';
    }

    return '...';
  }

  @override
  Widget build(BuildContext context) {
    final isLandscapePhone = Responsive.isLandscapePhone(context);
    final carouselHeight = isLandscapePhone ? 92.0 : 112.0;

    return FutureBuilder<int>(
      future: activeUserCountFuture,
      builder: (context, userSnapshot) {
        return FutureBuilder<int>(
          future: surveyCountFuture,
          builder: (context, surveySnapshot) {
            return FutureBuilder<int>(
              future: alertCountFuture,
              builder: (context, alertSnapshot) {
                final activeUsers = _snapshotValue(userSnapshot);
                final alertCount = _snapshotValue(alertSnapshot);
                final surveyCount = _snapshotValue(surveySnapshot);

                final cards = <Widget>[
                  CarouselStatCard(
                    number: alertCount,
                    label: 'Health Alerts',
                    subtitle: 'Recent inbox alerts',
                    icon: Icons.local_hospital,
                    accentColor: AppTheme.warning,
                    onTap: onHealthAlerts,
                  ),
                  CarouselStatCard(
                    number: activeUsers,
                    label: 'Active Users',
                    subtitle: 'Registered mobile users',
                    icon: Icons.groups,
                    accentColor: AppTheme.success,
                  ),
                  CarouselStatCard(
                    number: surveyCount,
                    label: 'Mobile Surveys',
                    subtitle: 'Available public surveys',
                    icon: Icons.poll_outlined,
                    accentColor: AppTheme.info,
                    onTap: onSurveys,
                  ),
                ];

                return Column(
                  children: [
                    SizedBox(
                      height: carouselHeight,
                      child: PageView.builder(
                        controller: controller,
                        itemCount: cards.length,
                        onPageChanged: onPageChanged,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: cards[index],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(cards.length, (index) {
                        final selected = index == selectedIndex;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: selected ? 18 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.primary
                                : AppTheme.border,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
