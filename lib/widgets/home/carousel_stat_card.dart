import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../theme/app_theme.dart';
import '../../theme/responsive.dart';

class CarouselStatCard extends StatelessWidget {
  final String number;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;

  const CarouselStatCard({
    super.key,
    required this.number,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscapePhone = Responsive.isLandscapePhone(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.all(isLandscapePhone ? 12 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accentColor, AppTheme.primary],
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.22),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -22,
                child: Icon(
                  icon,
                  size: isLandscapePhone ? 76 : 96,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: isLandscapePhone ? 20 : 24,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: isLandscapePhone ? 22 : 26,
                    ),
                  ),
                  SizedBox(width: isLandscapePhone ? 10 : 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          number,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isLandscapePhone ? 24 : 30,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        SizedBox(height: isLandscapePhone ? 3 : 5),
                        Text(
                          context.tr(label),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isLandscapePhone ? 13 : 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.tr(subtitle),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
