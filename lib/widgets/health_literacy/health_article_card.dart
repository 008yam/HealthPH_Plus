import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../localization/app_translations.dart';
import '../../theme/app_theme.dart';
import '../literacy_media.dart';

class HealthArticleCard extends StatelessWidget {
  final String contentType;
  final String mediaUrl;
  final String imageUrl;
  final String mediaContentType;
  final String title;
  final String source;
  final String description;
  final String articleUrl;
  final List<String> tags;
  final LiteracyPreviewGroup? previewOwner;

  const HealthArticleCard({
    super.key,
    this.previewOwner,
    required this.contentType,
    required this.mediaUrl,
    required this.imageUrl,
    required this.mediaContentType,
    required this.title,
    required this.source,
    required this.description,
    required this.articleUrl,
    required this.tags,
  });

  bool get _isVideo =>
      mediaContentType.startsWith("video/") ||
      (mediaContentType.isEmpty &&
          (contentType == "video" || contentType == "videos"));

  bool get _isPdf => mediaContentType == "application/pdf";
  bool get _isInfographic =>
      contentType == 'infographic' || contentType == 'infographics';

  Future<void> _openContent(BuildContext context) async {
    if (_isInfographic && !_isPdf && imageUrl.isNotEmpty) {
      await showDialog<void>(
        context: context,
        builder: (_) => InfographicViewer(
          imageUrl: mediaContentType.startsWith('image/') && mediaUrl.isNotEmpty
              ? mediaUrl
              : imageUrl,
          title: title,
          caption: description,
        ),
      );
      return;
    }
    if (_isVideo) {
      if (mediaUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr("Video is unavailable."))),
        );
        return;
      }

      await showDialog(
        context: context,
        builder: (_) {
          return VideoPlayerDialog(videoUrl: mediaUrl, title: title);
        },
      );
      return;
    }

    if (articleUrl.isEmpty || articleUrl == "null") {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        showDragHandle: true,
        builder: (sheetContext) {
          return Theme(
            data: AppTheme.lightTheme,
            child: SafeArea(
              child: DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.82,
                minChildSize: 0.50,
                maxChildSize: 0.95,
                builder: (context, scrollController) {
                  return SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppTheme.text,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          source,
                          style: const TextStyle(
                            color: AppTheme.mutedText,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          description,
                          style: const TextStyle(
                            color: AppTheme.text,
                            fontSize: 15,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
      return;
    }

    final Uri url = Uri.parse(articleUrl);

    try {
      if (await launchUrl(url, mode: LaunchMode.externalApplication)) return;
    } catch (_) {
      // Leave the card available when the device cannot open the external link.
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Unable to open content.'))),
      );
    }
  }

  Widget _buildMediaPreview(BuildContext context) {
    Widget buildFallback() {
      return Image.asset(
        'assets/images/Health Literacy Picture Thumbnaik.jpeg',
        height: 230,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    Widget buildThumbnail() {
      if (imageUrl.isEmpty) {
        return buildFallback();
      }

      return Image.network(
        imageUrl,
        height: 230,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return const SizedBox(
            height: 230,
            child: Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (_, _, _) => buildFallback(),
      );
    }

    final thumbnail = buildThumbnail();

    if (_isVideo) {
      return LiteracyVideoPreview(
        url: mediaUrl,
        title: title,
        thumbnail: thumbnail,
        previewOwner: previewOwner,
      );
    }

    return Semantics(
      button: true,
      label: '${context.tr('View')}: $title',
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: () => _openContent(context), child: thumbnail),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMediaPreview(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.text,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    source,
                    style: const TextStyle(
                      color: AppTheme.mutedText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (_isInfographic)
                    ExpandableMediaCaption(text: description)
                  else
                    Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.text,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 5,
                          runSpacing: 4,
                          children: tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(width: 8),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6DA7F2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: () => _openContent(context),
                        child: Text(
                          context.tr(
                            _isVideo
                                ? "Watch video"
                                : _isPdf
                                ? "Open PDF"
                                : contentType == "infographic" ||
                                      contentType == "infographics"
                                ? "View"
                                : "Read more",
                          ),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
