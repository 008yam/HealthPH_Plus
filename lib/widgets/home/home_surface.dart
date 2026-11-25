import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/responsive.dart';

class HomeContentSurface extends StatelessWidget {
  final Widget child;

  const HomeContentSurface({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Responsive.contentMaxWidth(context),
        ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(color: AppTheme.text),
          child: child,
        ),
      ),
    );
  }
}

BoxDecoration homeCardDecoration() {
  return BoxDecoration(
    color: AppTheme.surfaceSoft,
    border: Border.all(color: AppTheme.border),
    borderRadius: BorderRadius.circular(12),
  );
}
