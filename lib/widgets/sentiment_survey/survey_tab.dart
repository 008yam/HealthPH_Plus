import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../models/mobile_survey.dart';
import '../../services/api_config.dart';
import '../../services/sentiment_survey_service.dart';
import '../../theme/app_theme.dart';
import '../animated_state_view.dart';
import 'survey_response_sheet.dart';

class SurveyTab extends StatefulWidget {
  const SurveyTab({super.key});

  @override
  State<SurveyTab> createState() => _SurveyTabState();
}

class _SurveyTabState extends State<SurveyTab> {
  late Future<List<MobileSurvey>> surveyFuture;

  final surveyService = SentimentSurveyService(
    baseUrl: ApiConfig.sentimentBaseUrl,
  );

  @override
  void initState() {
    super.initState();
    surveyFuture = surveyService.fetchPublicSurveys();
  }

  void _refreshSurveys() {
    setState(() {
      surveyFuture = surveyService.fetchPublicSurveys();
    });
  }

  void _openSurvey(MobileSurvey survey) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Theme(
          data: AppTheme.lightTheme,
          child: SurveyResponseSheet(
            survey: survey,
            surveyService: surveyService,
            onSubmitted: _refreshSurveys,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MobileSurvey>>(
      future: surveyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return AnimatedStateView(
            animation: StateAnimationKind.empty,
            title: context.tr('Unable to load surveys.'),
            actionLabel: context.tr('Retry'),
            onAction: _refreshSurveys,
          );
        }

        final surveys = snapshot.data ?? [];

        if (surveys.isEmpty) {
          return AnimatedStateView(
            animation: StateAnimationKind.empty,
            title: context.tr('No active mobile surveys currently available.'),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: surveys.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final survey = surveys[index];
            final progress = survey.target <= 0
                ? 0.0
                : (survey.responses / survey.target).clamp(0.0, 1.0);

            return InkWell(
              onTap: () => _openSurvey(survey),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      survey.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    if (survey.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        survey.subtitle,
                        style: const TextStyle(
                          color: AppTheme.mutedText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    LinearProgressIndicator(value: progress),
                    const SizedBox(height: 6),
                    Text(
                      context.tr(
                        "{survey.responses} / {survey.target} responses",
                        parameters: {
                          "survey.responses": survey.responses,
                          "survey.target": survey.target,
                        },
                      ),
                      style: const TextStyle(
                        color: AppTheme.mutedText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
