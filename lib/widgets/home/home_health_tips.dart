import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../theme/app_theme.dart';
import 'home_surface.dart';

class HomeHealthTips extends StatelessWidget {
  final VoidCallback onViewMore;

  const HomeHealthTips({
    super.key,
    required this.onViewMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: homeCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('Health Tips 📖'),
            style: const TextStyle(
              color: AppTheme.text,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFD9F8D8),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('Stay Protected'),
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(
                    'Remember to wash your hands frequently, weak mask in crowded places, and keep your living spaces well-ventilated',
                  ),
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: onViewMore,
                      child: Text(
                        context.tr('More Health Tips'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}