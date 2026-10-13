import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthphplus/models/mobile_alert.dart';
import 'package:healthphplus/pages/disease_watch_page.dart';
import 'package:healthphplus/services/mobile_alert_service.dart';

MobileAlert alert(String id) => MobileAlert.fromJson({
  'id': id,
  'title': 'Alert $id',
  'regionName': 'Manila',
  'message': 'Published alert details',
  'reportCount': 8,
});

class FakeAlerts extends MobileAlertService {
  FakeAlerts() : super(baseUrl: 'http://unused');
  bool unauthorized = false;
  int reads = 0;
  final cursors = <String?>[];
  @override
  Future<MobileAlertsPage> fetchAlerts({
    int limit = 20,
    String? cursor,
    String? accessToken,
  }) async {
    cursors.add(cursor);
    if (unauthorized) {
      throw const MobileAlertAuthenticationException(
        'Sign in with a registered account to view alerts.',
      );
    }
    return MobileAlertsPage(
      items: [alert(cursor == null ? 'one' : 'two')],
      nextCursor: cursor == null ? 'next' : null,
      unreadCount: 1,
    );
  }

  @override
  Future<MobileAlert> fetchAlert({
    required String alertId,
    required String? accessToken,
  }) async => alert(alertId);
  @override
  Future<MobileAlertReadResult> markAlertRead({
    required String alertId,
    required String? accessToken,
  }) async {
    reads++;
    return MobileAlertReadResult(item: alert(alertId), unreadCount: 0);
  }
}

void main() {
  testWidgets('loads inbox, searches, paginates and opens real details', (
    tester,
  ) async {
    final service = FakeAlerts();
    await tester.pumpWidget(
      MaterialApp(home: DiseaseWatchPage(alertService: service)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Alert one'), findsOneWidget);
    expect(find.text('Respiratory Infection Cluster'), findsNothing);
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    expect(service.cursors, [null, 'next']);
    expect(find.text('Alert two'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pumpAndSettle();
    expect(find.text('No matching alerts.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'one');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alert one'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(service.reads, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('authentication failure is not shown as an empty inbox', (
    tester,
  ) async {
    final service = FakeAlerts()..unauthorized = true;
    await tester.pumpWidget(
      MaterialApp(home: DiseaseWatchPage(alertService: service)),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Sign in with a registered account to view alerts.'),
      findsOneWidget,
    );
    expect(find.text('No recent alerts right now.'), findsNothing);
    service.unauthorized = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Alert one'), findsOneWidget);
  });

  testWidgets('dark landscape with large text has no overflow', (tester) async {
    tester.view.physicalSize = const Size(932, 430);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.8)),
          child: child!,
        ),
        home: DiseaseWatchPage(alertService: FakeAlerts()),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
