import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:healthphplus/pages/health_literacy_page.dart';
import 'package:healthphplus/widgets/literacy_media.dart';

class FakeVideos extends VideoPlayerPlatform {
  final streams = <int, StreamController<VideoEvent>>{};
  final urls = <String>[];
  final playing = <int>{};
  final volumes = <int, double>{};
  final disposed = <int>{};
  bool fail = false;
  @override
  Future<void> init() async {}
  @override
  Future<int> createWithOptions(VideoCreationOptions options) async {
    final id = streams.length;
    urls.add(options.dataSource.uri!);
    final stream = streams[id] = StreamController<VideoEvent>();
    if (fail) {
      stream.addError(PlatformException(code: 'unavailable', message: 'Media unavailable'));
    } else {
      stream.add(
        VideoEvent(
          eventType: VideoEventType.initialized,
          size: const Size(1280, 720),
          duration: const Duration(seconds: 60),
        ),
      );
    }
    return id;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => streams[playerId]!.stream;
  @override
  Future<void> dispose(int playerId) async {
    disposed.add(playerId);
    playing.remove(playerId);
  }

  @override
  Future<void> play(int playerId) async {
    playing.add(playerId);
  }

  @override
  Future<void> pause(int playerId) async {
    playing.remove(playerId);
  }

  @override
  Future<void> setVolume(int playerId, double volume) async {
    volumes[playerId] = volume;
  }

  @override
  Future<void> setLooping(int playerId, bool looping) async {}
  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}
  @override
  Future<void> setPreventsDisplaySleepDuringVideoPlayback(
    int playerId,
    bool preventsDisplaySleepDuringVideoPlayback,
  ) async {}
  @override
  Future<Duration> getPosition(int playerId) async => Duration.zero;
  @override
  Future<void> seekTo(int playerId, Duration position) async {}
  @override
  Widget buildView(int playerId) => const ColoredBox(color: Colors.teal);
}

const url = 'https://example.test/api/health-literacy-hub/media/video.mp4';
Widget preview({LiteracyPreviewGroup? group, String videoUrl = url}) =>
    LiteracyVideoPreview(
      url: videoUrl,
      title: 'Health video',
      previewOwner: group,
      thumbnail: const ColoredBox(color: Colors.amber),
    );

