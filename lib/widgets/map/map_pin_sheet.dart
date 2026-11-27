import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../models/surveillance_pin.dart';
import '../surveillance_pin_details.dart';
import '../weather_widget.dart';

Future<void> showSurveillancePinSheet({
  required BuildContext context,
  required SurveillancePin pin,
}) {
  final region = pin.region?.trim();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    barrierColor: Colors.black.withValues(alpha: 0.12),
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.82,
        minChildSize: 0.40,
        maxChildSize: 0.94,
        builder: (context, controller) {
          return ListView(
            controller: controller,
            padding: EdgeInsets.only(
              bottom: 16 + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              SurveillancePinDetails(
                pin: pin,
                embedded: true,
                onClose: () => Navigator.pop(sheetContext),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              if (region != null && region.isNotEmpty)
                WeatherWidget(
                  key: ValueKey('pin-weather-${pin.id}'),
                  region: region,
                  lockRegion: true,
                  embedded: true,
                )
              else
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    context.tr(
                      'Weather unavailable: this pin has no region code.',
                    ),
                  ),
                ),
            ],
          );
        },
      );
    },
  );
}
