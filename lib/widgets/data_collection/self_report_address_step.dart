import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../services/location_data_services.dart';
import '../../theme/app_theme.dart';
import '../location_autocomplete_field.dart';

class SelfReportAddressStep extends StatelessWidget {
  final bool locationLoaded;
  final bool lockAddressFields;
  final bool isNcrSelected;

  final LocationOption? selectedRegion;
  final LocationOption? selectedProvince;
  final LocationOption? selectedCity;
  final LocationOption? selectedBarangay;

  final List<LocationOption> regions;
  final List<LocationOption> provinces;
  final List<LocationOption> cities;
  final List<LocationOption> barangays;

  final ValueChanged<LocationOption> onRegionSelected;
  final ValueChanged<LocationOption> onProvinceSelected;
  final ValueChanged<LocationOption> onCitySelected;
  final ValueChanged<LocationOption> onBarangaySelected;

  const SelfReportAddressStep({
    super.key,
    required this.locationLoaded,
    required this.lockAddressFields,
    required this.isNcrSelected,
    required this.selectedRegion,
    required this.selectedProvince,
    required this.selectedCity,
    required this.selectedBarangay,
    required this.regions,
    required this.provinces,
    required this.cities,
    required this.barangays,
    required this.onRegionSelected,
    required this.onProvinceSelected,
    required this.onCitySelected,
    required this.onBarangaySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (!locationLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      children: [
        Text(
          context.tr('Report locaiton'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          context.tr(
            'Selected the location where the symptoms were experienced.',
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
                'Using your registered address. Addres fields are locked for account consistency.',
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
          options: regions,
          onSelected: onRegionSelected,
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
            options: provinces,
            onSelected: onProvinceSelected,
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
          options: cities,
          onSelected: onCitySelected,
        ),
        const SizedBox(height: 12),
        LocationAutocompleteField(
          key: ValueKey(
            'wizard_barangay_'
            '${selectedRegion?.code}_'
            '${selectedProvince?.code}_'
            '${selectedCity?.code}',
          ),
          refreshKey:
              '${selectedRegion?.code}_'
              '${selectedProvince?.code}_'
              '${selectedCity?.code}',
          label: 'Barangay',
          icon: Icons.home_work_outlined,
          enabled: !lockAddressFields && selectedCity != null,
          value: selectedBarangay,
          options: barangays,
          onSelected: onBarangaySelected,
        ),
      ],
    );
  }
}