void main() {
  late FakeVideos videos;
  setUp(() {
    videos = FakeVideos();
    VideoPlayerPlatform.instance = videos;
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    VisibilityDetectorController.instance.updateInterval = const Duration(
      milliseconds: 500,
    );
  });

  Future<void> settlePreview(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
  }

  Future<void> cleanup(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
  }

  testWidgets('desktop hover previews muted, preserves URL, exits cleanly', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SizedBox(width: 300, child: preview())),
      ),
    );
    await settlePreview(tester);
    expect(videos.urls, isEmpty);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(700, 500));
    await mouse.moveTo(tester.getCenter(find.byType(LiteracyVideoPreview)));
    await settlePreview(tester);
    expect(videos.urls, [url]);
    expect(videos.playing, {0});
    expect(videos.volumes[0], 0);
    await mouse.moveTo(const Offset(700, 500));
    await tester.pump();
    expect(videos.disposed, contains(0));
    await mouse.removePointer();
    await cleanup(tester);
  });

  testWidgets(
    'phone previews one at a time and thumbnail opens audible modal',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final group = LiteracyPreviewGroup();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                SizedBox(height: 200, child: preview(group: group)),
                SizedBox(
                  height: 200,
                  child: preview(group: group, videoUrl: '$url?second=1'),
                ),
                const SizedBox(height: 1000),
              ],
            ),
          ),
        ),
      );
      await settlePreview(tester);
      expect(videos.playing.length, 1);
      await tester.tap(find.byType(LiteracyVideoPreview).first);
      await tester.pumpAndSettle();
      expect(find.byType(VideoPlayerDialog), findsOneWidget);
      expect(videos.playing.length, 1);
      expect(videos.volumes[videos.playing.single], 1);
      await tester.tap(find.byTooltip('Pause'));
      await tester.pump();
      expect(videos.playing, isEmpty);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -700));
      await settlePreview(tester);
      expect(videos.playing, isEmpty);
      await cleanup(tester);
      group.dispose();
    },
  );

  testWidgets('tab changes and app background stop previews', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(
      MaterialApp(
        home: DefaultTabController(
          length: 3,
          initialIndex: 1,
          child: Scaffold(
            appBar: AppBar(
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Articles'),
                  Tab(text: 'Videos'),
                  Tab(text: 'Images'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                const SizedBox(),
                ListView(children: [preview()]),
                const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
    await settlePreview(tester);
    expect(videos.playing.length, 1);
    tester.binding.handleAppLifecycleStateChanged(
      AppLifecycleState.paused,
    );
    await tester.pump();
    expect(videos.playing, isEmpty);
    tester.binding.handleAppLifecycleStateChanged(
      AppLifecycleState.resumed,
    );
    await settlePreview(tester);
    expect(videos.playing.length, 1);
    await tester.tap(find.text('Articles'));
    await tester.pumpAndSettle();
    expect(videos.playing, isEmpty);
    await cleanup(tester);
  });

  testWidgets(
    'preview failures retain clickable thumbnail and modal can retry',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      videos.fail = true;
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: preview())));
      await settlePreview(tester);
      await tester.tap(find.byType(LiteracyVideoPreview));
      await tester.pumpAndSettle();
      expect(find.text('Video is unavailable.'), findsOneWidget);
      videos.fail = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Pause'), findsOneWidget);
      await cleanup(tester);
    },
  );

  testWidgets('captions expand only when truncated', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 240,
            child: ExpandableMediaCaption(
              text: List.filled(20, 'Health information.').join(' '),
            ),
          ),
        ),
      ),
    );
    expect(find.text('See more'), findsOneWidget);
    await tester.tap(find.text('See more'));
    await tester.pump();
    expect(find.text('See less'), findsOneWidget);
    await tester.tap(find.text('See less'));
    await tester.pump();
    expect(find.text('See more'), findsOneWidget);
    await tester.pumpWidget(
      const MaterialApp(home: ExpandableMediaCaption(text: 'Short caption')),
    );
    expect(find.text('See more'), findsNothing);
    await cleanup(tester);
  });

  for (final size in [const Size(390, 844), const Size(844, 390)]) {
    testWidgets('media viewers fit $size with large text', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Widget app(Widget child) => MaterialApp(
        theme: ThemeData.dark(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: Scaffold(body: child),
      );
      await tester.pumpWidget(
        app(
          const VideoPlayerDialog(
            videoUrl: url,
            title: 'Respiratory health information',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip('Pause'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(
        app(
          InfographicViewer(
            imageUrl: 'https://example.test/image.jpg',
            title: 'Respiratory health information',
            caption: List.filled(20, 'Health guidance').join(' '),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Zoom in'));
      await tester.pump();
      final viewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      expect(viewer.transformationController!.value.getMaxScaleOnAxis(), 1.5);
      await tester.tap(find.byTooltip('Reset zoom'));
      await tester.pump();
      expect(viewer.transformationController!.value.getMaxScaleOnAxis(), 1);
      await cleanup(tester);
    });
  }

  testWidgets('infographic thumbnail opens in-app viewer', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: HealthArticleCard(
              contentType: 'infographic',
              mediaUrl: 'https://example.test/full.jpg',
              imageUrl: 'https://example.test/thumb.jpg',
              mediaContentType: 'image/jpeg',
              title: 'Infographic',
              source: 'HealthPH+',
              description: 'Caption',
              articleUrl: '',
              tags: [],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Image).first);
    await tester.pumpAndSettle();
    final viewer = tester.widget<InfographicViewer>(
      find.byType(InfographicViewer),
    );
    expect(viewer.imageUrl, 'https://example.test/full.jpg');
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(HealthArticleCard), findsOneWidget);
    await cleanup(tester);
  });
}
