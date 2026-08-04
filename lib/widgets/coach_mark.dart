import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CoachMarkStep {
  final GlobalKey targetKey;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const CoachMarkStep({
    required this.targetKey,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class CoachMark {
  static Future<void> show(
    BuildContext context, {
      required List<CoachMarkStep> steps,
      VoidCallback? onFinished,
    }) async {
      if (steps.isEmpty || !context.mounted) return;

      var currentIndex = 0;
      late OverlayEntry entry;
      var isClosed = false;

      await _scrollToTarget(steps[currentIndex].targetKey);

      if(!context.mounted) return;

      void close() {
        if (isClosed) return;
        isClosed = true;
        entry.remove();
        onFinished?.call();
      }

      Future<void> next() async {
        if (currentIndex == steps.length - 1) {
          close();
          return;
        } 

        currentIndex++;
        await _scrollToTarget(steps[currentIndex].targetKey);

        if(isClosed) return;
        entry.markNeedsBuild();
      }

      entry = OverlayEntry(
        builder: (context) {
          final step = steps[currentIndex];
          final targetRect = _targetRect(step.targetKey);

          return _CoachMarkOverlay(
            step: step,
            targetRect: targetRect,
            currentStep: currentIndex + 1,
            totalSteps: steps.length,
            onNext: next,
            onSkip: close,
          );
        },
      );

      Overlay.of(context).insert(entry);
    }

    static Future<void> showOnce(
      BuildContext context, {
        required String discoveryKey,
        required List<CoachMarkStep> steps,
      }) async {
        final prefs = await SharedPreferences.getInstance();
        final storageKey = "coach_mark_seen_$discoveryKey";
        final hasSeen = prefs.getBool(storageKey) ?? false;

        if (hasSeen || !context.mounted) return;

        show(context,
        steps: steps,
        onFinished: () {
          prefs.setBool(storageKey, true);
        },
      );
    }

    static Future<void> _scrollToTarget(GlobalKey key) async {
      final targetContext = key.currentContext;
      if (targetContext == null) return;

      await Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
        alignment: 0.22,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      );

      await Future<void>.delayed(const Duration(microseconds: 80));
    }

    static Rect? _targetRect(GlobalKey key) {
      final renderObject = key.currentContext?.findRenderObject();

      if (renderObject is! RenderBox || !renderObject.hasSize) {
        return null;
      }

      final offset = renderObject.localToGlobal(Offset.zero);
      return offset & renderObject.size;
    }
}

class _CoachMarkOverlay extends StatelessWidget {
  final CoachMarkStep step;
  final Rect? targetRect;
  final int currentStep;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _CoachMarkOverlay({
    required this.step,
    required this.targetRect,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final highlightedRect = targetRect?.inflate(8);

    final rawTop = highlightedRect == null
        ? size.height * 0.36
        : highlightedRect.bottom + 14;

    final cardTop = rawTop > size.height - 230
        ? ((highlightedRect?.top ?? 260) - 210)
            .clamp(72.0, size.height - 230.0)
            .toDouble()
        : rawTop.clamp(72.0, size.height - 230.0).toDouble();

    final cardWidth = size.width > 430 ? 360.0 : size.width - 32;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onNext,
              child: Container(
                color: Colors.black.withValues(alpha: 0.56),
              ),
            ),
          ),

          if (highlightedRect != null)
            Positioned(
              left: highlightedRect.left,
              top: highlightedRect.top,
              width: highlightedRect.width,
              height: highlightedRect.height,
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: step.color, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: step.color.withValues(alpha: 0.45),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          Positioned(
            top: cardTop,
            left: (size.width - cardWidth) / 2,
            width: cardWidth,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.92, end: 1),
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: step.color.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: step.color.withValues(alpha: 0.14),
                          child: Icon(step.icon, color: step.color),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            step.title,
                            style: const TextStyle(
                              color: AppTheme.text,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          "$currentStep/$totalSteps",
                          style: const TextStyle(
                            color: AppTheme.mutedText,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      step.description,
                      style: const TextStyle(
                        color: AppTheme.mutedText,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        TextButton(
                          onPressed: onSkip,
                          child: const Text("Skip"),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: step.color,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            currentStep == totalSteps ? "Done" : "Next",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}