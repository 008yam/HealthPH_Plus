import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../models/surveillance_pin.dart';

const Map<int, String> mapTimelineOptions = {
  1: 'Last 24 hours',
  7: 'Last 7 days',
  30: 'Last 30 days',
};

const List<String> _regionCodes = [
  'all',
  'NCR',
  'I',
  'II',
  'III',
  'IVA',
  'IVB',
  'V',
  'VI',
  'VII',
  'VIII',
  'IX',
  'X',
  'XI',
  'XII',
  'XIII',
  'CAR',
  'BARMM',
];

@immutable
class MapFilterSelection {
  final int days;
  final String region;
  final String disease;

  const MapFilterSelection({
    required this.days,
    required this.region,
    required this.disease,
  });
}

Future<MapFilterSelection?> showMapFilterSheet({
  required BuildContext context,
  required MapFilterSelection initialSelection,
}) {
  var days = initialSelection.days;
  var region = initialSelection.region;
  var disease = initialSelection.disease;

  final formKey = GlobalKey<FormState>();

  return showModalBottomSheet<MapFilterSelection>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, update) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.viewInsetsOf(context).bottom + 20,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.tr('Disease-signal filters'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    key: const ValueKey('surveillance-timeline'),
                    initialValue: days,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: context.tr('Timeline'),
                    ),
                    items: mapTimelineOptions.entries
                        .map(
                          (entry) => DropdownMenuItem<int>(
                            value: entry.key,
                            child: Text(context.tr(entry.value)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        update(() => days = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: region,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: context.tr('Region'),
                    ),
                    items: _regionCodes
                        .map(
                          (code) => DropdownMenuItem<String>(
                            value: code,
                            child: Text(
                              code == 'all' ? context.tr('All regions') : code,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        update(() => region = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: disease,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: context.tr('Disease'),
                    ),
                    items: ['all', ...SurveillancePin.diseases]
                        .map(
                          (code) => DropdownMenuItem<String>(
                            value: code,
                            child: Text(
                              code == 'all' ? context.tr('All diseases') : code,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        update(() => disease = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;

                      Navigator.pop(
                        sheetContext,
                        MapFilterSelection(
                          days: days,
                          region: region,
                          disease: disease,
                        ),
                      );
                    },
                    child: Text(context.tr('Apply')),
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
