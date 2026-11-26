import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../services/location_data_services.dart';
import '../location_autocomplete_field.dart';

class RegistrationLocationFields extends StatelessWidget {
  final bool loading;
  final bool isNcrSelected;
  final LocationOption? region;
  final LocationOption? province;
  final LocationOption? city;
  final LocationOption? barangay;
  final List<LocationOption> regions;
  final List<LocationOption> provinces;
  final List<LocationOption> cities;
  final List<LocationOption> barangays;
  final ValueChanged<LocationOption> onRegionSelected;
  final ValueChanged<LocationOption> onProvinceSelected;
  final ValueChanged<LocationOption> onCitySelected;
  final ValueChanged<LocationOption> onBarangaySelected;

  const RegistrationLocationFields({
    super.key,
    required this.loading,
    required this.isNcrSelected,
    required this.region,
    required this.province,
    required this.city,
    required this.barangay,
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
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        LocationAutocompleteField(
          label: 'Region',
          icon: Icons.map_outlined,
          enabled: true,
          value: region,
          options: regions,
          onSelected: onRegionSelected,
        ),
        const SizedBox(height: 12),
        if (isNcrSelected) ...[
          TextFormField(
            initialValue: 'NCR',
            enabled: false,
            decoration: InputDecoration(
              labelText: context.tr('Province'),
              prefixIcon: const Icon(Icons.location_city_outlined),
            ),
          ),
          const SizedBox(height: 12),
        ] else ...[
          LocationAutocompleteField(
            label: 'Province',
            icon: Icons.location_city_outlined,
            enabled: region != null,
            value: province,
            options: provinces,
            onSelected: onProvinceSelected,
          ),
          const SizedBox(height: 12),
        ],
        LocationAutocompleteField(
          key: ValueKey('login_city_${region?.code}_${province?.code}'),
          label: 'City / Municipality',
          icon: Icons.apartment_outlined,
          enabled: isNcrSelected ? region != null : province != null,
          value: city,
          options: cities,
          onSelected: onCitySelected,
        ),
        const SizedBox(height: 12),
        LocationAutocompleteField(
          key: ValueKey(
            'login_barangay_${region?.code}_${province?.code}_${city?.code}',
          ),
          label: 'Barangay',
          icon: Icons.home_work_outlined,
          enabled: city != null,
          value: barangay,
          options: barangays,
          onSelected: onBarangaySelected,
        ),
      ],
    );
  }
}
