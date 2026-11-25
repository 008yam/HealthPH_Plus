import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../models/mobile_survey.dart';
import '../../theme/app_theme.dart';

class SurveyQuestionCard extends StatelessWidget {
  final int number;
  final MobileSurveyQuestion question;
  final Map<String, dynamic> answers;
  final bool isSubmitting;
  final VoidCallback onChanged;

  const SurveyQuestionCard({
    super.key,
    required this.number,
    required this.question,
    required this.answers,
    required this.isSubmitting,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final answer = answers[question.id];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ${question.title}'
            '${question.isRequired ? ' *' : ''}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: 10),
          _buildQuestionInput(context, answer),
        ],
      ),
    );
  }

  Widget _buildQuestionInput(BuildContext context, dynamic answer) {
    switch (question.type) {
      case 'multipleChoice':
        return Column(
          children: question.choices.map((choice) {
            final isSelected = answer?.toString() == choice;

            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: isSubmitting
                  ? null
                  : () {
                      answers[question.id] = choice;
                      onChanged();
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isSelected ? AppTheme.primary : AppTheme.mutedText,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        choice,
                        style: const TextStyle(color: AppTheme.text),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );

      case 'rating':
        final min = question.rateMin;
        final max = question.rateMax;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(max - min + 1, (index) {
            final value = min + index;
            final isSelected = answer == value;

            return ChoiceChip(
              label: Text(
                '$value',
                style: const TextStyle(color: AppTheme.text),
              ),
              selected: isSelected,
              onSelected: isSubmitting
                  ? null
                  : (_) {
                      answers[question.id] = value;
                      onChanged();
                    },
            );
          }),
        );

      case 'text':
      default:
        return TextFormField(
          enabled: !isSubmitting,
          style: const TextStyle(color: AppTheme.text),
          cursorColor: AppTheme.primary,
          minLines: 2,
          maxLines: 4,
          initialValue: answer?.toString(),
          decoration: InputDecoration(
            hintText: context.tr('Type your answer'),
            hintStyle: const TextStyle(color: AppTheme.mutedText),
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (question.isRequired &&
                (value == null || value.trim().isEmpty)) {
              return context.tr('This question is required.');
            }

            return null;
          },
          onChanged: (value) {
            answers[question.id] = value;
          },
        );
    }
  }
}
