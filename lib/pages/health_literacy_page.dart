import '../localization/app_translations.dart';
import 'package:flutter/material.dart';
import '../widgets/literacy_media.dart';
import '../theme/app_theme.dart';
import 'package:healthphplus/main_page.dart';
import '../widgets/coach_mark.dart';
import '../services/healthph_api_services.dart';
import '../services/api_config.dart';
import '../theme/responsive.dart';
import '../widgets/animated_state_view.dart';
import '../services/health_literacy_content_resolver.dart';
import '../widgets/health_literacy/health_article_card.dart';

class HealthLiteracyPage extends StatefulWidget {
  const HealthLiteracyPage({super.key});

  @override
  State<HealthLiteracyPage> createState() => _HealthLiteracyPageState();
}

class _HealthLiteracyPageState extends State<HealthLiteracyPage> {
  final TextEditingController _searchController = TextEditingController();
  final LiteracyPreviewGroup _previewOwner = LiteracyPreviewGroup();
  final HealthLiteracyContentResolver _contentResolver =
      HealthLiteracyContentResolver(baseUrl: ApiConfig.healthLiteracyBaseUrl);
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
    _previewOwner.dispose();
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

  Widget _buildContentList(List<String> allowedTypes, String emptyMessage) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: healthLiteracyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return AnimatedStateView(
            animation: StateAnimationKind.empty,
            title: context.tr('Unable to load content.'),
            actionLabel: context.tr('Retry'),
            onAction: _refreshHealthLiteracy,
            backgroundColor: Colors.white,
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
            _contentResolver.joinList(item["tags"]),
            _contentResolver.joinList(item["topics"]),
            _contentResolver.joinList(item["diseases"]),
          ].join(" ").toLowerCase();

          return allowedTypes.contains(type) &&
              (searchQuery.isEmpty || searchableText.contains(searchQuery));
        }).toList();

        if (filtered.isEmpty) {
          return AnimatedStateView(
            animation: StateAnimationKind.empty,
            title: context.tr(emptyMessage),
            backgroundColor: Colors.white,
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
              final mediaUrl = _contentResolver.mediaUrl(item);

              return HealthArticleCard(
                key: ValueKey(item['id'] ?? '$type:$mediaUrl:${item['title']}'),
                previewOwner: _previewOwner,
                contentType: type,
                mediaUrl: mediaUrl,
                imageUrl: _contentResolver.thumbnailUrl(item),
                mediaContentType: _contentResolver.mediaContentType(item),
                title: (item["title"] ?? "Untitled content").toString(),
                source: (item["source"] ?? "HealthPH+").toString(),
                description: (item["description"] ?? "").toString(),
                articleUrl: _contentResolver.openUrl(item),
                tags: List<String>.from(item["tags"] ?? []),
              );
            },
          ),
        );
      },
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
                              child: Text(context.tr("Back")),
                            ),

                            SizedBox(
                              height: Responsive.verticalGap(context, 8),
                            ),

                            Image.asset(
                              'assets/images/healthphplusbarlogo.png',
                              height: Responsive.logoHeight(context),
                            ),

                            Text(
                              context.tr("Health Literacy Hub"),
                              style: TextStyle(
                                fontSize: Responsive.isLandscapePhone(context)
                                    ? 19
                                    : 21,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF243B8F),
                              ),
                            ),

                            Text(
                              context.tr(
                                "Evidence-based health information and fact-checking",
                              ),
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
                                  hintText: context.tr(
                                    "Search articles, topics, claims...",
                                  ),
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
                                child: TabBar(
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
                                    Tab(text: context.tr("Articles")),
                                    Tab(text: context.tr("Videos")),
                                    Tab(text: context.tr("Infographics")),
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
