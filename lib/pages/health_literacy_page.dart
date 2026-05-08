import 'package:flutter/material.dart';


class HealthLiteracyPage extends StatelessWidget {
  const HealthLiteracyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        body: SafeArea(
          child: Column(
            children: [
              // TOP BACK BUTTON
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Back"),
                  ),
                ),
              ),

              // HEALTHPH+ LOGO BUTTON
              Transform.translate(
                offset: const Offset(-35, 0,),
                child: Image.asset(
                  'assets/images/healthphplusbarlogo.png',
                  height: 60,
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Health Literacy Hub",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Evidence-based health information and fact-checking",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // SEARCH BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search articles, topics, claims...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // TABS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const TabBar(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.indigo,
                    tabs: [
                      Tab(text: "Health Articles"),
                      Tab(text: "Fact Checker"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // TAB CONTENT
              Expanded(
                child: TabBarView(
                  children: [
                    // HEALTH ARTICLES TAB
                    ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: const [
                        HealthArticleCard( //LungHeath article
                          imagePath: 'assets/images/lunghealtharticle.png',
                          title: "Lung Health in the Philippines - Latest Data",
                          source: "RMC Medical Staff · August 5, 2025",
                          description:
                              "Learn about lung health, respiratory diseases, and ways to protect your lungs.",
                        ),
                        HealthArticleCard( //College of Chest Article
                          imagePath: 'assets/images/COCarticle.png',
                          title:
                              "The Philippine College of Chest Physicians and Its Impact",
                          source: "Guinever Dy Agra+ · Septembr 01, 2025",
                          description:
                              "A look at respiratory health programs and public education efforts.",
                        ),
                        HealthArticleCard( // Protect Your Lungs Article
                          imagePath: 'assets/images/protectyourlungs.png',
                          title:
                              "The lungs play a vital role in our overall well-being, responsible for bringing oxygen into our bodies and expelling carbon dioxide",
                          source: "Doctor Anywhere Team · Community Health",
                          description:
                              "Showcasing and informing the importance the Lungs",
                        ),
                      ],
                    ),

                    // FACT CHECKER TAB
                    ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: const [
                        FactCheckCard(
                          claim: "Steam inhalation cures respiratory infections.",
                          result: "Needs Context",
                          explanation:
                              "Steam may relieve congestion, but it does not cure infections.",
                        ),
                        FactCheckCard(
                          claim: "Wearing masks can help reduce exposure to air pollution.",
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
      ),
    );
  }
}

class HealthArticleCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String source;
  final String description;

  const HealthArticleCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.source,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.black26),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            imagePath,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  source,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),

                const SizedBox(height: 8),

                Text(
                  description,
                  style: const TextStyle(fontSize: 12),
                ),

                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text("Read more"),
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Colors.black26),
      ),
      child: ListTile(
        leading: const Icon(Icons.fact_check, color: Colors.indigo),
        title: Text(
          claim,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(explanation),
        trailing: Text(
          result,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}