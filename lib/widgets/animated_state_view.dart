import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

enum StateAnimationKind { empty, login }

class AnimatedStateView extends StatefulWidget {
  final StateAnimationKind animation;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? backgroundColor;

  const AnimatedStateView({
    super.key,
    required this.animation,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.backgroundColor,
  });

  @override
  State<AnimatedStateView> createState() => _AnimatedStateViewState();
}

class _AnimatedStateViewState extends State<AnimatedStateView> {
  late final VideoPlayerController _controller;
  late final Future<void> _initialization;

  String get _assetPath => widget.animation == StateAnimationKind.empty
      ? 'assets/animations/empty_box.mp4'
      : 'assets/animations/login_blue.mp4';

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(_assetPath);
    _initialization = _prepareAnimation();
  }

  Future<void> _prepareAnimation() async {
    await _controller.initialize();
    await _controller.setLooping(true);
    await _controller.setVolume(0);
    await _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : 360.0;

        return Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: availableHeight),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FutureBuilder<void>(
                      future: _initialization,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Icon(
                            widget.animation == StateAnimationKind.empty
                                ? Icons.inventory_2_outlined
                                : Icons.lock_person_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary,
                          );
                        }

                        if (snapshot.connectionState != ConnectionState.done) {
                          return const SizedBox(
                            height: 140,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        return SizedBox(
                          height: 140,
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (widget.message?.trim().isNotEmpty == true) ...[
                      const SizedBox(height: 6),
                      Text(widget.message!, textAlign: TextAlign.center),
                    ],
                    if (widget.onAction != null &&
                        widget.actionLabel != null) ...[
                      const SizedBox(height: 14),
                      FilledButton(
                        onPressed: widget.onAction,
                        child: Text(widget.actionLabel!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
