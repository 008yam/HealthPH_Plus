import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../localization/app_translations.dart';
import '../theme/app_theme.dart';

class LiteracyPreviewGroup extends ValueNotifier<Object?> {
  bool _disposed = false;
  LiteracyPreviewGroup() : super(null);
  void release(Object id) {
    if (!_disposed && value == id) value = null;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class ExpandableMediaCaption extends StatefulWidget {
  final String text;
  const ExpandableMediaCaption({super.key, required this.text});
  @override
  State<ExpandableMediaCaption> createState() => _ExpandableMediaCaptionState();
}

class _ExpandableMediaCaptionState extends State<ExpandableMediaCaption> {
  bool _expanded = false;
  @override
  void didUpdateWidget(covariant ExpandableMediaCaption oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) _expanded = false;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      const style = TextStyle(color: AppTheme.text, fontSize: 13, height: 1.4);
      final painter = TextPainter(
        text: TextSpan(text: widget.text, style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 3,
      )..layout(maxWidth: box.maxWidth);
      final overflows = painter.didExceedMaxLines;
      painter.dispose();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            style: style,
            maxLines: _expanded ? null : 3,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
          if (overflows)
            TextButton(
              onPressed: () => setState(() => _expanded = !_expanded),
              child: Text(context.tr(_expanded ? 'See less' : 'See more')),
            ),
        ],
      );
    },
  );
}

class InfographicViewer extends StatefulWidget {
  final String imageUrl, title, caption;
  const InfographicViewer({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.caption,
  });
  @override
  State<InfographicViewer> createState() => _InfographicViewerState();
}

