import 'package:flutter/material.dart';

import '../../data/app_taxonomy.dart';
import '../../localization/app_translations.dart';
import '../../theme/app_theme.dart';

class SelfReportSymptomsStep extends StatelessWidget {
  final Set<String> selectedSymptomIds;
  final TextEditingController notesController;
  final void Function(String symptomId, bool selected) onSymptomChanged;

  const SelfReportSymptomsStep({
    super.key,
    required this.selectedSymptomIds,
    required this.notesController,
    required this.onSymptomChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      children: [
        Text(
          context.tr('Select your symptoms'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          context.tr("Select all symptoms you're experiencing."),
          style: const TextStyle(color: AppTheme.mutedText),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppTaxonomy.symptoms.map((symptom) {
            final selected = selectedSymptomIds.contains(symptom.id);

            return FilterChip(
              label: Text(context.tr(symptom.label)),
              selected: selected,
              selectedColor: AppTheme.primary.withValues(alpha: 0.16),
              checkmarkColor: AppTheme.primary,
              onSelected: (checked) {
                onSymptomChanged(symptom.id, checked);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: notesController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: context.tr('Additional notes (optional)'),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}
