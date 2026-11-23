import 'package:flutter/material.dart';

import '../../data/app_taxonomy.dart';
import '../../localization/app_translations.dart';
import '../../services/healthph_api_services.dart';
import '../../services/location_data_services.dart';
import '../../services/profile_store.dart';
import 'self_report_symptoms_steps.dart';
import 'self_report_address_step.dart';
import 'self_report_review_step.dart';
import 'self_report_wizard_scaffold.dart';
import '../../services/self_report_submission_service.dart';

class SelfReportWizard extends StatefulWidget {
  final VoidCallback onSubmitted;

  const SelfReportWizard({super.key, required this.onSubmitted});

  @override
  State<SelfReportWizard> createState() => _SelfReportWizardState();
}

class _SelfReportWizardState extends State<SelfReportWizard> {
  final PageController pageController = PageController();
  final notesController = TextEditingController();
  final submissionService = SelfReportSubmissionService();

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
            context.tr('Complete address and add at least one symptom.'),
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
      await submissionService.submit(
        region: selectedRegion!,
        province: selectedProvince,
        city: selectedCity!,
        barangay: selectedBarangay!,
        symptomIds: selectedSymptomIds.toList(),
        condition: condition,
        notes: notesController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Self-report submitted successfully.')),
        ),
      );

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(context.tr('Report submitted')),
            content: Text(
              context.tr(
                '{condition.label} This is not a diagnosis. Please consult a healthcare provider, especially if symptoms worsen.',
                parameters: {'condition.label': context.tr(condition.label)},
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  widget.onSubmitted();
                },
                child: Text(context.tr('Understood')),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

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
    } catch (error, stackTrace) {
      debugPrint('SELF REPORT SUBMISSION ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

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
      if (mounted) {
        setState(() {
          reportSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = <Widget>[
      SelfReportSymptomsStep(
        selectedSymptomIds: selectedSymptomIds,
        notesController: notesController,
        onSymptomChanged: (symptomId, selected) {
          setState(() {
            if (selected) {
              selectedSymptomIds.add(symptomId);
            } else {
              selectedSymptomIds.remove(symptomId);
            }
          });
        },
      ),
      SelfReportAddressStep(
        locationLoaded: locationLoaded,
        lockAddressFields: lockAddressFields,
        isNcrSelected: isNcrSelected,
        selectedRegion: selectedRegion,
        selectedProvince: selectedProvince,
        selectedCity: selectedCity,
        selectedBarangay: selectedBarangay,
        regions: locationService.regions,
        provinces: provinceOption,
        cities: cityOptions,
        barangays: barangayOptions,
        onRegionSelected: (value) {
          setState(() {
            selectedRegion = value;
            selectedProvince = null;
            selectedCity = null;
            selectedBarangay = null;
          });
        },
        onProvinceSelected: (value) {
          setState(() {
            selectedProvince = value;
            selectedCity = null;
            selectedBarangay = null;
          });
        },
        onCitySelected: (value) {
          setState(() {
            selectedCity = value;
            selectedBarangay = null;
          });
        },
        onBarangaySelected: (value) {
          setState(() {
            selectedBarangay = value;
          });
        },
      ),
      SelfReportReviewStep(
        symptomLabels: AppTaxonomy.labelsFor(
          AppTaxonomy.symptoms,
          selectedSymptomIds.toList(),
        ),
        location: [
          selectedBarangay?.name,
          selectedCity?.name,
          selectedProvince?.name,
          selectedRegion?.name,
        ].whereType<String>().where((value) => value.isNotEmpty).join(', '),
        possibleConditionLabel: _possibleCondition().label,
        notes: notesController.text.trim(),
      ),
    ];

    return SelfReportWizardScaffold(
      currentStep: currentStep,
      submitting: reportSubmitting,
      pageController: pageController,
      stepTitles: const ['Symptoms', 'Address', 'Review'],
      steps: steps,
      onPageChanged: (index) {
        setState(() {
          currentStep = index;
        });
      },
      onHorizontalDragEnd: _handleHorizontalSwipe,
      onClose: () => Navigator.of(context).pop(),
      onBack: () => _moveToStep(currentStep - 1),
      onNext: () => _moveToStep(currentStep + 1),
      onSubmit: _submitReport,
    );
  }
}
