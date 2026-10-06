import 'package:flutter/widgets.dart';

// Starter translations: have native speakers review these before release.
// Keys match the English phrases in the static text inventory.
const appTranslations = <String, Map<String, String>>{
  'Filipino': {
    'Home': 'Simula',
    'Profile': 'Profile',
    'Disease Map': 'Mapa ng mga Sakit',
    'Preferences': 'Mga Kagustuhan',
    'Appearance': 'Hitsura',
    'Language Selection': 'Pagpili ng Wika',
    'Choose your preferred application language':
        'Piliin ang iyong gustong wika para sa application',
    'Current theme: {theme}': 'Kasalukuyang tema: {theme}',
    // Profile and preferences
    'Account, preferences, security, and accessibility':
        'Account, mga kagustuhan, seguridad, at aksesibilidad',
    'Account': 'Account',
    'Authentication': 'Pagpapatunay ng Pagkakakilanlan',
    'Login Security': 'Seguridad sa Pag-sign In',
    'Replay Coach Marks': 'Ipakitang Muli ang Gabay',
    'Show your guide highlights again': 'Ipakitang muli ang mga gabay sa paggamit',
    'Logout': 'Mag-sign Out',
    'Clear this session and return to login.':
        'Tapusin ang session at bumalik sa pag-sign in.',
    'Guest User': 'Bisita',
    'Tap to create your profile': 'Pindutin upang gumawa ng iyong profile',
    'No saved address': 'Walang naka-save na address',
    'No city': 'Walang nakatalang lungsod',

    // Theme and language selection
    'Default': 'Karaniwan',
    'Light': 'Maliwanag',
    'Grey': 'Abo',
    'Dark': 'Madilim',
    'Choose Language': 'Pumili ng Wika',
    'Select your preferred language for HealthPH+.':
        'Piliin ang iyong gustong wika para sa HealthPH+.',
    'This is your selected language': 'Ito ang iyong napiling wika',

    // PIN and biometric settings
    'PIN Login': 'Pag-sign In Gamit ang PIN',
    'Set PIN': 'Magtakda ng PIN',
    'Set PIN first': 'Magtakda muna ng PIN',
    'Update PIN': 'Baguhin ang PIN',
    'Save PIN': 'I-save ang PIN',
    'Current password': 'Kasalukuyang password',
    'Fingerprint Login': 'Pag-sign In Gamit ang Fingerprint',
    'Enabled': 'Naka-on',
    'Disabled': 'Naka-off',
    'Available': 'Magagamit',

    // Common buttons
    'Cancel': 'Kanselahin',
    'Continue': 'Magpatuloy',
    'Back': 'Bumalik',
    'Next': 'Susunod',
    'Done': 'Tapos Na',
    'Close': 'Isara',
    'Open': 'Buksan',
    'View': 'Tingnan',
    'View Details': 'Tingnan ang Detalye',
    'Read more': 'Magbasa Pa',
    'Try again': 'Subukang Muli',
    'Retry': 'Subukang Muli',
    'Submit': 'Isumite',
    'Submitting...': 'Isinusumite...',
    // Home page
    'Active Outbreaks': 'Aktibong Paglaganap ng Sakit',
    'Regional disease signals': 'Mga Palatandaan ng Sakit sa mga Rehiyon',
    'Health Alerts': 'Mga Babala sa Kalusugan',
    'Recent inbox alerts': 'Mga Bagong Natanggap na Babala',
    'Active Users': 'Mga Aktibong Gumagamit',
    'Registered mobile users': 'Mga Rehistradong Gumagamit ng App',
    'Mobile Surveys': 'Mga Survey sa App',
    'Available public surveys': 'Mga Pampublikong Survey na Maaaring Sagutan',
    'Disease Watch': 'Pagsubaybay sa Sakit',
    'Track outbreaks and alerts': 'Subaybayan ang paglaganap ng sakit at mga babala',
    'Health Literacy': 'Kaalaman sa Kalusugan',
    'Public attitude insights': 'Mga Pananaw ng Publiko',
    'Quick Actions ⓘ': 'Mga Mabilisang Aksyon ⓘ',
    'Recent Alerts ⓘ': 'Mga Bagong Babala ⓘ',
    'Your Health Contribution': 'Ang Iyong Ambag sa Kalusugan',
    'Report symptoms, review contribution, or answer surveys':
        'Mag-ulat ng sintomas, tingnan ang iyong mga ambag, o sumagot ng survey',
    'Data Collection and Self-Report': 'Pangangalap ng Datos at Sariling Ulat',
    'Submit symptoms and health information':
        'Magsumite ng mga sintomas at impormasyon sa kalusugan',
    'My Self-Reports': 'Aking mga Sariling Ulat',
    'Review your previous contributions': 'Balikan ang iyong mga naunang ambag',
    'Sentiment Pulse and Mobile Survey': 'Pananaw ng Publiko at Survey sa App',
    'View surveys available for mobile users':
        'Tingnan ang mga survey na maaaring sagutan sa app',
    // Health Literacy Hub
    'Health Literacy Hub': 'Sentro ng Kaalaman sa Kalusugan',
    'Evidence-based health information and fact-checking':
        'Impormasyong pangkalusugan batay sa ebidensya at pagsusuri ng katotohanan',
    'Search articles, topics, claims...':
        'Maghanap ng artikulo, paksa, o pahayag...',
    'Articles': 'Mga Artikulo',
    'Videos': 'Mga Video',
    'Infographics': 'Mga Infographic',
    'No articles found.': 'Walang nahanap na artikulo.',
    'No videos found.': 'Walang nahanap na video.',
    'No infographics found.': 'Walang nahanap na infographic.',
    'Unable to load content.': 'Hindi maipakita ang nilalaman.',
    'Video is unavailable.': 'Hindi available ang video.',
    'Watch video': 'Panoorin ang Video',
    'Open PDF': 'Buksan ang PDF',
  },
  'Cebuano': {
    'Home': 'Sinugdanan',
    'Profile': 'Profile',
    'Disease Map': 'Mapa sa mga Sakit',
  },
  'Ilocano': {
    'Home': 'Rugian',
    'Profile': 'Profile',
    'Disease Map': 'Mapa dagiti Sakit',
  },
  'Hiligaynon': {
    'Home': 'Sinugdanan',
    'Profile': 'Profile',
    'Disease Map': 'Mapa sang mga Balatian',
  },
};

String translateText(
  String english,
  String language, {
  Map<String, Object> parameters = const {},
}) {
  final translated = appTranslations[language]?[english];
  final template = translated == null || translated.trim().isEmpty
      ? english
      : translated;
  return template.replaceAllMapped(RegExp(r'\{([^{}]+)\}'), (match) {
    return parameters[match.group(1)]?.toString() ?? match.group(0)!;
  });
}

class AppLanguageScope extends InheritedWidget {
  const AppLanguageScope({
    super.key,
    required this.language,
    required super.child,
  });

  final String language;

  @override
  bool updateShouldNotify(AppLanguageScope oldWidget) =>
      language != oldWidget.language;
}

extension AppTranslationContext on BuildContext {
  String tr(String english, {Map<String, Object> parameters = const {}}) {
    final scope = dependOnInheritedWidgetOfExactType<AppLanguageScope>();
    return translateText(
      english,
      scope?.language ?? 'English',
      parameters: parameters,
    );
  }
}
