// lib/feature/admin/widgets/confirmation_dialog.dart
import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  
  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirmar',
    this.cancelText = 'Cancelar',
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            cancelText,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: Text(
            confirmText,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}