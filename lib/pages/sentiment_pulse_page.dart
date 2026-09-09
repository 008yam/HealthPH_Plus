import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:healthphplus/main_page.dart';
import '../theme/responsive.dart';
import '../models/mobile_survey.dart';
import '../services/api_config.dart';
import '../services/profile_store.dart';
import '../services/sentiment_survey_service.dart';


class SentimentPulsePage extends StatelessWidget {
  final int initialTabIndex;

  const SentimentPulsePage({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final safeInitialIndex = initialTabIndex.clamp(0, 3).toInt();
    return DefaultTabController(
      length: 4,
      initialIndex: safeInitialIndex,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Column(
              children: [
                // HEADER
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(45),
                      bottomRight: Radius.circular(45),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton(
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
                          const SizedBox(height: 10),

                          Image.asset(
                            'assets/images/healthphplusbarlogo.png',
                            height: 55,
                          ),

                          const Text(
                            "Sentiment Pulse",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),

                          const Text(
                            "Evidence-based health infomration and fact-checking",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppTheme.border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const TabBar(
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Colors.indigo,
                            tabs: [
                              Tab(text: "Overview"),
                              Tab(text: "Trends"),
                              Tab(text: "Regional"),
                              Tab(text: "Survey")
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        Expanded(
                          child: TabBarView(
                            children: [
                              OverviewTab(),
                              TrendsTab(),
                              RegionalTab(),
                              SurveyTab(),
                            ],
                          ),
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

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: const [
        Text(
          "Overall Sentiment",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 12),

        Row(
          children: [
            SentimentBox(
              percent: "25%", //"${count['AURI']}%",
              label: "Concerned",
              icon: Icons.sentiment_dissatisfied,
              color: Color(0xFFFFD98A),
            ),

            SizedBox(width: 8),

            SentimentBox(
              percent: "14%", //"${count['PN']}%",
              label: "Misinformed",
              icon: Icons.warning_amber_rounded,
              color: Color(0xFFFFB3B3),
            ),
          ],
        ),

        SizedBox(height: 8),

        Row(
          children: [
            SentimentBox(
              percent: "12%", //"${count['TB']}%",
              label: "Neutral",
              icon: Icons.sentiment_neutral,
              color: Color(0xFFBBD7FF),
            ),
            SizedBox(width: 8),
            SentimentBox(
              percent: "24", //"${count['COVID']}%",
              label: "Proactive",
              icon: Icons.sentiment_satisfied_alt,
              color: Color(0xFFBDF2CD),
            ),
          ],
        ),

        SizedBox(height: 16),

        BarGraphCard(),
      ],
    );
  }
}

class TrendsTab extends StatelessWidget {
  const TrendsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: const [
        Text(
          "Sentiment Trends",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        Text("Sentiment changes over time", style: TextStyle(fontSize: 12)),

        SizedBox(height: 12),

        TrendLineCard(),

        SizedBox(height: 16),

        Text(
          "Trends Insights",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 8),

        Row(
          children: [
            InsightCard(
              title: "Concerned",
              value: "+6%",
              description: 'Increase from last week',
              color: Color(0xFFFFE082),
            ),
            SizedBox(width: 8),
            InsightCard(
              title: "Proactive",
              value: "+6%",
              description: "Increase from last week",
              color: Color(0xFFC8E6C9),
            ),
          ],
        ),

        SizedBox(height: 16),

        Text(
          "Region Trend Changes",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 8),

        RegionMiniCard(region: "NCR", sentiment: "Concerned", change: "+6%"),
        RegionMiniCard(
          region: "Region III",
          sentiment: "Neutral",
          change: "+9%",
        ),
        RegionMiniCard(
          region: "Region V",
          sentiment: "Misinformed",
          change: "+6%",
        ),
      ],
    );
  }
}

class RegionalTab extends StatelessWidget {
  const RegionalTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: const [
        Text(
          "Regional Sentiment",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        Text("Dominant sentiment by region", style: TextStyle(fontSize: 12)),

        SizedBox(height: 12),

        RegionalSentimentCard(
          region: "NCR",
          sentiment: "Concerned",
          percent: 45,
          color: Colors.amber,
        ),

        RegionalSentimentCard(
          region: "Region III",
          sentiment: 'Neutral',
          percent: 38,
          color: Colors.green,
        ),

        RegionalSentimentCard(
          region: "Region IV-A",
          sentiment: "Proactive",
          percent: 38,
          color: Colors.blue,
        ),

        RegionalSentimentCard(
          region: "Region VII",
          sentiment: "Concerned",
          percent: 48,
          color: Colors.amber,
        ),
      ],
    );
  }
}

class SurveyTab extends StatefulWidget {
  const SurveyTab({super.key});

  @override
  State<SurveyTab> createState() => _SurveyTabState();
}

class _SurveyTabState extends State<SurveyTab>{
  late Future<List<MobileSurvey>> surveyFuture;

  final surveyService = SentimentSurveyService(
    baseUrl: ApiConfig.baseUrl
  );

  @override
  void initState() {
    super.initState();
    surveyFuture = surveyService.fetchPublicSurveys();
  }

  void _refreshSurveys() {
    setState(() {
      surveyFuture = surveyService.fetchPublicSurveys();
    });
  }

  void _openSurvey(MobileSurvey survey) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return SurveyResponseSheet(
          survey: survey,
          surveyService: surveyService,
          onSubmitted: _refreshSurveys,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MobileSurvey>>(
      future: surveyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Unable to load surveys.",
              style: TextStyle(
                color: AppTheme.text,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        final surveys = snapshot.data ?? [];

        if (surveys.isEmpty) {
          return const Center(
            child: Text(
              "No active mobile surveys currently available.",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: surveys.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final survey = surveys[index];
            final progress = survey.target <= 0
                ? 0.0
                : (survey.responses / survey.target).clamp(0.0, 1.0);

            return InkWell(
              onTap: () => _openSurvey(survey),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      survey.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    if (survey.subtitle.isNotEmpty) ... [
                      const SizedBox(height: 4),
                      Text(
                        survey.subtitle,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 10),
                    LinearProgressIndicator(value: progress),
                    const SizedBox(height: 6),
                    Text(
                      "${survey.responses} / ${survey.target} responses",
                      style: const TextStyle(fontSize: 11),
                     ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class SurveyResponseSheet extends StatefulWidget {
  final MobileSurvey survey;
  final SentimentSurveyService surveyService;
  final VoidCallback onSubmitted;

  const SurveyResponseSheet({
    super.key,
    required this.survey,
    required this.surveyService,
    required this.onSubmitted,
  });

  @override
  State<SurveyResponseSheet> createState() => _SurveyResponseSheetState();
}

class _SurveyResponseSheetState extends State<SurveyResponseSheet> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> answers = {};
  bool isSubmitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cleanedAnswers = Map<String, dynamic>.from(answers)
      ..removeWhere((_, value) => value == null || value.toString().trim().isEmpty);

    if (cleanedAnswers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please answer at least one question.")),
      );
      return;
    }

    final profile = ProfileStore.instance.profile;

    final userLocation = <String, dynamic>{
      "regionCode": profile?.regionCode,
      "regionLabel": profile?.regionLabel,
      "province": profile?.province,
      "city": profile?.city,
      "barangay": profile?.barangay,
    }..removeWhere((_, value) => value == null || value == "");

    final metadata = <String, dynamic>{
      "roleId": profile?.roleId,
    }..removeWhere((_, value) => value == null || value == "");

    setState(() => isSubmitting = true);

    try {
      await widget.surveyService.submitSurveyResponse(
        surveyId: widget.survey.id,
        answers: cleanedAnswers,
        region: profile?.regionLabel,
        userId: profile?.id,
        userLocation: userLocation,
        metadata: metadata,
      );

      if (!mounted) return;
      Navigator.pop(context);
      widget.onSubmitted();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Survey response submitted.")),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to submit survey response.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          18,
          16,
          18,
          MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.survey.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              if (widget.survey.subtitle.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(widget.survey.subtitle),
              ],
              const SizedBox(height: 16),
              ...List.generate(widget.survey.questions.length, (index) {
                return _QuestionCard(
                  number: index + 1,
                  question: widget.survey.questions[index],
                  answers: answers,
                  isSubmitting: isSubmitting,
                  onChanged: () => setState(() {}),
                );
              }),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: isSubmitting ? null : _submit,
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(isSubmitting ? "Submitting..." : "Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int number;
  final MobileSurveyQuestion question;
  final Map<String, dynamic> answers;
  final bool isSubmitting;
  final VoidCallback onChanged;

  const _QuestionCard({
    required this.number,
    required this.question,
    required this.answers,
    required this.isSubmitting,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final answer = answers[question.id];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$number. ${question.title}${question.isRequired ? " *" : ""}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: 10),
          _buildQuestionInput(answer),
        ],
      ),
    );
  }

  Widget _buildQuestionInput(dynamic answer) {
    switch (question.type) {
      case "multipleChoice":
        return Column(
          children: question.choices.map((choice) {
            return RadioListTile<String>(
              value: choice,
              groupValue: answer?.toString(),
              onChanged: isSubmitting
                  ? null
                  : (value) {
                      answers[question.id] = value;
                      onChanged();
                    },
              title: Text(choice),
              dense: true,
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        );

      case "rating":
        final min = question.rateMin;
        final max = question.rateMax;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(max - min + 1, (index) {
            final value = min + index;
            final isSelected = answer == value;

            return ChoiceChip(
              label: Text("$value"),
              selected: isSelected,
              onSelected: isSubmitting
                  ? null
                  : (_) {
                      answers[question.id] = value;
                      onChanged();
                    },
            );
          }),
        );

      case "text":
      default:
        return TextFormField(
          enabled: !isSubmitting,
          minLines: 2,
          maxLines: 4,
          initialValue: answer?.toString(),
          decoration: const InputDecoration(
            hintText: "Type your answer",
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (question.isRequired && (value == null || value.trim().isEmpty)) {
              return "This question is required.";
            }
            return null;
          },
          onChanged: (value) {
            answers[question.id] = value;
          },
        );
    }
  }
}

class SentimentBox extends StatelessWidget {
  final String percent;
  final String label;
  final IconData icon;
  final Color color;
  //final count = apiData['count']; // Babalikan

  const SentimentBox({
    super.key,
    required this.percent,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 95,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    percent,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ),
            Icon(icon, size: 42, color: Colors.indigo),
          ],
        ),
      ),
    );
  }
}

class BarGraphCard extends StatelessWidget {
  const BarGraphCard({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      {"label": "Concerned", "value": 45, "color": AppTheme.concerned},
      {"label": "Misinfomred", "value": 28, "color": AppTheme.misinformed},
      {"label": "Neutral", "value": 18, "color": AppTheme.neutral},
      {"label": "Proactive", "value": 9, "color": AppTheme.proactive},
    ];

    return Container(
      height: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((item) {
          final int value = item["value"] as int;
          final Color color = item["color"] as Color;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("$value%"),
                Container(
                  height: value * 3,
                  width: 34,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item["label"].toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class TrendLineCard extends StatelessWidget {
  const TrendLineCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 178,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _trendRow("Concerned", "45% → 52%", AppTheme.concerned),
          _trendRow("Neutral", "35% → 44%", AppTheme.neutral),
          _trendRow("Proactive", "26% → 33%", AppTheme.proactive),
          _trendRow("Misinformed", "16% → 24%", AppTheme.misinformed),
        ],
      ),
    );
  }

  static Widget _trendRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(width: 14, height: 14, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(value),
        ],
      ),
    );
  }
}

class InsightCard extends StatelessWidget {
  final String title;
  final String value;
  final String description;
  final Color color;

  const InsightCard({
    super.key,
    required this.title,
    required this.value,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.45),
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(description, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class RegionMiniCard extends StatelessWidget {
  final String region;
  final String sentiment;
  final String change;

  const RegionMiniCard({
    super.key,
    required this.region,
    required this.sentiment,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        dense: true,
        title: Text(region),
        subtitle: Text(sentiment),
        trailing: Text(
          change,
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class RegionalSentimentCard extends StatelessWidget {
  final String region;
  final String sentiment;
  final int percent;
  final Color color;

  const RegionalSentimentCard({
    super.key,
    required this.region,
    required this.sentiment,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(region, style: const TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),

            Stack(
              children: [
                Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percent / 100,
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sentiment,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Spacer(),

                Text(
                  "$percent% of the population",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
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
