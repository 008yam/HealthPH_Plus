class AppOption {
  final String id;
  final String label;

  const AppOption({required this.id, required this.label});
}

class AppTaxonomy {
  static const guestEmail = "guest@healthphplus.local";

  static const roles = [
    AppOption(id: "citizen", label: "Citizen"),
    AppOption(id: "field_health_worker", label: "Field Health Worker"),
    AppOption(id: "lgu_doh_user", label: "LGU/DOH User"),
  ];

  static const guestRole = AppOption(id: "guest", label: "Guest Tester");

  static const reporterTypes = [
    AppOption(id: "guest", label: "Guest"),
    AppOption(id: "registered", label: "Registered"),
  ];

  static const symptoms = [
    AppOption(id: "cough", label: "Cough"),
    AppOption(id: "fever", label: "Fever"),
    AppOption(id: "chills", label: "Chills"),
    AppOption(id: "fatigue", label: "Fatigue"),
    AppOption(id: "shortness_of_breath", label: "Shortness of breath"),
    AppOption(id: "chest_pain", label: "Chest Pain"),
    AppOption(id: "sore_throat", label: "Sore throat"),
    AppOption(id: "runny_nose", label: "Runny nose"),
    AppOption(id: "wheezing", label: "Wheezing"),
    AppOption(id: "loss_of_taste_or_smell", label: "Loss of taste or smell"),
    AppOption(id: "headache", label: "Headache"),
    AppOption(id: "body_aches", label: "Body aches"),
    AppOption(id: "cough_2_weeks", label: "Cough for 2+ weeks"),
    AppOption(id: "night_sweats", label: "Night sweats"),
    AppOption(id: "weight_loss", label: "Weight loss"),
  ];

  static const possibleConditions = [
    AppOption(
      id: "covid_like_respiratory_pattern",
      label: "Possible COVID-like respiratory symptom pattern",
    ),
    AppOption(id: "pneumonia_pattern", label: "Possible pneumonia pattern"),
    AppOption(
      id: "tuberculosis_pattern",
      label: "Possible tuberculosis symptom pattern",
    ),
    AppOption(
      id: "acute_respiratory_infection_pattern",
      label: "Possible acute respiratory infection pattern",
    ),
    AppOption(
      id: "respiratory_symptoms_reported",
      label: "Respiratory symptoms reported",
    ),
  ];

  static String labelFor(List<AppOption> options, String id) {
    return options
        .firstWhere(
          (option) => option.id == id,
          orElse: () => AppOption(id: id, label: id),
        )
        .label;
  }

  static String idForLabel(List<AppOption> options, String label) {
    final normalizedLabel = label.trim().toLowerCase();

    return options
        .firstWhere(
          (option) => option.label.toLowerCase() == normalizedLabel,
          orElse: () => AppOption(id: label, label: label),
        )
        .id;
  }

  static List<String> labelsFor(List<AppOption> options, List<String> ids) {
    return ids.map((id) => labelFor(options, id)).toList();
  }

  static List<String> idsForLabels(
    List<AppOption> options,
    List<String> labels,
  ) {
    return labels.map((label) => idForLabel(options, label)).toList();
  }

  static bool isGuestRole(String roleId) {
    return roleId == guestRole.id;
  }
}
