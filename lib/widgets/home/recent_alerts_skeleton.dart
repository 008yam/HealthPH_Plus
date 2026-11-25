import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../app_skeleton.dart';

class RecentAlertsSkeleton extends StatelessWidget {
  const RecentAlertsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(height: 15, width: 210),
              SizedBox(height: 8),
              AppSkeleton(height: 12, width: 145),
              SizedBox(height: 14),
              AppSkeleton(height: 10, width: double.infinity),
            ],
          ),
        ),
      ),
    );
  }
}
