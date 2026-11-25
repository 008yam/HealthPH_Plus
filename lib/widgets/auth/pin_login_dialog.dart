import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../services/healthph_api_services.dart';
import '../../services/profile_store.dart';
import '../../theme/app_theme.dart';
import '../six_digit_field.dart';

class PinLoginDialog extends StatefulWidget {
  final HealthPhApiService api;
  final UserProfile profile;

  const PinLoginDialog({super.key, required this.api, required this.profile});

  @override
  State<PinLoginDialog> createState() => _PinLoginDialogState();
}

class _PinLoginDialogState extends State<PinLoginDialog> {
  final pinController = TextEditingController();
  final pinFocusNode = FocusNode();

  bool isVerifying = false;
  String? errorMessage;

  @override
  void dispose() {
    pinController.dispose();
    pinFocusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyPin() async {
    final pin = pinController.text.trim();
    final userId = widget.profile.id;

    if (userId == null || userId.isEmpty) {
      setState(() {
        errorMessage = "Account ID is missing. Please login again.";
      });
      return;
    }

    if (!RegExp(r"^\d{6}$").hasMatch(pin)) {
      setState(() {
        errorMessage = "Enter your complete six-digit PIN.";
      });
      pinFocusNode.requestFocus();
      return;
    }

    setState(() {
      isVerifying = true;
      errorMessage = null;
    });

    try {
      final verifiedProfile = await widget.api.verifyMobileUserPin(
        userId: userId,
        pin: pin,
        accessToken: widget.profile.accessToken,
      );

      if (!mounted) return;
      Navigator.pop(context, verifiedProfile);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isVerifying = false;
        errorMessage =
            "PIN verification failed. Check your connection or sign in again.";
        pinController.clear();
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          pinFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.tr("Enter PIN")),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(
              "Enter the six-digit PIN for {widget.profile.email}.",
              parameters: {"widget.profile.email": widget.profile.email},
            ),
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 18),
          SixDigitPinField(
            controller: pinController,
            focusNode: pinFocusNode,
            enabled: !isVerifying,
            autofocus: true,
            onChanged: (_) {
              if (errorMessage != null) {
                setState(() {
                  errorMessage = null;
                });
              }
            },
            onCompleted: (_) => _verifyPin(),
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
      actions: [
        TextButton(
          onPressed: isVerifying ? null : () => Navigator.pop(context),
          child: Text(context.tr("Cancel")),
        ),
        ElevatedButton(
          onPressed: isVerifying ? null : _verifyPin,
          child: isVerifying
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(context.tr("Verify")),
        ),
      ],
    );
  }
}
