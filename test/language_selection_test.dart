import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthphplus/pages/language_selection_page.dart';
import 'package:healthphplus/services/app_settings_store.dart';
import 'package:healthphplus/services/healthph_api_services.dart';
import 'package:healthphplus/services/profile_store.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const profile = UserProfile(
  id: 'MUSER-000004',
  fullName: 'Test User',
  email: 'test@example.invalid',
  accessToken: 'test-token',
  pinConfigured: true,
  roleId: 'user',
  role: 'User',
  language: 'English',
  regionCode: 'NCR',
  regionLabel: 'National Capital Region',
  province: 'Metro Manila',
  city: 'Manila',
  barangay: 'Test Barangay',
);

HealthPhApiService apiFor(http.Client client, {String? base}) =>
    HealthPhApiService(
      baseUrl: base ?? 'https://example.invalid',
      client: client,
    );

Future<void> openPage(WidgetTester tester, HealthPhApiService api) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) =>
                    LanguageSelectionPage(returnToSettings: true, api: api),
              ),
            ),
            child: const Text('Open languages'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open languages'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Filipino'));
  await tester.tap(find.text('Continue'));
  await tester.pump();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppSettingsStore.instance.setLanguage('English');
    ProfileStore.instance.saveProfile(profile);
  });
  tearDown(() => ProfileStore.instance.clearProfile());

  for (final base in [
    'https://example.invalid',
    'https://example.invalid/api/',
  ]) {
    test('language request normalizes $base and sends bearer token', () async {
      final client = MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(
          request.url.toString(),
          'https://example.invalid/api/mobile/users/MUSER-000004/language',
        );
        expect(request.headers['Authorization'], 'Bearer test-token');
        expect(jsonDecode(request.body), {'language': 'Filipino'});
        return http.Response(
          jsonEncode({'id': profile.id, 'language': 'Filipino'}),
          200,
        );
      });
      final result = await apiFor(client, base: base).updatedMobileUserLanguage(
        userId: profile.id!,
        language: 'Filipino',
        accessToken: profile.accessToken,
      );
      expect(result.language, 'Filipino');
      client.close();
    });
  }

  for (final status in [401, 403, 404, 405, 500]) {
    test('HTTP $status becomes a safe typed error', () async {
      final client = MockClient(
        (_) async => http.Response('private server detail', status),
      );
      await expectLater(
        apiFor(client).updatedMobileUserLanguage(
          userId: profile.id!,
          language: 'Filipino',
          accessToken: profile.accessToken,
        ),
        throwsA(
          isA<LanguageUpdateException>()
              .having((e) => e.statusCode, 'status', status)
              .having(
                (e) => e.message.contains('private server detail'),
                'no raw body',
                false,
              ),
        ),
      );
      client.close();
    });
  }

  test('missing token never sends an HTTP request', () async {
    final client = MockClient(
      (_) async => throw StateError('Must not request'),
    );
    await expectLater(
      apiFor(client).updatedMobileUserLanguage(
        userId: profile.id!,
        language: 'Filipino',
        accessToken: null,
      ),
      throwsA(
        isA<LanguageUpdateException>().having(
          (e) => e.statusCode,
          'status',
          401,
        ),
      ),
    );
    client.close();
  });

  test(
    'unexpected success payload is not accepted as a saved preference',
    () async {
      final client = MockClient((_) async => http.Response('{}', 200));
      await expectLater(
        apiFor(client).updatedMobileUserLanguage(
          userId: profile.id!,
          language: 'Filipino',
          accessToken: profile.accessToken,
        ),
        throwsFormatException,
      );
      client.close();
    },
  );

  testWidgets('404 stays handled; local saving requires explicit consent', (
    tester,
  ) async {
    final client = MockClient(
      (_) async => http.Response('{"detail":"Not Found"}', 404),
    );
    addTearDown(client.close);
    await openPage(tester, apiFor(client));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Account language not saved'), findsOneWidget);
    expect(AppSettingsStore.instance.language, 'English');
    expect(ProfileStore.instance.profile!.language, 'English');
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(LanguageSelectionPage), findsOneWidget);
    expect(AppSettingsStore.instance.language, 'English');
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Use on this device'));
    await tester.pumpAndSettle();
    expect(find.byType(LanguageSelectionPage), findsNothing);
    expect(AppSettingsStore.instance.language, 'Filipino');
    expect(
      (await SharedPreferences.getInstance()).getString(
        'healthph_selected_language',
      ),
      'Filipino',
    );
    expect(ProfileStore.instance.profile!.accessToken, profile.accessToken);
    expect(ProfileStore.instance.profile!.fullName, profile.fullName);
    expect(ProfileStore.instance.profile!.pinConfigured, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('successful save preserves identity and blocks repeated taps', (
    tester,
  ) async {
    final completion = Completer<http.Response>();
    var calls = 0;
    final client = MockClient((_) {
      calls++;
      return completion.future;
    });
    addTearDown(client.close);
    await openPage(tester, apiFor(client));
    await tester.pump();
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    expect(calls, 1);
    completion.complete(
      http.Response(
        jsonEncode({'id': profile.id, 'language': 'Filipino'}),
        200,
      ),
    );
    await tester.pumpAndSettle();
    expect(AppSettingsStore.instance.language, 'Filipino');
    expect(ProfileStore.instance.profile!.fullName, profile.fullName);
    expect(ProfileStore.instance.profile!.email, profile.email);
    expect(ProfileStore.instance.profile!.regionCode, 'NCR');
    expect(ProfileStore.instance.profile!.pinConfigured, isTrue);
    expect(ProfileStore.instance.profile!.accessToken, profile.accessToken);
    expect(find.byType(LanguageSelectionPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('guest language stays local without a backend request', (
    tester,
  ) async {
    ProfileStore.instance.clearProfile();
    final client = MockClient(
      (_) async => throw StateError('Must not request'),
    );
    addTearDown(client.close);
    await openPage(tester, apiFor(client));
    await tester.pumpAndSettle();
    expect(AppSettingsStore.instance.language, 'Filipino');
    expect(find.byType(LanguageSelectionPage), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
