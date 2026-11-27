import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';

class OutbreakDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> outbreak;
  const OutbreakDetailsSheet({super.key, required this.outbreak});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final rawTags = outbreak['tags'];
    final tags = rawTags is List
        ? rawTags.whereType<String>().toList()
        : <String>[];
    String value(String key) => outbreak[key]?.toString() ?? '';
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: DefaultTextStyle(
          style: TextStyle(color: colors.onSurface, fontSize: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr(value('disease')),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: context.tr('Close'),
                    color: colors.onSurface,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                value('name'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                context.tr(value('category')),
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr(
                  '{count} reports',
                  parameters: {'count': outbreak['reports'] ?? 0},
                ),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                value('updated'),
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
              if (value('pinAccuracy').isNotEmpty)
                Text(
                  context.tr(value('pinAccuracy')),
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: tags
                    .map(
                      (tag) => Chip(
                        label: Text(
                          context.tr(tag),
                          style: TextStyle(color: colors.onSecondaryContainer),
                        ),
                        backgroundColor: colors.secondaryContainer,
                        side: BorderSide(color: colors.outlineVariant),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
