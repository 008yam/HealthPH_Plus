import 'package:flutter/widgets.dart';

// Starter translations: have native speakers review these before release.
// Keys match the English phrases in the static text inventory.
const appTranslations = <String, Map<String, String>>{
  'Filipino': {
    'Search alerts': 'Maghanap ng mga abiso',
    'No matching alerts.': 'Walang tumugmang abiso.',
    'Refresh': 'I-refresh',
    'Load more': 'Magpakita pa',
    'Unable to mark alert as read.': 'Hindi mamarkahan bilang nabasa ang abiso.',
    'Please sign in again before submitting your report.':
        'Mag-sign in muli bago isumite ang iyong ulat.',
    'Your session has expired. Please sign in again.':
        'Nag-expire na ang iyong session. Mag-sign in muli.',
    'The server did not accept your report. Please review your details and try again.':
        'Hindi tinanggap ng server ang iyong ulat. Suriin ang mga detalye at subukang muli.',
    'Could not confirm submission. Check My Self Reports before trying again.':
        'Hindi makumpirma ang pagsusumite. Tingnan muna ang iyong mga ulat bago subukang muli.',
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
    'Show your guide highlights again':
        'Ipakitang muli ang mga gabay sa paggamit',
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
    'Track outbreaks and alerts':
        'Subaybayan ang paglaganap ng sakit at mga babala',
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
    'Search alerts': 'Pangitaa ang mga pahibalo',
    'No matching alerts.': 'Walay katugbang nga pahibalo.',
    'Refresh': 'I-refresh',
    'Load more': 'Ipakita pa',
    'Unable to mark alert as read.': 'Dili mamarkahan nga nabasa ang pahibalo.',
    'Please sign in again before submitting your report.':
        'Pag-sign in pag-usab sa dili pa ipadala ang imong taho.',
    'The server did not accept your report. Please review your details and try again.':
        'Wala gidawat sa server ang imong taho. Susiha ang mga detalye ug sulayi pag-usab.',
    'Could not confirm submission. Check My Self Reports before trying again.':
        'Dili makumpirma ang pagpadala. Susiha una ang imong mga taho sa dili pa mosulay pag-usab.',
    "Wearher unavailable": "Dili makuha ang impormasyon sa panahon",
    "Today": "Karong Adlawa",
    "{weather.temperature.toInt()}°C": "{weather.temperature.toInt()}°C",
    "Sunny": "Masidlak ang adlaw",
    "Humidity": "Kaumog",
    "Pressure": "Presyon",
    "AQI": "AQI",
    "{weather.temperature.round()}°C · Today":
        "{weather.temperature.round()}°C · Karong Adlawa",
    "AQI {weather.aqi}": "AQI {weather.aqi}",
    "Six-digit PIN": "PIN nga unom ka digit",
    "Home": "Sinugdanan",
    "Profile": "Profile",
    "Disease Map": "Mapa sa mga Sakit",
    "Skip": "Laktawi",
    "Done": "Nahuman",
    "Next": "Sunod",
    "Default": "Default",
    "Light": "Hayag",
    "Grey": "Abohon",
    "Dark": "Ngitngit",
    "HealthPH+ blue and gold": "Asul ug bulawan sa HealthPH+",
    "Bright clinical layout": "Hayag nga klinikal nga disenyo",
    "Soft neutral contrast": "Malumo nga kalainan sa neyutral nga mga kolor",
    "Low-light dashboard style":
        "Disenyo sa dashboard alang sa ngitngit nga palibot",
    "Failed to load public surveys: {response.statusCode}":
        "Dili makuha ang mga pampublikong survey: {response.statusCode}",
    "Failed to submit survey response: {response.body}":
        "Dili maisumite ang tubag sa survey: {response.body}",
    "Sign in with a registered account to view alerts.":
        "Pag-sign in gamit ang rehistradong account aron makita ang mga pasidaan.",
    "Your session has expired. Please sign in again.":
        "Na-expire na ang imong session. Palihog pag-sign in pag-usab.",
    "Failed to load mobile alerts ({response.statusCode}): {response.body}":
        "Dili makuha ang mga pasidaan sa app ({response.statusCode}): {response.body}",
    "Mobile alert request failed ({response.statusCode}): {response.body}":
        "Napakyas ang hangyo alang sa pasidaan sa app ({response.statusCode}): {response.body}",
    "Self-reported on {createdAt.month}/{createdAt.day}/{createdAt.year} at {hour}:{minute}":
        "Kaugalingong gi-report niadtong {createdAt.month}/{createdAt.day}/{createdAt.year} sa {hour}:{minute}",
    "Self-reported respiratory symptoms":
        "Kaugalingong gi-report nga mga sintomas sa pagginhawa",
    "Exact address geocoded": "Nakit-an ang mga coordinate sa adres",
    "Region-level estimate": "Gibanabana nga lokasyon sa rehiyon",
    "Use biometrics to sign in to HealthPH+.":
        "Gamita ang biometrics aron maka-sign in sa HealthPH+.",
    "Failed to loaod disease points": "Dili makuha ang mga lokasyon sa sakit",
    "Failed to sync self-report to MongoDB":
        "Dili ma-sync ang kaugalingong report ngadto sa MongoDB",
    "Failed to load self-report map pings":
        "Dili makuha ang mga pin sa mapa sa kaugalingong report",
    "A user id or email is required.": "Gikinahanglan ang user ID o email.",
    "Failed to load your self-reports ({response.statusCode}): {response.body}":
        "Dili makuha ang imong kaugalingong mga report ({response.statusCode}): {response.body}",
    "Health literacy response has no items array":
        "Walay items array ang tubag alang sa kahibalo sa panglawas",
    "Failed to load health literacy content ({response.statusCode}): {response.body}":
        "Dili makuha ang sulod sa kahibalo sa panglawas ({response.statusCode}): {response.body}",
    "Failed to save mobile user to MongoDB: {response.body}":
        "Dili ma-save ang tiggamit sa app ngadto sa MongoDB: {response.body}",
    "Failed to login: {response.body}": "Dili maka-sign in: {response.body}",
    "Failed to set Pin: {response.body}":
        "Dili matakda ang PIN: {response.body}",
    "Failed to verify PIN: {response.body}":
        "Dili mapamatud-an ang PIN: {response.body}",
    "Failed to update language: {response.body}":
        "Dili mausab ang pinulongan: {response.body}",
    "Failed to load mobile users count ({response.statusCode}): {response.body}":
        "Dili makuha ang gidaghanon sa mga tiggamit sa app ({response.statusCode}): {response.body}",
    "A mobile access token is required.":
        "Gikinahanglan ang mobile access token.",
    "HealthPH+ self-reports export":
        "Pag-export sa kaugalingong mga report sa HealthPH+",
    "Exported HealthPH+ self-report records.":
        "Na-export nga kaugalingong mga report sa HealthPH+.",
    "Login with a registered account to view your account self-reports.":
        "Pag-sign in gamit ang rehistradong account aron makita ang imong kaugalingong mga report.",
    "Unable to load self-reports. Check your backend connection.":
        "Dili makuha ang kaugalingong mga report. Susiha ang koneksyon sa backend.",
    "My Self-Reports": "Akong mga Kaugalingong Report",
    "Review the symptoms and possible conditions you contributed.":
        "Susiha ang mga sintomas ug posibleng kondisyon nga imong gi-report.",
    "No reports yet": "Wala pay mga report",
    "Local reports": "Lokal nga mga report",
    "Mongo reports": "Mga report sa MongoDB",
    "Most common concern": "Kasagarang gikabalak-an",
    "Latest contribution": "Pinakabag-ong kontribusyon",
    "None": "Wala",
    "Report ID": "ID sa Report",
    "Status": "Kahimtang",
    "Detected Language": "Nailhang Pinulongan",
    "Location": "Lokasyon",
    "Date": "Petsa",
    "Notes": "Mga Nota",
    "Try again": "Sulayi Pag-usab",
    "No self-reports yet": "Wala pay kaugalingong mga report",
    "Submitted self-reports will appear here for review.":
        "Makita dinhi ang gisumite nga kaugalingong mga report aron masusi.",
    "Mongo report": "Report sa MongoDB",
    "submitted": "naisumite",
    "Respiratory symptoms": "Mga sintomas sa pagginhawa",
    "Date unavailable": "Walay petsa",
    "{date.month}/{date.day}/{date.year} at {hour}:{minute}":
        "{date.month}/{date.day}/{date.year} sa {hour}:{minute}",
    "Location unavailable": "Walay makuhang lokasyon",
    "Please sign in with a registered account first.":
        "Palihog pag-sign in una gamit ang rehistradong account.",
    "Your PIN was saved successfully.": "Malampusong na-save ang imong PIN.",
    "Unable to save PIN. Check your password and connection.":
        "Dili ma-save ang PIN. Susiha ang imong password ug koneksyon.",
    "Coach marks will replay when you revisit pages.":
        "Ipakita pag-usab ang mga giya kon mobalik ka sa mga panid.",
    "Review the account details and location saved during registration.":
        "Susiha ang detalye sa account ug lokasyon nga na-save panahon sa pagrehistro.",
    "Appearance": "Panagway",
    "Choose the background and color mode that is most readable for you.":
        "Pilia ang background ug mga kolor nga labing sayon nimo basahon.",
    "Language Selection": "Pagpili og Pinulongan",
    "Choose the language that is most comfortable for you.":
        "Pilia ang pinulongan nga labing komportable nimo gamiton.",
    "Login Security": "Seguridad sa Pag-sign In",
    "Set your account PIN and manage fingerprint login when your device supports it.":
        "Itakda ang PIN sa imong account ug dumalaha ang pag-sign in gamit ang fingerprint kon suportado sa imong device.",
    "Account, preferences, security, and accessibility":
        "Account, mga gipalabi, seguridad, ug aksesibilidad",
    "Preferences": "Mga Gipalabi",
    "Current theme: {appSettings.visualMode.label}":
        "Kasamtangang tema: {appSettings.visualMode.label}",
    "Choose your preferred application language":
        "Pilia ang imong gustong pinulongan para sa app",
    "Replay Coach Marks": "Ipakita Pag-usab ang Giya",
    "Show your guide highlights again":
        "Ipakita pag-usab ang mga giya sa paggamit",
    "Account": "Account",
    "Logout": "Pag-sign Out",
    "Clear this session and return to login.":
        "Taposa kini nga session ug balik sa pag-sign in.",
    "Guest User": "Bisita",
    "Tap to create your profile": "Pislita aron makahimo sa imong profile",
    "Guest Access": "Akses alang sa Bisita",
    "Complete your address during registration":
        "Kompletoha ang imong adres panahon sa pagrehistro",
    "Register": "Pagrehistro",
    "Active": "Aktibo",
    "No saved address": "Walay na-save nga adres",
    "No city": "Walay nakatalang siyudad",
    "Mobile Surveys": "Mga Survey sa App",
    "{count} survey ready to answer": "{count} ka survey ang andam tubagon",
    "Check available surveys": "Tan-awa ang mga survey nga mahimong tubagon",
    "Enter all six PIN digits.": "Isulod ang tanang unom ka digit sa PIN.",
    "Enter your current account password.":
        "Isulod ang kasamtangang password sa imong account.",
    "Set six-digit PIN": "Pagtakda og PIN nga unom ka digit",
    "Enter a six-digit numeric PIN. Each digit uses a separate box.":
        "Isulod ang PIN nga unom ka numero. Matag numero adunay kaugalingong kahon.",
    "Current password": "Kasamtangang password",
    "Cancel": "Kanselahon",
    "Save PIN": "I-save ang PIN",
    "Authentication": "Pagpamatuod sa Pagkatawo",
    "PIN Login": "Pag-sign In Gamit ang PIN",
    "Set PIN first": "Pagtakda una og PIN",
    "Enabled": "Naka-on",
    "Disabled": "Naka-off",
    "You need to set a six-digit PIN before enabling PIN login.":
        "Kinahanglan ka magtakda og PIN nga unom ka digit sa dili pa i-on ang pag-sign in gamit ang PIN.",
    "Set PIN": "Pagtakda og PIN",
    "Update PIN": "Usba ang PIN",
    "Open": "Ablihi",
    "Fingerprint Login": "Pag-sign In Gamit ang Fingerprint",
    "Available": "Magamit",
    "Biometric login disabled.":
        "Naka-off ang pag-sign in gamit ang biometrics.",
    "Login first before enabling biometrics.":
        "Pag-sign in una sa dili pa i-on ang biometrics.",
    "Biometrics authentication is unavailable or cancelled.":
        "Dili magamit o gikansela ang pagpamatuod gamit ang biometrics.",
    "Biometric login enabled": "Naka-on ang pag-sign in gamit ang biometrics",
    "AURI": "AURI",
    "Cough": "Ubo",
    "Fever": "Hilanat",
    "Sore throat": "Sakit sa tutunlan",
    "Influenza-like illness": "Sakit nga sama sa trangkaso",
    "Pneumonia": "Pneumonia",
    "Bronchitis": "Bronchitis",
    "Asthma flare-up": "Pagsamot sa hika",
    "Shortness of breath": "Kalisod sa pagginhawa",
    "Wheezing": "Pagtaghoy sa pagginhawa",
    "COVID-like symptoms": "Mga sintomas nga sama sa COVID",
    "Tuberculosis symptoms": "Mga sintomas sa tuberculosis",
    "Acute Upper Respiratory Infection": "Acute Upper Respiratory Infection",
    "Upper Respiratory": "Ibabaw nga bahin sa agianan sa ginhawa",
    "Updated: June 1, 2026": "Gi-update: Hunyo 1, 2026",
    "Lower Respiratory": "Ubos nga bahin sa agianan sa ginhawa",
    "Updated: May 31, 2026": "Gi-update: Mayo 31, 2026",
    "Tuberculosis": "Tuberculosis",
    "Respiratory": "May kalabotan sa pagginhawa",
    "Updated: May 30, 2026": "Gi-update: Mayo 30, 2026",
    "All diseases & symptoms": "Tanang sakit ug sintomas",
    "filter": "filter",
    "filters": "mga filter",
    "{selectedFilters.length} {filterLabel} selected":
        "{selectedFilters.length} ka {filterLabel} ang napili",
    "Select Diseases / Symptoms": "Pagpili og mga Sakit / Sintomas",
    "Close": "Sirad-i",
    "No filters selected. All reports will be shown.":
        "Walay napiling filter. Ipakita ang tanang report.",
    "{draftFilters.length} selected": "{draftFilters.length} ang napili",
    "Clear All": "Hawani Tanan",
    "Apply": "I-apply",
    "Respiratory outbreak monitoring":
        "Pagsubay sa pagkaylap sa mga sakit sa pagginhawa",
    "Disease Watch": "Pagsubay sa Sakit",
    "Health Literacy": "Kahibalo sa Panglawas",
    "Sentiment Pulse": "Panan-aw sa Publiko",
    "Data Collection": "Pagkolekta og Datos",
    "Outbreak Map": "Mapa sa Pagkaylap sa Sakit",
    "{reportCount} active reports": "{reportCount} ka aktibong report",
    "{outbreak[\"reports\"]} reports": "{outbreak[\"reports\"]} ka report",
    "Contribute symptom information to disease surveillance and review reports connected to your account.":
        "Ipaambit ang impormasyon sa sintomas alang sa pagsubay sa sakit ug susiha ang mga report nga nalambigit sa imong account.",
    "Collection Tabs": "Mga Tab sa Pagkolekta",
    "Switch between submitting a self-report, reviewing your reports, and community information.":
        "Pagbalhin tali sa pagsumite sa kaugalingong report, pagsusi sa imong mga report, ug impormasyon sa komunidad.",
    "Self Report Form": "Porma sa Kaugalingong Report",
    "Complete your location, symptoms, duration, severity, and notes before submitting your report.":
        "Kompletoha ang lokasyon, mga sintomas, gidugayon, kagrabe, ug mga nota sa dili pa isumite ang imong report.",
    "Back": "Balik",
    "Tracks symptoms & outbreaks":
        "Nagsubay sa mga sintomas ug pagkaylap sa sakit",
    "Self Report": "Kaugalingong Report",
    "My Reports": "Akong mga Report",
    "Community": "Komunidad",
    "Self-reports CSV is ready to share.":
        "Andam nang ipaambit ang CSV sa kaugalingong mga report.",
    "Unable to export self-reports CSV.":
        "Dili ma-export ang CSV sa kaugalingong mga report.",
    "Your Recent Reports": "Imong Bag-ong mga Report",
    "No self-reports submitted yet.":
        "Wala pay naisumite nga kaugalingong report.",
    "Your Recent Reports ({reports.length})":
        "Imong Bag-ong mga Report ({reports.length})",
    "Export CSV": "I-export ang CSV",
    "Self-reported": "Kaugalingong gi-report",
    "For review": "Alang sa pagsusi",
    "No additional notes provided.": "Walay dugang nga nota.",
    "Community Reports": "Mga Report sa Komunidad",
    "View symptom reports shared by other users.":
        "Tan-awa ang mga report sa sintomas nga gipaambit sa ubang tiggamit.",
    "2 days": "2 ka adlaw",
    "Moderate": "Kasarangan",
    "Reported on May 6, 2025": "Gi-report niadtong Mayo 6, 2025",
    "User experienced fever and fatigue.":
        "Ang tiggamit nakasinati og hilanat ug kakapoy.",
    "4 days": "4 ka adlaw",
    "Mild": "Dili grabe",
    "User reported dry cough and throat irritation.":
        "Ang tiggamit nag-report og uga nga ubo ug iritasyon sa tutunlan.",
    "Headache": "Sakit sa ulo",
    "1 day": "1 ka adlaw",
    "Reported on May 5, 2025": "Gi-report niadtong Mayo 5, 2025",
    "User reported mild headache and tiredness.":
        "Ang tiggamit nag-report og dili grabeng sakit sa ulo ug kakapoy.",
    "Complete address and add at least one symptoms":
        "Kompletoha ang adres ug pagdugang og labing menos usa ka sintomas",
    "Self-report submitted successfully.":
        "Malampusong naisumite ang kaugalingong report.",
    "Report submitted": "Naisumite ang report",
    "{condition.label} This is not a diagnosis. Please consult a healthcare provider, especially if symptoms worsen.":
        "{condition.label} Dili kini usa ka diagnosis. Palihog konsultaha ang usa ka propesyonal sa panglawas, ilabina kon mosamot ang mga sintomas.",
    "Understood": "Nasabtan",
    "Self Report Symptoms": "Ireport ang Imong mga Sintomas",
    "Report respiratory symptoms to supper surveillance mapping.":
        "Ireport ang mga sintomas sa pagginhawa aron makatabang sa pagmapa ug pagsubay sa sakit.",
    "Using your registered address. Adress fields are locked for account consistency.":
        "Gigamit ang imong rehistradong adres. Dili mausab ang mga field sa adres aron magpabiling pareho ang impormasyon sa account.",
    "Region": "Rehiyon",
    "Province": "Probinsya",
    "City / Municipality": "Siyudad / Munisipyo",
    "Barangay": "Barangay",
    "Symptoms": "Mga Sintomas",
    "Additional notes (optional)": "Dugang nga mga nota (opsyonal)",
    "Location Address...": "Gipangita ang Adres...",
    "Submit Self Report": "Isumite ang Kaugalingong Report",
    "Duration: {duration}": "Gidugayon: {duration}",
    "Possible / Consideration: {consideration}":
        "Posible / Angay Hunahunaon: {consideration}",
    "Why Report Symptoms Your reports help public health officials track and monitor its origin.":
        "Nganong Ireport ang mga Sintomas Ang imong mga report makatabang sa mga opisyal sa panglawas sa pagsubay ug pagmonitor sa gigikanan niini.",
    "Respiratory Infection Cluster":
        "Grupo sa mga Kaso sa Impeksyon sa Pagginhawa",
    "Upper Respiratory Disease":
        "Sakit sa Ibabaw nga Bahin sa Agianan sa Ginhawa",
    "Monitor reported respiratory disease activity across Philippine regions.":
        "Subaybayi ang gi-report nga mga sakit sa pagginhawa sa mga rehiyon sa Pilipinas.",
    "Search and Filter": "Pagpangita ug Pag-filter",
    "Search a region or disease term, then narrow the results by disease category.":
        "Pangitaa ang rehiyon o sakit, dayon limitahi ang mga resulta sumala sa kategoriya sa sakit.",
    "Regional Reports": "Mga Report sa Rehiyon",
    "Review each region's report totals and disease breakdown in the results list.":
        "Susiha ang kinatibuk-ang report ug pagbahinbahin sa mga sakit sa matag rehiyon diha sa listahan sa resulta.",
    "Outbreak monitoring across the Philippines":
        "Pagsubay sa pagkaylap sa sakit sa tibuok Pilipinas",
    "Find Diseases": "Pangitaa ang mga Sakit",
    "Select all that apply": "Pilia ang tanang angay",
    "COVID": "COVID",
    "Active Outbreaks": "Aktibong Pagkaylap sa Sakit",
    "Resolved": "Nasulbad",
    "Error: {snapshot.error}": "Sayop: {snapshot.error}",
    "No outbreaks found.": "Walay nakitang pagkaylap sa sakit.",
    "Region {region[\"region\"]}": "Rehiyon {region[\"region\"]}",
    "AURI: {auri} | PN: {pn} | TB: {tb} | COVID: {covid}":
        "AURI: {auri} | PN: {pn} | TB: {tb} | COVID: {covid}",
    "Severity Levels": "Mga Ang-ang sa Kagrabe",
    "{reports} reports": "{reports} ka report",
    "View Details": "Tan-awa ang mga Detalye",
    "Monitor outbreak reports, active cases, and disease risk signals across regions.":
        "Subaybayi ang mga report sa pagkaylap sa sakit, aktibong kaso, ug mga timailhan sa risgo sa sakit sa mga rehiyon.",
    "View outbreak activity geographically and identify affected areas faster.":
        "Tan-awa sa mapa ang pagkaylap sa sakit aron mas dali mailhan ang naapektuhang mga lugar.",
    "Health Literacy Hub": "Sentro sa Kahibalo sa Panglawas",
    "Read evidence-based health articles and review fact-checking information.":
        "Basaha ang mga artikulo sa panglawas nga gibase sa ebidensya ug susiha ang impormasyon bahin sa pagsusi sa kamatuoran.",
    "Understand public concern, misinformation, and health behavior trends.":
        "Sabta ang mga kabalaka sa publiko, sayop nga impormasyon, ug mga uso sa pamatasan bahin sa panglawas.",
    "Submit and review symptom reports that support public health monitoring.":
        "Isumite ug susiha ang mga report sa sintomas nga makatabang sa pagsubay sa panglawas sa publiko.",
    "Continue": "Padayon",
    "English": "English",
    "Filipino": "Filipino",
    "Cebuano": "Cebuano",
    "Ilocano": "Ilocano",
    "Hiligaynon": "Hiligaynon",
    "Choose Language": "Pagpili og Pinulongan",
    "Select your preferred language for HealthPH+.":
        "Pilia ang imong gustong pinulongan para sa HealthPH+.",
    "This is your selected language": "Kini ang imong napiling pinulongan",
    "Evidence-based health infomration and fact-checking":
        "Impormasyon sa panglawas nga gibase sa ebidensya ug pagsusi sa kamatuoran",
    "Overview": "Kinatibuk-ang Pagtan-aw",
    "Trends": "Mga Uso",
    "Regional": "Sa mga Rehiyon",
    "Survey": "Survey",
    "Overall Sentiment": "Kinatibuk-ang Panan-aw",
    "Concerned": "Nabalaka",
    "Misinformed": "Adunay Sayop nga Impormasyon",
    "Neutral": "Neyutral",
    "Proactive": "Nag-una og Lihok",
    "Sentiment Trends": "Mga Uso sa Panan-aw",
    "Sentiment changes over time":
        "Pagbag-o sa panan-aw sa paglabay sa panahon",
    "Trends Insights": "Pagsabot sa mga Uso",
    "Increase from last week": "Pagsaka gikan sa miaging semana",
    "Region Trend Changes": "Mga Pagbag-o sa Uso sa Rehiyon",
    "Regional Sentiment": "Panan-aw sa Rehiyon",
    "Dominant sentiment by region": "Nag-unang panan-aw sa matag rehiyon",
    "Unable to load surveys.": "Dili makuha ang mga survey.",
    "No active mobile surveys currently available.":
        "Wala pay aktibong survey nga mahimong tubagon sa app karon.",
    "{survey.responses} / {survey.target} responses":
        "{survey.responses} / {survey.target} ka tubag",
    "Please answer at least one question.":
        "Palihog tubaga ang labing menos usa ka pangutana.",
    "Survey response submitted.": "Naisumite ang tubag sa survey.",
    "Unable to submit survey response.": "Dili maisumite ang tubag sa survey.",
    "Submitting...": "Nagpadala pa...",
    "Submit": "Isumite",
    "Type your answer": "Isulat ang imong tubag",
    "This question is required.": "Kinahanglang tubagon kini nga pangutana.",
    "{percent}% of the population": "{percent}% sa populasyon",
    "Browse published articles, videos, and infographics from trusted health sources.":
        "Tan-awa ang gipatik nga mga artikulo, bidyo, ug infographic gikan sa kasaligan nga mga tinubdan sa panglawas.",
    "Search Health Topics": "Pangitaa ang mga Hilisgutan sa Panglawas",
    "Filter the current tab by title, topic, source, disease, or keyword.":
        "I-filter ang kasamtangang tab pinaagi sa titulo, hilisgutan, tinubdan, sakit, o keyword.",
    "Content Categories": "Mga Kategoriya sa Sulod",
    "Switch between articles, playable videos, and downloadable infographics.":
        "Pagbalhin tali sa mga artikulo, bidyo nga mapatukar, ug mga infographic nga ma-download.",
    "Learning Content": "Mga Materyal sa Pagkat-on",
    "Tap a card action to read an article, open a PDF, view an image, or play a video.":
        "Pislita ang aksyon sa card aron mobasa og artikulo, moabli og PDF, motan-aw og hulagway, o mopatukar og bidyo.",
    "Unable to load content.": "Dili maipakita ang sulod.",
    "Retry": "Sulayi Pag-usab",
    "Untitled content": "Sulod nga Walay Titulo",
    "Evidence-based health information and fact-checking":
        "Impormasyon sa panglawas nga gibase sa ebidensya ug pagsusi sa kamatuoran",
    "Search articles, topics, claims...":
        "Pangitaa ang mga artikulo, hilisgutan, o pahayag...",
    "Articles": "Mga Artikulo",
    "Videos": "Mga Bidyo",
    "Infographics": "Mga Infographic",
    "No articles found.": "Walay nakitang artikulo.",
    "No videos found.": "Walay nakitang bidyo.",
    "No infographics found.": "Walay nakitang infographic.",
    "Video is unavailable.": "Dili magamit ang bidyo.",
    "Video": "Bidyo",
    "Watch video": "Tan-awa ang Bidyo",
    "Open PDF": "Ablihi ang PDF",
    "View": "Tan-awa",
    "Read more": "Basaha ang Dugang",
    "Unable to play video. URL: {widget.videoUrl} Error: {snapshot.error}":
        "Dili mapatukar ang bidyo. URL: {widget.videoUrl} Sayop: {snapshot.error}",
    "Verdict:": "Hukom:",
    "Citizen": "Lungsoranon",
    "Field Health Worker": "Trabahante sa Panglawas sa Komunidad",
    "LGU/DOH User": "Tiggamit sa LGU/DOH",
    "Guest Tester": "Bisitang Tigsulay",
    "Guest": "Bisita",
    "Registered": "Rehistrado",
    "Chills": "Pangurog",
    "Fatigue": "Kakapoy",
    "Chest Pain": "Sakit sa Dughan",
    "Runny nose": "Sip-on",
    "Loss of taste or smell": "Pagkawala sa panlasa o pang-amoy",
    "Body aches": "Panakit sa lawas",
    "Cough for 2+ weeks": "Ubo sulod sa 2 o labaw pang semana",
    "Night sweats": "Pagpaningot sa gabii",
    "Weight loss": "Pagkunhod sa timbang",
    "Possible COVID-like respiratory symptom pattern":
        "Posibleng sumbanan sa mga sintomas sa pagginhawa nga sama sa COVID",
    "Possible pneumonia pattern": "Posibleng sumbanan sa pneumonia",
    "Possible tuberculosis symptom pattern":
        "Posibleng sumbanan sa mga sintomas sa tuberculosis",
    "Possible acute respiratory infection pattern":
        "Posibleng sumbanan sa kalit nga impeksyon sa pagginhawa",
    "Respiratory symptoms reported": "Gi-report nga mga sintomas sa pagginhawa",
    "Complete your address.": "Kompletoha ang imong adres.",
    "Account Created.": "Nahimo na ang Account.",
    "Logged in.": "Naka-sign in na.",
    "Biometric login is unavailable. Please use password login.":
        "Dili magamit ang pag-sign in gamit ang biometrics. Palihog gamita ang password.",
    "Reset Password": "I-reset ang Password",
    "Email Address": "Adres sa Email",
    "Pass reset link sent.": "Napadala na ang link sa pag-reset sa password.",
    "Send Link": "Ipadala ang Link",
    "Enter {label}": "Isulod ang {label}",
    "Enter your email": "Isulod ang imong email",
    "Enter a valid email": "Isulod ang balidong email",
    "Enter your password": "Isulod ang imong password",
    "Password must be at least 6 characters":
        "Kinahanglang adunay labing menos 6 ka karakter ang password",
    "Passowrd do not match": "Dili magkapareho ang mga password",
    "Create Account": "Paghimo og Account",
    "User Login": "Pag-sign In sa Tiggamit",
    "Register your basic HeathPH+ profile.":
        "Irehistro ang imong batakang profile sa HealthPH+.",
    "Sign in using your email and password.":
        "Pag-sign in gamit ang imong email ug password.",
    "Full Name": "Kompletong Ngalan",
    "your full name": "imong kompletong ngalan",
    "Email": "Email",
    "Password": "Password",
    "Confirm Password": "Kumpirmaha ang Password",
    "Role": "Papel",
    "Preferred Language": "Gipalabing Pinulongan",
    "Select your preferred language": "Pilia ang imong gipalabing pinulongan",
    "Forgot password?": "Nakalimot sa password?",
    "Login": "Pag-sign In",
    "Login with Biometrics": "Pag-sign In Gamit ang Biometrics",
    "Continue as Guest": "Padayon isip Bisita",
    "Already have an account? Login": "Aduna ka nay account? Pag-sign In",
    "New User? Create an account": "Bag-ong Tiggamit? Paghimo og account",
    "Account ID is missing. Please login again.":
        "Wala ang ID sa account. Palihog pag-sign in pag-usab.",
    "Enter your complete six-digit PIN.":
        "Isulod ang kompleto nga unom ka digit sa imong PIN.",
    "Incorrect PIN. Please try again.":
        "Sayop ang PIN. Palihog sulayi pag-usab.",
    "Enter PIN": "Isulod ang PIN",
    "Enter the six-digit PIN for {widget.profile.email}.":
        "Isulod ang PIN nga unom ka digit para sa {widget.profile.email}.",
    "Verify": "Pamatud-i",
    "Untitled Survey": "Survey nga Walay Titulo",
    "Question": "Pangutana",
    "HealthAlert": "Pasidaan sa Panglawas",
    "{windowMinutes ~/ 60}h window": "Sulod sa {windowMinutes ~/ 60} ka oras",
    "{windowMinutes}m window": "Sulod sa {windowMinutes} ka minuto",
    "{reportCount} reports": "{reportCount} ka report",
    "Live Health Summary": "Kasamtangang Katingbanan sa Panglawas",
    "Swipe through current outbreaks, health alerts, registered users, and available mobile surveys.":
        "I-swipe aron makita ang pagkaylap sa sakit, mga pasidaan, rehistradong tiggamit, ug mga survey nga mahimong tubagon.",
    "Your Contributions": "Imong mga Kontribusyon",
    "Submit a self-report, review your previous reports, or answer an available mobile survey.":
        "Isumite ang kaugalingong report, susiha ang miaging mga report, o tubaga ang usa ka survey.",
    "Quick Actions": "Mga Daling Aksyon",
    "Open Disease Watch for outbreaks or Health Literacy for trusted learning resources.":
        "Ablihi ang Pagsubay sa Sakit aron makita ang pagkaylap niini o ang Kahibalo sa Panglawas alang sa kasaligan nga mga materyal sa pagkat-on.",
    "Recent Alerts": "Bag-ong mga Pasidaan",
    "Review the latest respiratory health alerts and outbreaks":
        "Susiha ang pinakabag-ong mga pasidaan ug pagkaylap sa mga sakit sa pagginhawa",
    "Publication time unavailable": "Walay makuhang oras sa pagpatik",
    "Published {published.year}-{published.month.toString().padLeft(2, '0')}-{published.day.toString().padLeft(2, '0')} {published.hour.toString().padLeft(2, '0')}:{published.minute.toString().padLeft(2, '0')}":
        "Gipatik {published.year}-{published.month.toString().padLeft(2, '0')}-{published.day.toString().padLeft(2, '0')} {published.hour.toString().padLeft(2, '0')}:{published.minute.toString().padLeft(2, '0')}",
    "No additional alert details were provided.":
        "Walay dugang nga detalye nga gihatag alang sa pasidaan.",
    "Unable to open this alert right now.":
        "Dili maablihan kini nga pasidaan karon.",
    "Quick Actions ⓘ": "Mga Daling Aksyon ⓘ",
    "Track outbreaks and alerts":
        "Subaybayi ang pagkaylap sa sakit ug mga pasidaan",
    "Public attitude insights": "Mga Panglantaw sa Publiko",
    "Recent Alerts ⓘ": "Bag-ong mga Pasidaan ⓘ",
    "Unable to load alerts.": "Dili makuha ang mga pasidaan.",
    "No recent alerts right now.": "Wala pay bag-ong mga pasidaan karon.",
    "Health Tips 📖": "Mga Tambag sa Panglawas 📖",
    "Stay Protected": "Panalipdi ang Imong Kaugalingon",
    "Remember to wash your hands frequently, weak mask in crowded places, and keep your living spaces well-ventilated":
        "Hinumdomi ang kanunay nga paghugas sa kamot, pagsul-ob og mask sa daghang tawo, ug pagpasulod og preskong hangin sa imong pinuy-anan.",
    "More Health Tips": "Dugang nga mga Tambag sa Panglawas",
    "Your Health Contribution": "Ang Imong Kontribusyon sa Panglawas",
    "Report symptoms, review contribution, or answer surveys":
        "Ireport ang mga sintomas, susiha ang imong kontribusyon, o tubaga ang mga survey",
    "Data Collection and Self-Report":
        "Pagkolekta og Datos ug Kaugalingong Report",
    "Submit symptoms and health information":
        "Isumite ang mga sintomas ug impormasyon sa panglawas",
    "Review your previous contributions":
        "Susiha ang imong nangaging mga kontribusyon",
    "Sentiment Pulse and Mobile Survey": "Panan-aw sa Publiko ug Survey sa App",
    "View surveys available for mobile users":
        "Tan-awa ang mga survey nga mahimong tubagon sa app",
    "Regional disease signals": "Mga Timailhan sa Sakit sa mga Rehiyon",
    "Health Alerts": "Mga Pasidaan sa Panglawas",
    "Recent inbox alerts": "Bag-ong Nadawat nga mga Pasidaan",
    "Active Users": "Mga Aktibong Tiggamit",
    "Registered mobile users": "Mga Rehistradong Tiggamit sa App",
    "Available public surveys": "Mga Pampublikong Survey nga Mahimong Tubagon",
    "Severity level": "Ang-ang sa kagrabe",
    "Current theme: {theme}": "Kasamtangang tema: {theme}",
    "Weather unavailable": "Dili makuha ang impormasyon sa panahon",
    "Passwords do not match": "Dili magkapareho ang mga password",
    "Password reset link sent.":
        "Napadala na ang link sa pag-reset sa password.",
    "Register your basic HealthPH+ profile.":
        "Irehistro ang imong batakang profile sa HealthPH+.",
    "Complete your address and add at least one symptom.":
        "Kompletoha ang imong adres ug pagdugang og labing menos usa ka sintomas.",
    "Report respiratory symptoms to support surveillance mapping.":
        "Ireport ang mga sintomas sa pagginhawa aron makatabang sa pagmapa ug pagsubay sa sakit.",
    "Biometric authentication is unavailable or cancelled.":
        "Dili magamit o gikansela ang pagpamatuod gamit ang biometrics.",
    "{count} reports": "{count} ka report",
    "{count} selected": "{count} ang napili",
    "{count} surveys ready to answer": "{count} ka survey ang andam tubagon",
    "Duration: {days} days": "Gidugayon: {days} ka adlaw",
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
