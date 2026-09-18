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
        final screen = MediaQuery.sizeOf(context);
        final isLandscape = screen.width > screen.height;

        return SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [...previousChildren, ?currentChild],
                    );
                  },
                  child: Image.asset(
                    mode.backgroundAsset,
                    key: ValueKey("${mode.backgroundAsset}-$isLandscape"),
                    width: screen.width,
                    height: screen.height,
                    fit: BoxFit.cover,
                    alignment: isLandscape
                        ? Alignment.center
                        : mode.backgroundAlignment,
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
          ),
        );
      },
    );
  }
}
