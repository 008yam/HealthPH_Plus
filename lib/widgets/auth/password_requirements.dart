import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../theme/app_theme.dart';

class PasswordRequirements extends StatelessWidget {
  final String password;

  const PasswordRequirements({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final rules = <({String text, bool met})>[
      (
        text: 'Password must contain at least 6 characters',
        met: password.length >= 6,
      ),
      (
        text: 'Password must contain at least 1 capital letter',
        met: RegExp(r'[A-Z]').hasMatch(password),
      ),
      (
        text: 'Password must contain at least 1 small letter',
        met: RegExp(r'[a-z]').hasMatch(password),
      ),
      (
        text: 'Password must contain at least 1 numerical character',
        met: RegExp(r'[0-9]').hasMatch(password),
      ),
      (
        text: 'Password must contain at least 1 symbol: @ ! % ( ) #',
        met: RegExp(r'[@!%()#]').hasMatch(password),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          for (final rule in rules)
            _PasswordRequirement(text: context.tr(rule.text), isMet: rule.met),
        ],
      ),
    );
  }
}

class _PasswordRequirement extends StatelessWidget {
  final String text;
  final bool isMet;

  const _PasswordRequirement({required this.text, required this.isMet});

  @override
  Widget build(BuildContext context) {
    final color = isMet ? AppTheme.success : AppTheme.highRisk;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel_outlined,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
