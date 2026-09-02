class MobileSurvey {
  final String id;
  final String title;
  final String subtitle;
  final int target;
  final int responses;
  final String status;
  final List<MobileSurveyQuestion> questions;

  MobileSurvey({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.target,
    required this.responses,
    required this.status,
    required this.questions,
  });

  factory MobileSurvey.fromJson(Map<String, dynamic> json) {
    return MobileSurvey(
      id: json["id"]?.toString() ?? "",
      title: json["title"]?.toString() ?? "Untitled Survey",
      subtitle: json["subtitle"]?.toString() ?? "",
      target: json["target"] is int ? json["target"] as int : 0,
      responses: json["responses"] is int ? json["responses"] as int : 0,
      status: json["status"]?.toString() ?? "",
      questions: (json["questions"] as List? ?? [])
          .whereType<Map>()
          .map((item) => MobileSurveyQuestion.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class MobileSurveyQuestion {
  final String id;
  final String type;
  final String title;
  final bool isRequired;
  final List<String> choices;
  final int rateMin;
  final int rateMax;

  MobileSurveyQuestion({
    required this.id,
    required this.type,
    required this.title,
    required this.isRequired,
    required this.choices,
    required this.rateMin,
    required this.rateMax,
  });

  factory MobileSurveyQuestion.fromJson(Map<String, dynamic> json) {
    return MobileSurveyQuestion(
      id: json["id"]?.toString() ?? "",
      type: json["type"]?.toString() ?? "text",
      title: json["title"]?.toString() ?? "Question",
      isRequired: json["required"] == true,
      choices: (json["choices"] as List? ?? [])
          .map((item) => item.toString())
          .toList(),
      rateMin: json["rateMin"] is int ? json["rateMin"] as int : 1,
      rateMax: json["rateMax"] is int ? json["rateMax"] as int : 5,
    );
  }
}