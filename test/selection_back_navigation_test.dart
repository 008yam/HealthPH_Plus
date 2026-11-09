import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthphplus/models/mobile_survey.dart';
import 'package:healthphplus/pages/language_selection_page.dart';
import 'package:healthphplus/pages/sentiment_pulse_page.dart';
import 'package:healthphplus/services/app_settings_store.dart';
import 'package:healthphplus/services/profile_store.dart';
import 'package:healthphplus/services/sentiment_survey_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordingSurveyService extends SentimentSurveyService {
  RecordingSurveyService() : super(baseUrl: 'https://example.invalid');
  int submissions = 0;

  @override
  Future<void> submitSurveyResponse({
    required String surveyId,
    required Map<String, dynamic> answers,
    String? region,
    String? userId,
    String? accessToken,
    Map<String, dynamic>? userLocation,
    Map<String, dynamic>? metadata,
  }) async {
    submissions++;
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    ProfileStore.instance.clearProfile();
    await AppSettingsStore.instance.setLanguage('English');
  });

  for (final fromSettings in [true, false]) {
    testWidgets(
      'language back returns without saving (settings: $fromSettings)',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          LanguageSelectionPage(returnToSettings: fromSettings),
                    ),
                  ),
                  child: const Text('Previous page'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Previous page'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Filipino'));
        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();
        expect(find.text('Previous page'), findsOneWidget);
        expect(find.byType(LanguageSelectionPage), findsNothing);
        expect(AppSettingsStore.instance.language, 'English');
        expect(
          (await SharedPreferences.getInstance()).getString(
            'healthph_selected_language',
          ),
          'English',
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final size in [const Size(390, 844), const Size(844, 390)]) {
    testWidgets('survey back stays visible while scrolling at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final service = RecordingSurveyService();
      var refreshed = false;
      final survey = MobileSurvey.fromJson({
        'id': 'SUR00001',
        'title': 'A survey with a long title that should fit its mobile header',
        'questions': List.generate(
          12,
          (index) => {
            'id': 'Q$index',
            'title': 'Question $index',
            'type': 'text',
          },
        ),
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => SurveyResponseSheet(
                    survey: survey,
                    surveyService: service,
                    onSubmitted: () => refreshed = true,
                  ),
                ),
                child: const Text('Open survey'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open survey'));
      await tester.pumpAndSettle();
      final before = tester.getCenter(find.byTooltip('Back'));
      await tester.enterText(
        find.byType(TextFormField).first,
        'An unsent answer',
      );
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();
      expect(tester.getCenter(find.byTooltip('Back')), before);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.byType(SurveyResponseSheet), findsNothing);
      expect(find.text('Open survey'), findsOneWidget);
      expect(service.submissions, 0);
      expect(refreshed, isFalse);
      expect(tester.takeException(), isNull);
    });
  }
}
