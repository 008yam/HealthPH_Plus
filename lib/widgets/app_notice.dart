import 'dart:async';
import 'package:flutter/material.dart';

enum AppNoticeType { success, error, warning, info }

class AppNotice {
  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(
    BuildContext context, {
    required String message,
    AppNoticeType type = AppNoticeType.info,
  }) {
    _timer?.cancel();
    if (_entry?.mounted == true) _entry!.remove();

    final overlay = Overlay.of(context, rootOverlay: true);
    final color = switch (type) {
      AppNoticeType.success => const Color(0xFF16865C),
      AppNoticeType.error => const Color(0xFFD14343),
      AppNoticeType.warning => const Color(0xFFE08A19),
      AppNoticeType.info => const Color(0xFF3478D4),
    };
    final icon = switch (type) {
      AppNoticeType.success => Icons.check_circle_outline,
      AppNoticeType.error => Icons.error_outline,
      AppNoticeType.warning => Icons.warning_amber_rounded,
      AppNoticeType.info => Icons.info_outline,
    };

    late final OverlayEntry entry;

    void dismiss() {
      if (entry.mounted) entry.remove();
      if (identical(_entry, entry)) _entry = null;
      _timer?.cancel();
    }

    entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 0,
        left: 12,
        right: 12,
        child: SafeArea(
          minimum: const EdgeInsets.only(top: 8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: -1, end: 0),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutBack,
            builder: (_, value, child) => Transform.translate(
              offset: Offset(0, value * 80),
              child: child,
            ),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.35)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(icon, color: color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Color(0xFF182236),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: dismiss,
                      icon: const Icon(Icons.close, size: 19),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    _entry = entry;
    overlay.insert(entry);
    _timer = Timer(const Duration(seconds: 4), dismiss);
  }

  static void success(BuildContext context, String message) =>
      show(context, message: message, type: AppNoticeType.success);

  static void error(BuildContext context, String message) =>
      show(context, message: message, type: AppNoticeType.error);

  static void warning(BuildContext context, String message) =>
      show(context, message: message, type: AppNoticeType.warning);

  static void info(BuildContext context, String message) =>
      show(context, message: message, type: AppNoticeType.info);
}