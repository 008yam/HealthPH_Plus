import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HealthLiteracyPage extends StatelessWidget {
  const HealthLiteracyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF3B4C98),
        body: Column(
          children: [
            // HEADER
            Container(
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
                          backgroundColor: const Color(0xFF31459B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
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

                      TextField(
                        decoration: InputDecoration(
                          hintText: "Search articles, topics, claims...",
                          hintStyle: const TextStyle(fontSize: 11),
                          prefixIcon: const Icon(Icons.search, size: 22),
                          filled: true,
                          fillColor: const Color(0xFFF4F4F4),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black26),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black26),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
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
                            Tab(text: "Health Articles"),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Fact Checker"),
                                  SizedBox(width: 6),
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.redAccent,
                                    child: Text(
                                      "3",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                    children: const [
                      HealthArticleCard(
                        imagePath: 'assets/images/lunghealtharticle.png',
                        title: "Lung Health in the Philippines - Latest Data",
                        source: "RMCI Medical Staff · August 5, 2025",
                        description:
                            "Lung health in the Philippines is a serious problem. Respiratory diseases are now ranking among the leading causes of death in the Philippines.",
                        articleUrl:
                            "https://www.rmci.com.ph/lung-health-in-the-philippines-latest-data/",
                        tags: ["community", "pneumonia", "tuberculosis"],
                      ),
                      HealthArticleCard(
                        imagePath: 'assets/images/COCarticle.png',
                        title:
                            "The Philippine College of Chest Physicians and Its Impact",
                        source: "Guinever Dy Agra · September 01, 2025",
                        description:
                            "A look at respiratory health programs and public education efforts.",
                        articleUrl:
                            "https://onlinelibrary.wiley.com/doi/full/10.1111/resp.70110",
                        tags: ["health", "community", "respiratory"],
                      ),
                      HealthArticleCard(
                        imagePath: 'assets/images/protectyourlungs.png',
                        title:
                            "Protect Your Lungs from Common Respiratory Issues",
                        source: "Doctor Anywhere Team · Community Health",
                        description:
                            "Learn how to prevent common respiratory issues and protect your lungs.",
                        articleUrl:
                            "https://www.doctoranywhere.ph/post/prevent-common-respiratory-issues",
                        tags: ["lungs", "prevention", "wellness"],
                      ),
                    ],
                  ),

                  ListView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                    children: const [
                      FactCheckCard(
                        claim: "Steam inhalation cures respiratory infections.",
                        result: "Needs Context",
                        explanation:
                            "Steam may relieve congestion, but it does not cure infections.",
                      ),
                      FactCheckCard(
                        claim:
                            "Wearing masks can help reduce exposure to air pollution.",
                        result: "Mostly True",
                        explanation:
                            "Proper masks can reduce exposure to airborne particles.",
                      ),
                      FactCheckCard(
                        claim: "Antibiotics cure all coughs.",
                        result: "False",
                        explanation:
                            "Many coughs are caused by viruses, where antibiotics are not effective.",
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

class HealthArticleCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String source;
  final String description;
  final String articleUrl;
  final List<String> tags;

  const HealthArticleCard({
    super.key,
    required this.imagePath,
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
            Image.asset(
              imagePath,
              height: 230,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

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
                        child: const Text(
                          "Read more",
                          style: TextStyle(fontSize: 11),
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
          //TOP ROW
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //ICON
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

              //CLAIM and Explanation
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

          //Verdict Bar
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
