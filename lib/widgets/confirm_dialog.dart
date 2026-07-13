import 'package:flutter/material.dart';
import '../constants/app_palette.dart';
import '../l10n/app_localizations.dart';

/// Shows a simple confirmation dialog styled to match the app.
///
/// Returns `true` if the user confirms, `false` if they cancel or dismiss it.
/// Set [isDestructive] to render the confirm action in a warning color.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool isDestructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => _ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      isDestructive: isDestructive,
    ),
  );
  return result ?? false;
}

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final bool isDestructive;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.isDestructive,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final confirmColor = isDestructive ? const Color(0xFFE05C5C) : const Color(0xFFBC91DB);

    return AlertDialog(
      backgroundColor: context.palette.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: context.palette.textPrimary,
        ),
      ),
      content: Text(
        message,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 1.4,
          color: context.palette.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            l.cancel,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: context.palette.textSecondary,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            confirmLabel,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: confirmColor,
            ),
          ),
        ),
      ],
    );
  }
}
