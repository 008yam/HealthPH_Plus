import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marquee/marquee.dart';
import 'package:healthphplus/main_page.dart';

const longSubtitle =
    'Review your previous contributions and all your submitted health reports';

Widget harness({
  String subtitle = longSubtitle,
  double width = 320,
  bool reducedMotion = false,
  double scale = 1,
  VoidCallback? onTap,
}) {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: width,
          child: MediaQuery(
            data: MediaQueryData(
              disableAnimations: reducedMotion,
              textScaler: TextScaler.linear(scale),
            ),
            child: QuickActionTile(
              title: 'Sentiment Pulse and Mobile Survey',
              subtitle: subtitle,
              icon: Icons.poll_outlined,
              iconColor: Colors.blue,
              onTap: onTap ?? () {},
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('short subtitle stays still', (tester) async {
    await tester.pumpWidget(harness(subtitle: 'View reports'));
    expect(find.byType(Marquee), findsNothing);
    expect(find.text('View reports'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long subtitle scrolls without resizing the tile', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(harness(onTap: () => taps++));
    await tester.pump();
    expect(find.byType(Marquee), findsOneWidget);
    final size = tester.getSize(find.byType(QuickActionTile));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 500));
    final scroll = tester.state<ScrollableState>(
      find
          .descendant(
            of: find.byType(Marquee),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(scroll.position.pixels, greaterThan(0));
    expect(tester.getSize(find.byType(QuickActionTile)), size);
    await tester.tap(find.byIcon(Icons.poll_outlined));
    expect(taps, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('reduced motion keeps full subtitle available in tooltip', (
    tester,
  ) async {
    await tester.pumpWidget(harness(reducedMotion: true, scale: 1.8));
    expect(find.byType(Marquee), findsNothing);
    expect(tester.widget<Tooltip>(find.byType(Tooltip)).message, longSubtitle);
    expect(tester.takeException(), isNull);
  });

  testWidgets('resizing replaces scrolling with static text when it fits', (
    tester,
  ) async {
    await tester.pumpWidget(harness());
    await tester.pump();
    expect(find.byType(Marquee), findsOneWidget);
    await tester.pumpWidget(harness(width: 790, subtitle: 'View reports'));
    await tester.pump(const Duration(seconds: 10));
    expect(find.byType(Marquee), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
