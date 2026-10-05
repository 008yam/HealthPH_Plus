import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import 'package:healthphplus/main_page.dart';
import '../widgets/coach_mark.dart';
import '../services/healthph_api_services.dart';
import '../services/api_config.dart';
import '../theme/responsive.dart';

class HealthLiteracyPage extends StatefulWidget {
  const HealthLiteracyPage({super.key});

  @override
  State<HealthLiteracyPage> createState() => _HealthLiteracyPageState();
}

class _HealthLiteracyPageState extends State<HealthLiteracyPage> {
  final TextEditingController _searchController = TextEditingController();
  final literacyHeaderKey = GlobalKey();
  final literacySearchKey = GlobalKey();
  final literacyTabsKey = GlobalKey();
  final literacyContentKey = GlobalKey();

  late Future<List<Map<String, dynamic>>> healthLiteracyFuture;

  String searchQuery = "";

  @override
  void initState() {
    super.initState();

    healthLiteracyFuture = HealthPhApiService(
      baseUrl: ApiConfig.healthLiteracyBaseUrl,
    ).fetchHealthLiteracyContent();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 650), () {
        if (!mounted) return;

        CoachMark.showOnce(
          context,
          discoveryKey: "health_literacy_v3",
          steps: [
            CoachMarkStep(
              targetKey: literacyHeaderKey, //Coach Mark for Header
              title: "Health Literacy Hub",
              description:
                  "Browse published articles, videos, and infographics from trusted health sources.",
              icon: Icons.article_outlined,
              color: AppTheme.success,
            ),
            CoachMarkStep(
              //Coach Mark for Search Bar
              targetKey: literacySearchKey,
              title: "Search Health Topics",
              description:
                  "Filter the current tab by title, topic, source, disease, or keyword.",
              icon: Icons.search,
              color: AppTheme.info,
            ),
            CoachMarkStep(
              targetKey: literacyTabsKey,
              title: "Content Categories",
              description:
                  "Switch between articles, playable videos, and downloadable infographics.",
              icon: Icons.tab,
              color: AppTheme.primary,
            ),
            CoachMarkStep(
              targetKey: literacyContentKey,
              title: "Learning Content",
              description:
                  "Tap a card action to read an article, open a PDF, view an image, or play a video.",
              icon: Icons.touch_app_outlined,
              color: AppTheme.warning,
            ),
          ],
        );
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      searchQuery = "";
    });
  }

  Future<void> _refreshHealthLiteracy() async {
    final nextFuture = HealthPhApiService(
      baseUrl: ApiConfig.healthLiteracyBaseUrl,
    ).fetchHealthLiteracyContent();

    setState(() {
      healthLiteracyFuture = nextFuture;
    });

    try {
      await nextFuture;
    } catch (_) {
      // The FutureBuilder renders the error state and keeps Retry available.
    }
  }

  String _joinList(dynamic value) {
    if (value is List) return value.join(" ");
    return "";
  }

  String _resolveUrl(dynamic rawValue) {
    final value = rawValue?.toString().trim() ?? "";
    if (value.isEmpty || value == "null") return "";
    if (value.startsWith("/")) {
      return "${ApiConfig.healthLiteracyBaseUrl}$value";
    }
    return value;
  }

  String _resolveMediaUrl(Map<String, dynamic> item) {
    final media = item["media"];
    final nestedUrl = media is Map ? media["url"] : null;
    final resolvedNestedUrl = _resolveUrl(nestedUrl);
    return resolvedNestedUrl.isNotEmpty
        ? resolvedNestedUrl
        : _resolveUrl(item["mediaUrl"]);
  }

  String _resolveImageUrl(Map<String, dynamic> item) {
    final directImageUrl = _resolveUrl(item["imageUrl"]);
    if (directImageUrl.isNotEmpty) return directImageUrl;

    final media = item["media"];
    final mediaType = media is Map
        ? (media["contentType"] ?? "").toString().toLowerCase()
        : "";
    return mediaType.startsWith("image/")
        ? _resolveUrl(media is Map ? media["url"] : null)
        : "";
  }

  String _resolveMediaContentType(Map<String, dynamic> item) {
    final media = item["media"];
    return media is Map
        ? (media["contentType"] ?? "").toString().toLowerCase()
        : "";
  }

  String _resolveOpenUrl(Map<String, dynamic> item) {
    final externalUrl = (item["externalUrl"] ?? "").toString();
    if (externalUrl.isNotEmpty && externalUrl != "null") {
      return externalUrl;
    }

    final mediaUrl = _resolveMediaUrl(item);
    if (mediaUrl.isNotEmpty) return mediaUrl;
    return _resolveImageUrl(item);
  }

  Widget _buildContentList(List<String> allowedTypes, String emptyMessage) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: healthLiteracyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Unable to load content.",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _refreshHealthLiteracy,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        final items = snapshot.data ?? [];

        final filtered = items.where((item) {
          final type = item["contentType"].toString().toLowerCase();

          final searchableText = [
            item["title"],
            item["description"],
            item["source"],
            item["author"],
            _joinList(item["tags"]),
            _joinList(item["topics"]),
            _joinList(item["diseases"]),
          ].join(" ").toLowerCase();

          return allowedTypes.contains(type) &&
              (searchQuery.isEmpty || searchableText.contains(searchQuery));
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Text(
              emptyMessage,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshHealthLiteracy,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final item = filtered[index];
              final type = item["contentType"].toString().toLowerCase();
              final mediaUrl = _resolveMediaUrl(item);

              return HealthArticleCard(
                contentType: type,
                mediaUrl: mediaUrl,
                imageUrl: _resolveImageUrl(item),
                mediaContentType: _resolveMediaContentType(item),
                title: (item["title"] ?? "Untitled content").toString(),
                source: (item["source"] ?? "HealthPH+").toString(),
                description: (item["description"] ?? "").toString(),
                articleUrl: _resolveOpenUrl(item),
                tags: List<String>.from(item["tags"] ?? []),
              );
            },
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final pagePadding = Responsive.pagePadding(context);
    final headerRadius = Responsive.isLandscapePhone(context) ? 24.0 : 35.0;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Column(
              children: [
                // HEADER
                KeyedSubtree(
                  key: literacyHeaderKey,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(headerRadius),
                        bottomRight: Radius.circular(headerRadius),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          pagePadding,
                          10,
                          pagePadding,
                          Responsive.verticalGap(context, 22, compact: 12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              onPressed: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MainPage(),
                                    ),
                                  );
                                }
                              },
                              child: const Text("Back"),
                            ),

                            SizedBox(
                              height: Responsive.verticalGap(context, 8),
                            ),

                            Image.asset(
                              'assets/images/healthphplusbarlogo.png',
                              height: Responsive.logoHeight(context),
                            ),

                            Text(
                              "Health Literacy Hub",
                              style: TextStyle(
                                fontSize: Responsive.isLandscapePhone(context)
                                    ? 19
                                    : 21,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF243B8F),
                              ),
                            ),

                            const Text(
                              "Evidence-based health information and fact-checking",
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF243B8F),
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            SizedBox(
                              height: Responsive.verticalGap(
                                context,
                                14,
                                compact: 8,
                              ),
                            ),

                            // SEARCH BAR - NOW FUNCTIONAL
                            KeyedSubtree(
                              key: literacySearchKey,
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(color: AppTheme.text),
                                cursorColor: AppTheme.primary,
                                onChanged: (value) {
                                  setState(() {
                                    searchQuery = value.toLowerCase().trim();
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText:
                                      "Search articles, topics, claims...",
                                  hintStyle: const TextStyle(
                                    color: AppTheme.mutedText,
                                    fontSize: 11,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: AppTheme.mutedText,
                                    size: 22,
                                  ),
                                  suffixIcon: searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.clear,
                                            color: AppTheme.mutedText,
                                          ),
                                          onPressed: _clearSearch,
                                        )
                                      : null,
                                  filled: true,
                                  fillColor: const Color(0xFFF4F4F4),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.black26,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.black26,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              height: Responsive.verticalGap(
                                context,
                                10,
                                compact: 6,
                              ),
                            ),

                            KeyedSubtree(
                              key: literacyTabsKey,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const TabBar(
                                  labelColor: Colors.black,
                                  unselectedLabelColor: Colors.grey,
                                  indicator: BoxDecoration(
                                    color: Color(0xFFF2F2F2),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Color(0xFF31459B),
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                  tabs: [
                                    Tab(text: "Articles"),
                                    Tab(text: "Videos"),
                                    Tab(text: "Infographics"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: KeyedSubtree(
                    key: literacyContentKey,
                    child: TabBarView(
                      children: [
                        _buildContentList([
                          "article",
                          "articles",
                          "fact_check",
                        ], "No articles found."),
                        _buildContentList([
                          "video",
                          "videos",
                        ], "No videos found."),
                        _buildContentList([
                          "infographic",
                          "infographics",
                        ], "No infographics found."),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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

  const HealthArticleCard({
    super.key,
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

  Future<void> _openContent(BuildContext context) async {
    if (_isVideo) {
      if (mediaUrl.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Video is unavailable.")));
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

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $articleUrl");
    }
  }

  Widget _buildMediaPreview() {
  Widget buildFallback() {
    return Image.asset(
      "assets/images/lunghealtharticle.png",
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

  if (!_isVideo) {
    return thumbnail;
  }

  return SizedBox(
    height: 230,
    width: double.infinity,
    child: Stack(
      fit: StackFit.expand,
      children: [
        thumbnail,
        Container(
          color: Colors.black.withValues(alpha: 0.22),
        ),
        const Center(
          child: Icon(
            Icons.play_circle_fill,
            color: Colors.white,
            size: 62,
          ),
        ),
        Positioned(
          left: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.70),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Video",
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
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
            _buildMediaPreview(),
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
                          _isVideo
                              ? "Watch video"
                              : _isPdf
                              ? "Open PDF"
                              : contentType == "infographic" ||
                                    contentType == "infographics"
                              ? "View"
                              : "Read more",
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

class VideoPlayerDialog extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoPlayerDialog({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<VideoPlayerDialog> {
  late final VideoPlayerController _controller;
  late final Future<void> _initializeVideoFuture;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    _initializeVideoFuture = _controller.initialize().then((_) {
      if (!mounted) return;
      _controller.play();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: AppTheme.primary,
              padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            FutureBuilder<void>(
              future: _initializeVideoFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SizedBox(
                    height: 260,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Center(
                        child: Text(
                          "Unable to play video.\n\nURL:\n${widget.videoUrl}\n\nError:\n${snapshot.error}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState != ConnectionState.done) {
                  return const SizedBox(
                    height: 220,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final aspectRatio = _controller.value.aspectRatio == 0
                    ? 16 / 9
                    : _controller.value.aspectRatio;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                        IconButton(
                          onPressed: _togglePlayback,
                          iconSize: 64,
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FactCheckCard extends StatelessWidget {
  final String claim;
  final String result;
  final String explanation;

  const FactCheckCard({
    super.key,
    required this.claim,
    required this.result,
    required this.explanation,
  });

  Color getResultColor() {
    switch (result.toLowerCase()) {
      case "false":
        return Colors.redAccent;
      case "mostly true":
        return Colors.green;
      case "needs context":
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  IconData getResultIcon() {
    switch (result.toLowerCase()) {
      case "false":
        return Icons.cancel;
      case "mostly true":
        return Icons.verified;
      case "needs context":
        return Icons.info;
      default:
        return Icons.fact_check;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color resultColor = getResultColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: resultColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(getResultIcon(), color: resultColor, size: 24),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      claim,
                      style: const TextStyle(
                        color: AppTheme.text,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      explanation,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: resultColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: resultColor.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                Icon(getResultIcon(), color: resultColor, size: 18),

                const SizedBox(width: 8),

                const Text(
                  "Verdict:",
                  style: TextStyle(
                    color: AppTheme.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(width: 6),

                Text(
                  result,
                  style: TextStyle(
                    color: resultColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
