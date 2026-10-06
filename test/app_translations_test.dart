import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthphplus/localization/app_translations.dart';
import 'package:healthphplus/services/app_settings_store.dart';

void main() {
  test('looks up every supported language and falls back to English', () {
    for (final language in AppSettingsStore.supportedLanguages) {
      expect(translateText('Home', language), isNotEmpty);
      expect(
        translateText('Untranslated phrase', language),
        'Untranslated phrase',
      );
    }
    expect(translateText('Home', 'Filipino'), 'Simula');
    expect(translateText('Home', 'unknown'), 'Home');
    expect(
      translateText('{count} reports', 'English', parameters: {'count': 3}),
      '3 reports',
    );
  });

  test('saves, restores and validates language preferences', () async {
    SharedPreferences.setMockInitialValues({});
    final settings = AppSettingsStore.instance;
    await settings.setLanguage('Ilocano');
    await settings.load();
    expect(settings.language, 'Ilocano');
    await settings.setLanguage('invalid');
    expect(settings.language, 'English');
  });

  testWidgets('existing widgets update when the language changes', (
    tester,
  ) async {
    final child = Builder(builder: (context) => Text(context.tr('Home')));
    Widget app(String language) => Directionality(
      textDirection: TextDirection.ltr,
      child: AppLanguageScope(language: language, child: child),
    );
    await tester.pumpWidget(app('English'));
    expect(find.text('Home'), findsOneWidget);
    await tester.pumpWidget(app('Filipino'));
    expect(find.text('Simula'), findsOneWidget);
  });
}
