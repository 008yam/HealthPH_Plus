import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';

Future<bool> showPasswordResetDialog(
  BuildContext context, {
  required String initialEmail,
}) async {
  final emailController = TextEditingController(text: initialEmail);
  try {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(dialogContext.tr('Rest Password')),
          content: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: dialogContext.tr('Email Addres'),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(dialogContext.tr('Send Link')),
            ),
          ],
        );
      },
    );
    return result ?? false;
  } finally {
    emailController.dispose();
  }
}
