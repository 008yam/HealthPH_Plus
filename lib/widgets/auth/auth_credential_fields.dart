import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../localization/app_translations.dart';
import '../shake_field.dart';
import 'password_requirements.dart';

class AuthCredentialFields extends StatelessWidget {
  final bool isRegistering;
  final bool obscurePassword;
  final GlobalKey<ShakeFieldState> fullNameShakeKey;
  final GlobalKey<ShakeFieldState> emailShakeKey;
  final GlobalKey<ShakeFieldState> passwordShakeKey;
  final GlobalKey<ShakeFieldState> confirmPasswordShakeKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FormFieldValidator<String> fullNameValidator;
  final FormFieldValidator<String> emailValidator;
  final FormFieldValidator<String> passwordValidator;
  final FormFieldValidator<String> confirmPasswordValidator;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onTogglePasswordVisibility;

  const AuthCredentialFields({
    super.key,
    required this.isRegistering,
    required this.obscurePassword,
    required this.fullNameShakeKey,
    required this.emailShakeKey,
    required this.passwordShakeKey,
    required this.confirmPasswordShakeKey,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.fullNameValidator,
    required this.emailValidator,
    required this.passwordValidator,
    required this.confirmPasswordValidator,
    required this.onPasswordChanged,
    required this.onTogglePasswordVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isRegistering)
          ShakeField(
            key: fullNameShakeKey,
            child: TextFormField(
              controller: fullNameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.tr('Full Name'),
                prefixIcon: const Icon(Icons.person_outlined),
              ),
              validator: fullNameValidator,
            ),
          ),
        const SizedBox(height: 13),
        ShakeField(
          key: emailShakeKey,
          child: TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: context.tr('Email'),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            validator: emailValidator,
          ),
        ),
        const SizedBox(height: 13),
        ShakeField(
          key: passwordShakeKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                keyboardType: TextInputType.visiblePassword,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[A-Za-z0-9@!%()#]'),
                  ),
                ],
                onChanged: onPasswordChanged,
                textInputAction: isRegistering
                    ? TextInputAction.next
                    : TextInputAction.done,
                decoration: InputDecoration(
                  errorStyle: const TextStyle(height: 0, fontSize: 0),
                  labelText: context.tr('Password'),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: onTogglePasswordVisibility,
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
                validator: passwordValidator,
              ),
              if (isRegistering) ...[
                const SizedBox(height: 8),
                PasswordRequirements(password: passwordController.text),
              ],
            ],
          ),
        ),
        if (isRegistering) ...[
          const SizedBox(height: 12),
          ShakeField(
            key: confirmPasswordShakeKey,
            child: TextFormField(
              controller: confirmPasswordController,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.tr('Confirm Password'),
                prefixIcon: const Icon(Icons.lock_reset),
              ),
              validator: confirmPasswordValidator,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
