import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../theme/app_theme.dart';
import '../six_digit_field.dart';

class SetPinDialog extends StatefulWidget {
  const SetPinDialog({super.key});

  @override
  State<SetPinDialog> createState() => _SetPinDialogState();
}

class _SetPinDialogState extends State<SetPinDialog> {
  final pinController = TextEditingController();
  final passwordController = TextEditingController();

  final pinFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  String? errorMessage;

  String get enteredPin => pinController.text.trim();

  void _submit() {
    final pin = enteredPin;
    final currentPassword = passwordController.text;

    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      setState(() {
        errorMessage = 'Enter all six PIN digits.';
      });

      pinFocusNode.requestFocus();
      return;
    }

    if (currentPassword.isEmpty) {
      setState(() {
        errorMessage = 'Enter your current account password.';
      });

      passwordFocusNode.requestFocus();
      return;
    }

    Navigator.pop(context, (pin: pin, currentPassword: currentPassword));
  }

  @override
  void dispose() {
    pinController.dispose();
    passwordController.dispose();
    pinFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.tr('Set six-digit PIN')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr(
                'Enter a six-digit numeric PIN. Each digit uses a separate box.',
              ),
            ),
            const SizedBox(height: 18),
            SixDigitPinField(
              controller: pinController,
              focusNode: pinFocusNode,
              autofocus: true,
              onChanged: (_) {
                if (errorMessage == null) return;

                setState(() {
                  errorMessage = null;
                });
              },
              onCompleted: (_) {
                passwordFocusNode.requestFocus();
              },
            ),
            const SizedBox(height: 18),
            TextField(
              controller: passwordController,
              focusNode: passwordFocusNode,
              obscureText: true,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: context.tr('Current password'),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              onSubmitted: (_) => _submit(),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                context.tr(errorMessage!),
                style: const TextStyle(color: AppTheme.highRisk, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.tr('Cancel')),
        ),
        ElevatedButton(onPressed: _submit, child: Text(context.tr('Save PIN'))),
      ],
    );
  }
}
