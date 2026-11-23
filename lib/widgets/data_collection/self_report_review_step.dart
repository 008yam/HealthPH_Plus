import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../theme/app_theme.dart';

class SelfReportReviewStep extends StatelessWidget {
  final List<String> symptomLabels;
  final String location;
  final String possibleConditionLabel;
  final String notes;

  const SelfReportReviewStep({
    super.key,
    required this.symptomLabels,
    required this.location,
    required this.possibleConditionLabel,
    required this.notes,
  });

  Widget _reviewRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(title),
                  style: const TextStyle(
                    color: AppTheme.mutedText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final translatedSymptoms = symptomLabels.map(context.tr).join(', ');

    final displayedNotes = notes.isEmpty
        ? context.tr('No additional notes provided.')
        : notes;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      children: [
        Text(
          context.tr('Review your self-report'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          context.tr('Confirm the information below before submitting.'),
          style: const TextStyle(color: AppTheme.mutedText),
        ),
        const SizedBox(height: 18),
        _reviewRow(
          context,
          icon: Icons.sick_outlined,
          title: 'Symptoms',
          value: translatedSymptoms,
        ),
        _reviewRow(
          context,
          icon: Icons.location_on_outlined,
          title: 'Location',
          value: location,
        ),
        _reviewRow(
          context,
          icon: Icons.medical_information_outlined,
          title: 'Possible condition',
          value: context.tr(possibleConditionLabel),
        ),
        _reviewRow(
          context,
          icon: Icons.notes_outlined,
          title: 'Additional notes',
          value: displayedNotes,
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.warning.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            context.tr(
              'This result is not a diagnosis. Consult a healthcare provider if symptoms worsen.',
            ),
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
