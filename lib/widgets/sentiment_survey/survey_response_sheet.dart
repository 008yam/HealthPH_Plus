import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../models/mobile_survey.dart';
import '../../services/profile_store.dart';
import '../../services/sentiment_survey_service.dart';
import '../../theme/app_theme.dart';
import 'survey_question_card.dart';

class SurveyResponseSheet extends StatefulWidget {
  final MobileSurvey survey;
  final SentimentSurveyService surveyService;
  final VoidCallback onSubmitted;

  const SurveyResponseSheet({
    super.key,
    required this.survey,
    required this.surveyService,
    required this.onSubmitted,
  });

  @override
  State<SurveyResponseSheet> createState() => _SurveyResponseSheetState();
}

class _SurveyResponseSheetState extends State<SurveyResponseSheet> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> answers = {};
  bool isSubmitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cleanedAnswers = Map<String, dynamic>.from(answers)
      ..removeWhere(
        (_, value) => value == null || value.toString().trim().isEmpty,
      );

    if (cleanedAnswers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr("Please answer at least one question.")),
        ),
      );
      return;
    }

    final profile = ProfileStore.instance.profile;

    final userLocation = <String, dynamic>{
      "regionCode": profile?.regionCode,
      "regionLabel": profile?.regionLabel,
      "province": profile?.province,
      "city": profile?.city,
      "barangay": profile?.barangay,
    }..removeWhere((_, value) => value == null || value == "");

    final metadata = <String, dynamic>{"roleId": profile?.roleId}
      ..removeWhere((_, value) => value == null || value == "");

    setState(() => isSubmitting = true);

    try {
      await widget.surveyService.submitSurveyResponse(
        surveyId: widget.survey.id,
        answers: cleanedAnswers,
        region: profile?.regionLabel,
        userId: profile?.id,
        accessToken: profile?.accessToken,
        userLocation: userLocation,
        metadata: metadata,
      );

      if (!mounted) return;
      Navigator.pop(context);
      widget.onSubmitted();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr("Survey response submitted."))),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr("Unable to submit survey response.")),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 18, 8),
            child: Row(
              children: [
                IconButton(
                  tooltip: context.tr('Back'),
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(context).maybePop(),
                  color: AppTheme.primary,
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.survey.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                18,
                0,
                18,
                MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.survey.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.survey.subtitle,
                        style: const TextStyle(color: AppTheme.mutedText),
                      ),
                    ],
                    const SizedBox(height: 16),
                    ...List.generate(widget.survey.questions.length, (index) {
                      return SurveyQuestionCard(
                        number: index + 1,
                        question: widget.survey.questions[index],
                        answers: answers,
                        isSubmitting: isSubmitting,
                        onChanged: () => setState(() {}),
                      );
                    }),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: isSubmitting ? null : _submit,
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send),
                        label: Text(
                          isSubmitting
                              ? context.tr("Submitting...")
                              : context.tr("Submit"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
