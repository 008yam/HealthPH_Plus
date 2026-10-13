import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthphplus/localization/app_translations.dart';
import 'package:healthphplus/services/app_settings_store.dart';
import 'package:healthphplus/services/profile_store.dart';
import 'package:healthphplus/pages/language_selection_page.dart';
import 'package:healthphplus/widgets/feature_tile.dart';

void main() {
  test(
    'Cebuano catalog has complete inventory coverage and stable placeholders',
    () {
      final catalog = appTranslations['Cebuano']!;
      expect(catalog.length, greaterThanOrEqualTo(419));
      final inventory = File(
        'reports/translations/HealthPH_Static_Text_Inventory.txt',
      ).readAsStringSync();
      for (final match in RegExp(
        r'^\[\d+\] (.+)$',
        multiLine: true,
      ).allMatches(inventory)) {
        expect(catalog.containsKey(match[1]), isTrue, reason: match[1]);
      }
      final placeholders = RegExp(r'\{[^{}]+\}');
      for (final entry in catalog.entries) {
        expect(entry.value.trim(), isNotEmpty, reason: entry.key);
        final source =
            placeholders.allMatches(entry.key).map((m) => m[0]).toList()
              ..sort();
        final translated =
            placeholders.allMatches(entry.value).map((m) => m[0]).toList()
              ..sort();
        expect(translated, source, reason: entry.key);
      }
      expect(catalog.containsKey('Choose Lanaguage'), isFalse);
      expect(catalog.containsKey('Mobile SUrvey'), isFalse);
      expect(
        translateText('Choose Language', 'Cebuano'),
        'Pagpili og Pinulongan',
      );
      expect(translateText('Watch video', 'Cebuano'), 'Tan-awa ang Bidyo');
      expect(translateText('PDF', 'Cebuano'), 'PDF');
      expect(
        translateText('{count} reports', 'Cebuano', parameters: {'count': 3}),
        '3 ka report',
      );
    },
  );

  testWidgets('shared titles and subtitles switch to Cebuano and back', (
    tester,
  ) async {
    const tile = FeatureTile(
      icon: Icons.menu_book,
      title: 'Health Literacy',
      description: 'Track outbreaks and alerts',
    );
    Widget app(String language) => MaterialApp(
      home: AppLanguageScope(
        language: language,
        child: const Scaffold(body: tile),
      ),
    );
    await tester.pumpWidget(app('English'));
    expect(find.text('Health Literacy'), findsOneWidget);
    await tester.pumpWidget(app('Cebuano'));
    expect(find.text('Kahibalo sa Panglawas'), findsOneWidget);
    expect(
      find.text('Subaybayi ang pagkaylap sa sakit ug mga pasidaan'),
      findsOneWidget,
    );
    await tester.pumpWidget(app('English'));
    expect(find.text('Health Literacy'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'language selection translates guidance but keeps language identifiers',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'healthph_selected_language': 'Cebuano',
      });
      ProfileStore.instance.clearProfile();
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(
          home: AppLanguageScope(
            language: 'Cebuano',
            child: LanguageSelectionPage(returnToSettings: true),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Pagpili og Pinulongan'), findsOneWidget);
      expect(find.text('Kini ang imong napiling pinulongan'), findsOneWidget);
      expect(find.text('Cebuano'), findsOneWidget);
      expect(find.text('Filipino'), findsOneWidget);
      expect(find.text('Padayon'), findsOneWidget);
      expect(tester.takeException(), isNull);
      tester.view.physicalSize = const Size(932, 430);
      await tester.pumpAndSettle();
      expect(find.text('Pagpili og Pinulongan'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
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
