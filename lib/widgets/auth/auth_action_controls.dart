import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../theme/app_theme.dart';
import '../../theme/responsive.dart';

class AuthActionControls extends StatelessWidget {
  final bool isRegistering;
  final bool biometricEnabled;
  final VoidCallback onForgotPassword;
  final VoidCallback onSubmit;
  final VoidCallback onBiometricLogin;
  final VoidCallback onContinueAsGuest;
  final VoidCallback onToggleMode;

  const AuthActionControls({
    super.key,
    required this.isRegistering,
    required this.biometricEnabled,
    required this.onForgotPassword,
    required this.onSubmit,
    required this.onBiometricLogin,
    required this.onContinueAsGuest,
    required this.onToggleMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        if (!isRegistering) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onForgotPassword,
              child: Text(context.tr('Forgot password?')),
            ),
          ),
        ],
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: Responsive.buttonHeight(context),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: onSubmit,
            child: Text(
              context.tr(isRegistering ? 'Register' : 'Login'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (!isRegistering && biometricEnabled) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: Responsive.buttonHeight(context),
            child: OutlinedButton.icon(
              onPressed: onBiometricLogin,
              icon: const Icon(Icons.fingerprint),
              label: Text(
                context.tr('Login with Biometrics'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (!isRegistering) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: Responsive.buttonHeight(context),
            child: OutlinedButton.icon(
              onPressed: onContinueAsGuest,
              icon: const Icon(Icons.person_outline),
              label: Text(
                context.tr('Continue as Guest'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
        Center(
          child: TextButton(
            onPressed: onToggleMode,
            child: Text(
              context.tr(
                isRegistering
                    ? 'Already have an account? Login'
                    : 'New User? Create an account',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
