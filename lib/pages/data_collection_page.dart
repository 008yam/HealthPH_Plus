import '../localization/app_translations.dart';
import 'package:flutter/material.dart';
import '../data/app_taxonomy.dart';
import '../theme/app_theme.dart';
import 'package:healthphplus/main_page.dart';
import '../services/self_report_store.dart';
import '../services/location_data_services.dart';
import '../widgets/location_autocomplete_field.dart';
import '../services/profile_store.dart';
import '../services/geocoding_service.dart';
import '../theme/responsive.dart';
import '../services/self_report_database.dart';
import '../services/self_report_export_service.dart';
import '../widgets/coach_mark.dart';
import '../services/api_config.dart';
import '../services/healthph_api_services.dart';
import '../models/surveillance_pin.dart';
import 'self_report_history_page.dart';

class DataCollectionPage extends StatefulWidget {
  const DataCollectionPage({super.key});

  @override
  State<DataCollectionPage> createState() => _DataCollectionPageState();
}

class _DataCollectionPageState extends State<DataCollectionPage> {
  final dataHeaderKey = GlobalKey();
  final dataTabsKey = GlobalKey();
  final dataContentKey = GlobalKey();
  final reportSymptomsButtonKey = GlobalKey();

  Future<void> _openSelfReportWizard() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final screen = MediaQuery.sizeOf(dialogContext);

        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 620,
              maxHeight: screen.height * 0.90,
            ),
            child: _SelfReportWizard(
              onSubmitted: () {
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 650), () {
        if (!mounted) return;

        CoachMark.showOnce(
          context,
          discoveryKey: "health_contributions_v1",
          steps: [
            CoachMarkStep(
              targetKey: dataHeaderKey,
              title: "Health Contributions",
              description:
                  "Review your reports and explore anonymous community health trends.",
              icon: Icons.health_and_safety_outlined,
              color: AppTheme.primary,
            ),
            CoachMarkStep(
              targetKey: dataTabsKey,
              title: "Contribution Views",
              description:
                  "Switch between your previous reports and anonymous community information.",
              icon: Icons.tab,
              color: AppTheme.info,
            ),
            CoachMarkStep(
              targetKey: reportSymptomsButtonKey,
              title: "Report Symptoms",
              description:
                  "Open the guided self-report form to submit symptoms and location information.",
              icon: Icons.add_circle_outline,
              color: AppTheme.warning,
            ),
          ],
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final pagePadding = Responsive.pagePadding(context);
    final headerRadius = Responsive.isLandscapePhone(context) ? 24.0 : 45.0;
    final contentMargin = Responsive.isLandscapePhone(context)
        ? EdgeInsets.fromLTRB(pagePadding, 8, pagePadding, 8)
        : EdgeInsets.all(pagePadding * 0.8);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Column(
              children: [
                // HEADER
                KeyedSubtree(
                  key: dataHeaderKey,
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
                          Responsive.verticalGap(context, 20, compact: 12),
                        ),
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
                              child: Text(context.tr("Back")),
                            ),

                            SizedBox(
                              height: Responsive.verticalGap(context, 8),
                            ),

                            Image.asset(
                              'assets/images/healthphplusbarlogo.png',
                              height: Responsive.logoHeight(context),
                            ),

                            SizedBox(
                              height: Responsive.verticalGap(context, 8),
                            ),

                            Text(
                              context.tr("Health Contributions"),
                              style: TextStyle(
                                fontSize: Responsive.isLandscapePhone(context)
                                    ? 20
                                    : 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),

                            Text(
                              context.tr("Reports and community health trends"),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Container(
                    margin: contentMargin,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppTheme.border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Theme(
                      data: AppTheme.lightTheme,
                      child: Column(
                        children: [
                          KeyedSubtree(
                            key: dataTabsKey,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TabBar(
                                isScrollable: Responsive.isSmallPhone(context),
                                labelColor: Colors.black,
                                unselectedLabelColor: Colors.grey,
                                indicator: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.indigo,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                tabs: [
                                  Tab(
                                    icon: const Icon(
                                      Icons.assignment_turned_in_outlined,
                                    ),
                                    text: context.tr("My Reports"),
                                  ),
                                  Tab(
                                    icon: const Icon(Icons.groups_outlined),
                                    text: context.tr("Community"),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Expanded(
                            child: KeyedSubtree(
                              key: dataContentKey,
                              child: const TabBarView(
                                children: [_MyReportsTab(), _CommunityTab()],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: KeyedSubtree(
          key: reportSymptomsButtonKey,
          child: FloatingActionButton.extended(
            onPressed: _openSelfReportWizard,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_circle_outline),
            label: Text(context.tr("Report Symptoms")),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

class _MyReportsTab extends StatelessWidget {
  const _MyReportsTab();
  bool get _canExportReports {
    final roleId = ProfileStore.instance.profile?.roleId ?? '';
    return roleId == "field_health_worker" || roleId == "lgu_doh_user";
  }

  Future<void> _exportReports(
    BuildContext context,
    List<SelfReport> reports,
  ) async {
    if (reports.isEmpty) return;

    try {
      final shared = await SelfReportExportService.instance.shareCsv(
        context: context,
        reports: reports,
      );

      if (!context.mounted) return;

      if (shared) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr("Self-reports CSV is ready to share.")),
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr("Unable to export self-reports CSV.")),
        ),
      );
    }
  }

  @override
    Widget build(BuildContext context) {
      return Column(
        children: [
          if (_canExportReports)
            AnimatedBuilder(
              animation: SelfReportStore.instance,
              builder: (context, _) {
                final localReports = SelfReportStore.instance.reports;

                return Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: context.tr('Export CSV'),
                    onPressed: localReports.isEmpty
                        ? null
                        : () => _exportReports(context, localReports),
                    icon: const Icon(Icons.ios_share),
                    color: AppTheme.primary,
                  ),
                );
              },
            ),
          const Expanded(
            child: SelfReportHistoryPage(embedded: true),
          ),
        ],
      );
    }
}

class _CommunityTab extends StatefulWidget {
  const _CommunityTab();

  @override
  State<_CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<_CommunityTab> {
  late Future<List<SurveillancePin>> pinsFuture;

  static const diseaseLabels = <String, String>{
    'TB': 'Tuberculosis',
    'PN': 'Pneumonia',
    'COVID': 'COVID-19',
    'AURI': 'Acute Upper Respiratory Infection',
  };

  @override
  void initState() {
    super.initState();
    pinsFuture = _loadCommunityData();
  }

  Future<List<SurveillancePin>> _loadCommunityData() {
    return HealthPhApiService(
      baseUrl: ApiConfig.baseUrl,
    ).fetchSurveillanceMapPins(days: 30);
  }

  void _retry() {
    setState(() {
      pinsFuture = _loadCommunityData();
    });
  }

  String _regionLabel(String code) {
    if (code == 'NCR') return 'National Capital Region';
    return code.startsWith('Region ') ? code : 'Region $code';
  }

  Widget _metricRow({
    required String label,
    required int value,
    required int total,
    required Color color,
  }) {
    final percentage = total == 0 ? 0 : ((value / total) * 100).round();
    final progress = total == 0
        ? 0.0
        : (value / total).clamp(0.0, 1.0).toDouble();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr(label),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '$value ($percentage%)',
                style: const TextStyle(
                  color: AppTheme.mutedText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SurveillancePin>>(
      future: pinsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  size: 42,
                  color: AppTheme.mutedText,
                ),
                const SizedBox(height: 12),
                Text(
                  context.tr('Unable to load community trends.'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh),
                  label: Text(context.tr('Retry')),
                ),
              ],
            ),
          );
        }

        final pins = snapshot.data ?? const <SurveillancePin>[];

        if (pins.isEmpty) {
          return Center(
            child: Text(
              context.tr(
                'No processed community signals are available for the last 30 days.',
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        final diseaseCounts = <String, int>{
          for (final code in SurveillancePin.diseases) code: 0,
        };
        final regionCounts = <String, int>{};

        for (final pin in pins) {
          for (final entry in pin.diseaseCounts.entries) {
            diseaseCounts.update(
              entry.key,
              (current) => current + entry.value,
              ifAbsent: () => entry.value,
            );
          }

          final region = pin.region?.trim() ?? '';
          if (region.isNotEmpty) {
            regionCounts.update(
              region,
              (current) => current + pin.processedEntryCount,
              ifAbsent: () => pin.processedEntryCount,
            );
          }
        }

        final diseaseRows =
            diseaseCounts.entries.where((entry) => entry.value > 0).toList()
              ..sort((a, b) => b.value.compareTo(a.value));

        final regionRows = regionCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        final diseaseTotal = diseaseRows.fold<int>(
          0,
          (total, entry) => total + entry.value,
        );
        final regionTotal = regionRows.fold<int>(
          0,
          (total, entry) => total + entry.value,
        );

        return RefreshIndicator(
          onRefresh: () async {
            final refreshed = _loadCommunityData();
            setState(() => pinsFuture = refreshed);
            await refreshed;
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              Text(
                context.tr('Community Trends'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                context.tr(
                  'Anonymous processed health signals from the community.',
                ),
                style: const TextStyle(color: AppTheme.mutedText),
              ),
              const SizedBox(height: 22),
              Text(
                context.tr('Top Disease Signals'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              ...diseaseRows
                  .take(4)
                  .map(
                    (entry) => _metricRow(
                      label: diseaseLabels[entry.key] ?? entry.key,
                      value: entry.value,
                      total: diseaseTotal,
                      color: AppTheme.primary,
                    ),
                  ),
              const SizedBox(height: 12),
              Text(
                context.tr('Processed Reports by Region'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              ...regionRows
                  .take(5)
                  .map(
                    (entry) => _metricRow(
                      label: _regionLabel(entry.key),
                      value: entry.value,
                      total: regionTotal,
                      color: AppTheme.success,
                    ),
                  ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.privacy_tip_outlined,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.tr(
                          'Community data is anonymized and aggregated to protect privacy. Disease signals are not confirmed diagnoses.',
                        ),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SelfReportWizard extends StatefulWidget {
  final VoidCallback onSubmitted;

  const _SelfReportWizard({required this.onSubmitted});

  @override
  State<_SelfReportWizard> createState() => _SelfReportWizardState();
}

class _SelfReportWizardState extends State<_SelfReportWizard> {
  final PageController pageController = PageController();
  final notesController = TextEditingController();

  int currentStep = 0;

  bool locationLoaded = false;
  bool reportSubmitting = false;
  LocationOption? selectedRegion;
  LocationOption? selectedProvince;
  LocationOption? selectedCity;
  LocationOption? selectedBarangay;

  LocationDataService get locationService => LocationDataService.instance;
  bool get isNcrSelected => locationService.isNcr(selectedRegion?.code);

  List<LocationOption> get provinceOption =>
      locationService.provincesForRegion(selectedRegion?.code);

  List<LocationOption> get cityOptions => locationService.citiesForProvince(
    selectedRegion?.code,
    selectedProvince?.code,
  );

  List<LocationOption> get barangayOptions => locationService.barangaysForCity(
    selectedRegion?.code,
    selectedProvince?.code,
    selectedCity?.code,
  );

  UserProfile? get currentProfile => ProfileStore.instance.profile;

  bool get isGuestUser {
    final profile = currentProfile;

    return profile == null ||
        AppTaxonomy.isGuestRole(profile.roleId) ||
        profile.email == AppTaxonomy.guestEmail;
  }

  bool get lockAddressFields {
    final profile = currentProfile;
    return !isGuestUser && (profile?.hasAddress ?? false);
  }

  final Set<String> selectedSymptomIds = {};

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    await locationService.load();

    final profile = ProfileStore.instance.profile;

    if (lockAddressFields && profile != null) {
      selectedRegion = locationService.regions
          .where((item) => item.code == profile.regionCode)
          .firstOrNull;

      selectedProvince = locationService
          .provincesForRegion(selectedRegion?.code)
          .where((item) => item.name == profile.province)
          .firstOrNull;

      selectedCity = locationService
          .citiesForProvince(selectedRegion?.code, selectedProvince?.code)
          .where((item) => item.name == profile.city)
          .firstOrNull;

      selectedBarangay = locationService
          .barangaysForCity(
            selectedRegion?.code,
            selectedProvince?.code,
            selectedCity?.code,
          )
          .where((item) => item.name == profile.barangay)
          .firstOrNull;
    }

    if (!mounted) return;

    setState(() {
      locationLoaded = true;
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    notesController.dispose();
    super.dispose();
  }

  AppOption _possibleCondition() {
    final s = selectedSymptomIds;

    if ((s.contains("cough") || s.contains("sore_throat")) &&
        s.contains("fever") &&
        (s.contains("loss_of_taste_or_smell") ||
            s.contains("fatigue") ||
            s.contains("body_aches") ||
            s.contains("shortness_of_breath"))) {
      return AppTaxonomy.possibleConditions[0];
    }

    if (s.contains("cough") &&
        s.contains("fever") &&
        s.contains("chills") &&
        s.contains("fatigue")) {
      return AppTaxonomy.possibleConditions[1];
    }

    if (s.contains("cough_2_weeks") ||
        (s.contains("cough") &&
            s.contains("night_sweats") &&
            s.contains("weight_loss"))) {
      return AppTaxonomy.possibleConditions[2];
    }

    if (s.contains("cough") ||
        s.contains("sore_throat") ||
        s.contains("runny_nose")) {
      return AppTaxonomy.possibleConditions[3];
    }

    return AppTaxonomy.possibleConditions[4];
  }

  bool get _addressComplete {
    return selectedRegion != null &&
        (isNcrSelected || selectedProvince != null) &&
        selectedCity != null &&
        selectedBarangay != null;
  }

  void _showStepError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.tr(message))));
  }

  Future<void> _moveToStep(int targetStep) async {
    if (targetStep > currentStep) {
      if (currentStep == 0 && selectedSymptomIds.isEmpty) {
        _showStepError('Select at least one symptom before continuing.');
        return;
      }

      if (currentStep == 1 && !_addressComplete) {
        _showStepError('Complete your address before continuing.');
        return;
      }
    }

    final safeTarget = targetStep.clamp(0, 2);

    await pageController.animateToPage(
      safeTarget,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleHorizontalSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;

    if (velocity < -350 && currentStep < 2) {
      _moveToStep(currentStep + 1);
    } else if (velocity > 350 && currentStep > 0) {
      _moveToStep(currentStep - 1);
    }
  }

  Future<void> _submitReport() async {
    if (reportSubmitting) return;

    if (selectedRegion == null ||
        (!isNcrSelected && selectedProvince == null) ||
        selectedCity == null ||
        selectedBarangay == null ||
        selectedSymptomIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr("Complete address and add at least one symptoms"),
          ),
        ),
      );
      return;
    }

    setState(() {
      reportSubmitting = true;
    });

    final condition = _possibleCondition();

    try {
      final geocoded = await GeocodingService.instance
          .geocodePhilippinesAddress(
            barangay: selectedBarangay!.name,
            city: selectedCity!.name,
            province: selectedProvince?.name ?? selectedRegion!.name,
          );

      if (!mounted) return;

      final report = SelfReport(
        region: selectedRegion!.code,
        province: selectedProvince?.name ?? selectedRegion!.name,
        city: selectedCity!.name,
        barangay: selectedBarangay!.name,
        latitude: geocoded?.latitude,
        longitude: geocoded?.longitude,
        geocodedAddress: geocoded?.displayName,
        symptomIds: selectedSymptomIds.toList(),
        symptoms: AppTaxonomy.labelsFor(
          AppTaxonomy.symptoms,
          selectedSymptomIds.toList(),
        ),
        possibleConditionId: condition.id,
        possibleCondition: condition.label,
        notes: notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      await HealthPhApiService(baseUrl: ApiConfig.baseUrl).submitSelfReport(
        report: report,
        regionName: selectedRegion!.name,
        provinceCode: selectedProvince?.code,
        cityCode: selectedCity?.code,
        barangayCode: selectedBarangay?.code,
      );
      // Local storage is a cache, not a second backend submission.
      SelfReportStore.instance.addReport(report);
      try {
        await SelfReportDatabase.instance.insertReport(report);
      } catch (_) {
        debugPrint('Report accepted; local cache could not be saved.');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr("Self-report submitted successfully.")),
        ),
      );

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(context.tr("Report submitted")),
          content: Text(
            context.tr(
              "{condition.label} This is not a diagnosis. Please consult a healthcare provider, especially if symptoms worsen.",
              parameters: {"condition.label": context.tr(condition.label)},
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onSubmitted();
              },
              child: Text(context.tr('Understood')),
            ),
          ],
        ),
      );

      setState(() {
        if (!lockAddressFields) {
          selectedRegion = null;
          selectedProvince = null;
          selectedCity = null;
          selectedBarangay = null;
        }

        selectedSymptomIds.clear();
        notesController.clear();
      });
    } on SelfReportSubmissionException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr(error.message))));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Could not confirm submission. Check My Self Reports before trying again.',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => reportSubmitting = false);
    }
  }

  Widget _buildSymptomsStep() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      children: [
        Text(
          context.tr('Select your symptoms'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          context.tr("Select all symptoms you're experiencing."),
          style: const TextStyle(color: AppTheme.mutedText),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppTaxonomy.symptoms.map((symptom) {
            final selected = selectedSymptomIds.contains(symptom.id);

            return FilterChip(
              label: Text(context.tr(symptom.label)),
              selected: selected,
              selectedColor: AppTheme.primary.withValues(alpha: 0.16),
              checkmarkColor: AppTheme.primary,
              onSelected: (checked) {
                setState(() {
                  if (checked) {
                    selectedSymptomIds.add(symptom.id);
                  } else {
                    selectedSymptomIds.remove(symptom.id);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: notesController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: context.tr('Additional notes (optional)'),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressStep() {
    if (!locationLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      children: [
        Text(
          context.tr('Report location'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          context.tr(
            'Select the location where the symptoms were experienced.',
          ),
          style: const TextStyle(color: AppTheme.mutedText),
        ),
        const SizedBox(height: 18),
        if (lockAddressFields) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.22),
              ),
            ),
            child: Text(
              context.tr(
                'Using your registered address. Address fields are locked for account consistency.',
              ),
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        LocationAutocompleteField(
          label: 'Region',
          icon: Icons.map_outlined,
          enabled: !lockAddressFields,
          value: selectedRegion,
          options: locationService.regions,
          onSelected: (value) {
            setState(() {
              selectedRegion = value;
              selectedProvince = null;
              selectedCity = null;
              selectedBarangay = null;
            });
          },
        ),
        const SizedBox(height: 12),
        if (isNcrSelected)
          TextFormField(
            initialValue: 'NCR',
            enabled: false,
            decoration: InputDecoration(
              labelText: context.tr('Province'),
              prefixIcon: const Icon(Icons.location_city_outlined),
            ),
          )
        else
          LocationAutocompleteField(
            label: 'Province',
            icon: Icons.location_city_outlined,
            enabled: !lockAddressFields && selectedRegion != null,
            value: selectedProvince,
            options: provinceOption,
            onSelected: (value) {
              setState(() {
                selectedProvince = value;
                selectedCity = null;
                selectedBarangay = null;
              });
            },
          ),
        const SizedBox(height: 12),
        LocationAutocompleteField(
          refreshKey: '${selectedRegion?.code}_${selectedProvince?.code}',
          label: 'City / Municipality',
          icon: Icons.apartment_outlined,
          enabled:
              !lockAddressFields &&
              (isNcrSelected
                  ? selectedRegion != null
                  : selectedProvince != null),
          value: selectedCity,
          options: cityOptions,
          onSelected: (value) {
            setState(() {
              selectedCity = value;
              selectedBarangay = null;
            });
          },
        ),
        const SizedBox(height: 12),
        LocationAutocompleteField(
          key: ValueKey(
            'wizard_barangay_${selectedRegion?.code}_${selectedProvince?.code}_${selectedCity?.code}',
          ),
          refreshKey:
              '${selectedRegion?.code}_${selectedProvince?.code}_${selectedCity?.code}',
          label: 'Barangay',
          icon: Icons.home_work_outlined,
          enabled: !lockAddressFields && selectedCity != null,
          value: selectedBarangay,
          options: barangayOptions,
          onSelected: (value) {
            setState(() => selectedBarangay = value);
          },
        ),
      ],
    );
  }

  Widget _reviewRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(title),
                  style: const TextStyle(
                    color: AppTheme.mutedText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    final symptoms = AppTaxonomy.labelsFor(
      AppTaxonomy.symptoms,
      selectedSymptomIds.toList(),
    );
    final condition = _possibleCondition();

    final location = [
      selectedBarangay?.name,
      selectedCity?.name,
      selectedProvince?.name,
      selectedRegion?.name,
    ].whereType<String>().where((value) => value.isNotEmpty).join(', ');

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      children: [
        Text(
          context.tr('Review your self-report'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          context.tr('Confirm the information below before submitting.'),
          style: const TextStyle(color: AppTheme.mutedText),
        ),
        const SizedBox(height: 18),
        _reviewRow(
          icon: Icons.sick_outlined,
          title: 'Symptoms',
          value: symptoms.map(context.tr).join(', '),
        ),
        _reviewRow(
          icon: Icons.location_on_outlined,
          title: 'Location',
          value: location,
        ),
        _reviewRow(
          icon: Icons.medical_information_outlined,
          title: 'Possible condition',
          value: context.tr(condition.label),
        ),
        _reviewRow(
          icon: Icons.notes_outlined,
          title: 'Additional notes',
          value: notesController.text.trim().isEmpty
              ? context.tr('No additional notes provided.')
              : notesController.text.trim(),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.warning.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            context.tr(
              'This result is not a diagnosis. Consult a healthcare provider if symptoms worsen.',
            ),
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const stepTitles = ['Symptoms', 'Address', 'Review'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('Report Symptoms'),
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: context.tr('Close'),
                onPressed: reportSubmitting
                    ? null
                    : () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${context.tr("Step")} ${currentStep + 1} ${context.tr("of")} 3: '
            '${context.tr(stepTitles[currentStep])}',
            style: const TextStyle(color: AppTheme.mutedText),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Container(
                  height: 5,
                  margin: EdgeInsets.only(right: index == 2 ? 0 : 7),
                  decoration: BoxDecoration(
                    color: index <= currentStep
                        ? AppTheme.primary
                        : AppTheme.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: _handleHorizontalSwipe,
              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => currentStep = index);
                },
                children: [
                  _buildSymptomsStep(),
                  _buildAddressStep(),
                  _buildReviewStep(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (currentStep > 0)
                OutlinedButton.icon(
                  onPressed: reportSubmitting
                      ? null
                      : () => _moveToStep(currentStep - 1),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(context.tr('Back')),
                ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: reportSubmitting
                    ? null
                    : currentStep == 2
                    ? _submitReport
                    : () => _moveToStep(currentStep + 1),
                icon: reportSubmitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        currentStep == 2
                            ? Icons.send_outlined
                            : Icons.arrow_forward,
                      ),
                label: Text(
                  context.tr(
                    reportSubmitting
                        ? 'Submitting...'
                        : currentStep == 2
                        ? 'Submit Self Report'
                        : 'Next',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}