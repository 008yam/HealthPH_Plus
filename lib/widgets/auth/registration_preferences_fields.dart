import 'package:flutter/material.dart';

import '../../data/app_taxonomy.dart';
import '../../localization/app_translations.dart';

class RegistrationPreferencesFields extends StatelessWidget {
  final AppOption selectedRole;
  final String? selectedLanguage;
  final List<String> languages;
  final ValueChanged<AppOption?> onRoleChanged;
  final ValueChanged<String?> onLanguageChanged;

  const RegistrationPreferencesFields({
    super.key,
    required this.selectedRole,
    required this.selectedLanguage,
    required this.languages,
    required this.onRoleChanged,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<AppOption>(
          initialValue: selectedRole,
          decoration: InputDecoration(
            labelText: context.tr('Role'),
            prefixIcon: const Icon(Icons.badge_outlined),
          ),
          items: AppTaxonomy.roles.map((role) {
            return DropdownMenuItem<AppOption>(
              value: role,
              child: Text(context.tr(role.label)),
            );
          }).toList(),
          onChanged: onRoleChanged,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: selectedLanguage,
          decoration: InputDecoration(
            labelText: context.tr('Preferred Language'),
            prefixIcon: const Icon(Icons.language),
          ),
          items: languages.map((language) {
            return DropdownMenuItem<String>(
              value: language,
              child: Text(language),
            );
          }).toList(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.tr('Select your preferred language');
            }
            return null;
          },
          onChanged: onLanguageChanged,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