class _InfographicViewerState extends State<InfographicViewer> {
  final _transform = TransformationController();
  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: AppTheme.lightTheme,
    child: Dialog.fullscreen(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.text,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: context.tr('Close'),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ColoredBox(
                      color: const Color(0xFFF0F2F5),
                      child: InteractiveViewer(
                        transformationController: _transform,
                        minScale: 1,
                        maxScale: 4,
                        child: SizedBox.expand(
                          child: Image.network(
                            widget.imageUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) =>
                                progress == null
                                ? child
                                : const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                            errorBuilder: (context, error, stack) => Center(
                              child: Text(context.tr('Unable to load image.')),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: context.tr('Zoom in'),
                            icon: const Icon(Icons.zoom_in),
                            onPressed: () {
                              final scale =
                                  (_transform.value.getMaxScaleOnAxis() * 1.5)
                                      .clamp(1.0, 4.0);
                              _transform.value = Matrix4.diagonal3Values(
                                scale,
                                scale,
                                1,
                              );
                            },
                          ),
                          IconButton(
                            tooltip: context.tr('Reset zoom'),
                            icon: const Icon(Icons.zoom_out_map),
                            onPressed: () =>
                                _transform.value = Matrix4.identity(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.caption.isNotEmpty)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * .25,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ExpandableMediaCaption(text: widget.caption),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

/// A page-scoped owner ensures only one muted preview plays at a time.
class LiteracyVideoPreview extends StatefulWidget {
  final String url, title;
  final Widget thumbnail;
  final LiteracyPreviewGroup? previewOwner;
  const LiteracyVideoPreview({
    super.key,
    required this.url,
    required this.title,
    required this.thumbnail,
    this.previewOwner,
  });
  @override
  State<LiteracyVideoPreview> createState() => _LiteracyVideoPreviewState();
}

class _LiteracyVideoPreviewState extends State<LiteracyVideoPreview>
    with WidgetsBindingObserver {
  final _id = Object();
  VideoPlayerController? _controller;
  TabController? _tabs;
  bool _visible = false,
      _hovered = false,
      _foreground = true,
      _modal = false,
      _failed = false;
  bool _routeActive = true, _reducedMotion = false;
  Timer? _delay;

  bool get _touch =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  bool get _eligible =>
      mounted &&
      _foreground &&
      _routeActive &&
      !_modal &&
      !_failed &&
      !_reducedMotion &&
      (_tabs == null || _tabs!.index == 1) &&
      !_tabsChanging &&
      _visible &&
      (_touch || _hovered) &&
      widget.url.isNotEmpty;
  bool get _tabsChanging => _tabs?.indexIsChanging ?? false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.previewOwner?.addListener(_sync);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tabs = DefaultTabController.maybeOf(context);
    if (_tabs != tabs) {
      _tabs?.removeListener(_sync);
      _tabs = tabs;
      _tabs?.addListener(_sync);
    }
    _routeActive = ModalRoute.of(context)?.isCurrent ?? true;
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _sync();
    });
  }

  @override
  void didUpdateWidget(covariant LiteracyVideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _stop();
      _failed = false;
    }
    if (oldWidget.previewOwner != widget.previewOwner) {
      oldWidget.previewOwner?.removeListener(_sync);
      widget.previewOwner?.addListener(_sync);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _sync();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _sync();
  }

  void _sync() {
    if (!mounted) return;
    final owner = widget.previewOwner;
    if (!_eligible || (owner?.value != null && owner!.value != _id)) {
      _stop();
      return;
    }
    if (_controller != null || _delay != null) return;
    _delay = Timer(const Duration(milliseconds: 400), () {
      _delay = null;
      if (!_eligible || (owner?.value != null && owner!.value != _id)) return;
      if (owner != null) owner.value = _id;
      unawaited(_start());
    });
  }

  Future<void> _start() async {
    if (_controller != null) return;
    final controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller = controller;
    try {
      await controller.initialize().timeout(const Duration(seconds: 20));
      if (!_eligible || _controller != controller) return;
      await controller.setVolume(0);
      await controller.setLooping(true);
      if (!_eligible || _controller != controller) return;
      await controller.play();
      if (mounted && _controller == controller) setState(() {});
    } catch (_) {
      if (mounted && _controller == controller) {
        _failed = true;
        _stop();
      }
    }
  }

  void _stop() {
    _delay?.cancel();
    _delay = null;
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      unawaited(controller.dispose().catchError((Object error) { debugPrint('Preview cleanup: $error'); }));
      if (mounted) setState(() {});
    }
    if (widget.previewOwner?.value == _id) widget.previewOwner!.value = null;
  }

  Future<void> _open() async {
    if (_modal) return;
    _modal = true;
    _stop();
    await showDialog<void>(
      context: context,
      builder: (_) =>
          VideoPlayerDialog(videoUrl: widget.url, title: widget.title),
    );
    if (!mounted) return;
    _modal = false;
    _sync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabs?.removeListener(_sync);
    widget.previewOwner?.removeListener(_sync);
    _delay?.cancel();
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      unawaited(controller.dispose().catchError((Object _) {}));
    }
    // Release after unmount so another card cannot rebuild during list teardown.
    final owner = widget.previewOwner;
    if (owner != null) scheduleMicrotask(() => owner.release(_id));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => VisibilityDetector(
    key: ObjectKey(_id),
    onVisibilityChanged: (info) {
      _visible = info.visibleFraction >= .75;
      _sync();
    },
    child: MouseRegion(
      onEnter: (_) {
        _hovered = true;
        _sync();
      },
      onExit: (_) {
        _hovered = false;
        _sync();
      },
      child: Semantics(
        button: true,
        label: '${context.tr('Watch video')}: ${widget.title}',
        child: Material(
          color: Colors.black,
          child: InkWell(
            onTap: widget.url.isEmpty ? null : _open,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  widget.thumbnail,
                  if (_controller?.value.isInitialized == true)
                    ColoredBox(
                      color: Colors.black,
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                    ),
                  const Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 52,
                    ),
                  ),
                  if (_controller?.value.isPlaying == true)
                    const Positioned(
                      right: 12,
                      bottom: 12,
                      child: Icon(Icons.volume_off, color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class VideoPlayerDialog extends StatefulWidget {
  final String videoUrl, title;
  const VideoPlayerDialog({
    super.key,
    required this.videoUrl,
    required this.title,
  });
  @override
  State<VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<VideoPlayerDialog>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _ready = false, _failed = false, _foreground = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_load());
  }

  Future<void> _load() async {
    final old = _controller;
    if (old != null) await old.dispose();
    if (!mounted) return;
    setState(() {
      _ready = false;
      _failed = false;
    });
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    _controller = controller;
    controller.addListener(() {
      if (mounted &&
          _controller == controller &&
          controller.value.hasError &&
          !_failed) {
        setState(() => _failed = true);
      }
    });
    try {
      await controller.initialize().timeout(const Duration(seconds: 20));
      if (!mounted || _controller != controller) return;
      setState(() => _ready = true);
      if (_foreground) await controller.play();
    } catch (_) {
      if (mounted && _controller == controller) setState(() => _failed = true);
    }
  }

  Future<void> _command(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (!_foreground && _controller != null) {
      unawaited(_command(_controller!.pause));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      unawaited(controller.dispose().catchError((Object _) {}));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: AppTheme.lightTheme,
    child: Dialog(
      insetPadding: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 800,
          maxHeight: MediaQuery.sizeOf(context).height * .85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: context.tr('Close'),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Flexible(
              child: _failed || (_controller?.value.hasError ?? false)
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(context.tr('Video is unavailable.')),
                          TextButton.icon(
                            onPressed: _load,
                            icon: const Icon(Icons.refresh),
                            label: Text(context.tr('Retry')),
                          ),
                        ],
                      ),
                    )
                  : !_ready
                  ? const SizedBox(
                      height: 180,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : ValueListenableBuilder<VideoPlayerValue>(
                      valueListenable: _controller!,
                      builder: (context, value, _) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: ColoredBox(
                              color: Colors.black,
                              child: Center(
                                heightFactor: 1,
                                child: AspectRatio(
                                  aspectRatio: value.aspectRatio,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      VideoPlayer(_controller!),
                                      if (value.isBuffering)
                                        const CircularProgressIndicator(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          VideoProgressIndicator(
                            _controller!,
                            allowScrubbing: true,
                            padding: const EdgeInsets.all(12),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                tooltip: context.tr(
                                  value.isPlaying ? 'Pause' : 'Play',
                                ),
                                icon: Icon(
                                  value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                ),
                                onPressed: () => _command(() async {
                                  if (!value.isPlaying &&
                                      value.position >= value.duration) {
                                    await _controller!.seekTo(Duration.zero);
                                  }
                                  await (value.isPlaying
                                      ? _controller!.pause()
                                      : _controller!.play());
                                }),
                              ),
                              IconButton(
                                tooltip: context.tr(
                                  value.volume == 0 ? 'Unmute' : 'Mute',
                                ),
                                icon: Icon(
                                  value.volume == 0
                                      ? Icons.volume_off
                                      : Icons.volume_up,
                                ),
                                onPressed: () => _command(
                                  () => _controller!.setVolume(
                                    value.volume == 0 ? 1 : 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}
