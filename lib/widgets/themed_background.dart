import 'package:flutter/material.dart';

import '../services/app_settings_store.dart';

class ThemedBackground extends StatelessWidget {
  final Widget child;

  const ThemedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettingsStore.instance,
      builder: (context, _) {
        final mode = AppSettingsStore.instance.visualMode;

        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 450),
                  child: Image.asset(
                  mode.backgroundAsset,
                  key: ValueKey(mode.backgroundAsset),
                  fit: BoxFit.cover,
                  alignment: mode.backgroundAlignment,
                ),
              ),
            ),
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 450),
                color: mode.backgroundOverlayColor,
              ),
            ),
            child,
          ],
        );
      },
    );
  }
}