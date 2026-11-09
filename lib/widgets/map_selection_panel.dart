import 'package:flutter/material.dart';

class MapSelectionPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool expanded;
  final double height;
  final VoidCallback onToggle;
  final Widget child;

  const MapSelectionPanel({
    super.key,
    required this.title,
    required this.icon,
    required this.expanded,
    required this.height,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            dense: true,
            minVerticalPadding: 4,
            horizontalTitleGap: 4,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            title: Text(
              title,
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            trailing: Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              color: colors.onSurface,
              size: 20,
            ),
            onTap: onToggle,
          ),
          if (expanded)
            SizedBox(
              height: height,
              width: double.infinity,
              child: child,
            ),
        ],
      ),
    );
  }
}