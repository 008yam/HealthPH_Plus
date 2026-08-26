import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import 'package:healthphplus/main_page.dart';
import '../widgets/coach_mark.dart';
import '../services/healthph_api_services.dart';

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
      baseUrl: "http://127.0.0.1:8000",
    ).fetchHealthLiteracyContent();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(microseconds: 650), () {
        if (!mounted) return;

        CoachMark.showOnce(
          context,
          discoveryKey: "health_literacy_v2",
          steps: [
            CoachMarkStep(
              targetKey: literacyHeaderKey, //Coach Mark for Header
              title: "Health Literacy Hub",
              description:
                  "Read trusted respiratory health articles and fact-checking content here.",
              icon: Icons.article_outlined,
              color: AppTheme.success,
            ),
            CoachMarkStep(
              //Coach Mark for Search Bar
              targetKey: literacySearchKey,
              title: "Search Health Topics",
              description:
                  "Search Articles by topic, claim, disease, or keyword",
              icon: Icons.search,
              color: AppTheme.info,
            ),
            CoachMarkStep(
              targetKey: literacyTabsKey,
              title: "Articles and Fact Checks",
              description:
                  "Switch between health artilces and quick fact-checking cards",
              icon: Icons.tab,
              color: AppTheme.primary,
            ),
            CoachMarkStep(
              targetKey: literacyContentKey,
              title: "Learning Content",
              description:
                  "Tab an article card to open the full health resource",
              icon: Icons.search,
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

  String _joinList(dynamic value) {
    if (value is List) return value.join(" ");
    return "";
  }

  String _resolveMediaUrl(Map<String, dynamic> item) {
    String value = "";

    final media = item["media"];
    if (media is Map && media["url"] != null) {
      value = media["url"].toString();
    }

    if (value.isEmpty) {
      value = (item["mediaUrl"] ?? item["imageUrl"] ?? "").toString();
    }

    if (value.startsWith("/")) {
      return "http://127.0.0.1:8000$value";
    }

    return value;
  }

  String _resolveOpenUrl(Map<String, dynamic> item) {
    final externalUrl = (item["externalUrl"] ?? "").toString();
    if (externalUrl.isNotEmpty && externalUrl != "null") {
      return externalUrl;
    }

    return _resolveMediaUrl(item);
  }

  Widget _buildContentList(List<String> allowedTypes, String emptyMessage) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: healthLiteracyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              "Unable to load content.",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
              ),
            ),
          );
        }

        final items = snapshot.data ?? [];

        final filtered = items.where((item) {
          final type = item ["contentType"].toString().toLowerCase();

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
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final item = filtered[index];
            final type = item["contentType"].toString().toLowerCase();
            final mediaUrl = _resolveMediaUrl(item);

            return HealthArticleCard(
              contentType: type,
              mediaUrl: mediaUrl,
              title: (item["title"] ?? "Untitled content").toString(),
              source: (item["source"] ?? "HealthPH+").toString(),
              description: (item["description"] ?? "").toString(),
              articleUrl: _resolveOpenUrl(item),
              tags: List<String>.from(item["tags"] ?? []),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.pageBlue,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/Backdrop2.png',
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.15),
              ),
            ),
            Column(
              children: [
                // HEADER
                KeyedSubtree(
                  key: literacyHeaderKey,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(35),
                        bottomRight: Radius.circular(35),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
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

                            const SizedBox(height: 8),

                            Image.asset(
                              'assets/images/healthphplusbarlogo.png',
                              height: 55,
                            ),

                            const Text(
                              "Health Literacy Hub",
                              style: TextStyle(
                                fontSize: 21,
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

                            const SizedBox(height: 14),

                            // SEARCH BAR - NOW FUNCTIONAL
                            KeyedSubtree(
                              key: literacySearchKey,
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) {
                                  setState(() {
                                    searchQuery = value.toLowerCase().trim();
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText:
                                      "Search articles, topics, claims...",
                                  hintStyle: const TextStyle(fontSize: 11),
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    size: 22,
                                  ),
                                  suffixIcon: searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
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

                            const SizedBox(height: 10),

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
                        _buildContentList(["article", "articles"], "No articles found."),
                        _buildContentList(["video", "videos"], "No videos found."),
                        _buildContentList(
                          ["infographic", "infographics"],
                          "No infographics found.",
                        ),
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
  final String title;
  final String source;
  final String description;
  final String articleUrl;
  final List<String> tags;

  const HealthArticleCard({
    super.key,
    required this.contentType,
    required this.mediaUrl,
    required this.title,
    required this.source,
    required this.description,
    required this.articleUrl,
    required this.tags,
  });

  Future<void> _openArticle() async {
    final Uri url = Uri.parse(articleUrl);

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $articleUrl');
    }
  }

  Widget _buildMediaPreview() {
    final isVideo = contentType == "video" || contentType == "videos";
    final hasNetworkMedia = mediaUrl.startsWith("http");

    if (isVideo) {
      return Container(
        height: 230,
        width: double.infinity,
        color: const Color(0xFF1D2450),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.play_circle_fill,
              color: Colors.white,
              size: 62,
            ),
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Video",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (hasNetworkMedia) {
      return Image.network(
        mediaUrl,
        height: 230,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _,) {
          return Image.asset(
            "assets/images/lunghealtharticle.png",
            height: 230,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        },
      );
    }

    return Image.asset(
      "assets/images/lunghealtharticle.png",
      height: 230,
      width: double.infinity,
      fit: BoxFit.cover,
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
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    source,
                    style: const TextStyle(fontSize: 10, color: Colors.black87),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9, height: 1.3),
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
                        onPressed: _openArticle,
                        child: Text(
                          contentType == "video" || contentType == "videos"
                              ? "Watch video"
                              : contentType == "infographic" || contentType == "infograpihcs"
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
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
