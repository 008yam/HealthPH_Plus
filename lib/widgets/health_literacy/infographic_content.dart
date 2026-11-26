import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../theme/app_theme.dart';

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
