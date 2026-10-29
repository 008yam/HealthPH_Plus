import 'package:flutter/material.dart';
import '../localization/app_translations.dart';
import '../models/surveillance_pin.dart';

class SurveillancePinDetails extends StatelessWidget {
  final SurveillancePin pin;
  final VoidCallback? onClose;
  final bool embedded;

  const SurveillancePinDetails({
    super.key,
    required this.pin,
    this.onClose,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final location = [
      pin.region,
      pin.province,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' · ');
    return SafeArea(
      top: false,
      bottom: !embedded,
      child: SingleChildScrollView(
        primary: embedded ? false : null,
        physics: embedded ? const NeverScrollableScrollPhysics() : null,
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: TextStyle(color: colors.onSurface, fontSize: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr('Processed disease signals'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: context.tr('Close'),
                    onPressed: onClose ?? () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Text(
                location.isEmpty ? pin.id : location,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Text(
                context.tr(
                  '{count} processed entries',
                  parameters: {'count': pin.processedEntryCount},
                ),
              ),
              const SizedBox(height: 12),
              for (final code in SurveillancePin.diseases)
                if (pin.diseaseCodes.contains(code) ||
                    pin.diseaseCounts.containsKey(code))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(child: Text(code)),
                        Text('${pin.diseaseCounts[code] ?? 0}'),
                      ],
                    ),
                  ),
              const SizedBox(height: 12),
              Text(
                context.tr(
                  'Disease signals can overlap across processed entries; these are not patient counts or diagnoses.',
                ),
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
