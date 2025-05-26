import 'package:flutter/material.dart';

class CustomSaveDialog extends StatelessWidget {
  final String title;
  final String description;
  final String saveButtonText;
  final String discardButtonText;
  final VoidCallback onSave;
  final VoidCallback onDiscard;

  const CustomSaveDialog({
    super.key,
    required this.title,
    required this.description,
    required this.saveButtonText,
    required this.discardButtonText,
    required this.onSave,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(description),
            const SizedBox(height: 24),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: onSave,
                    child: Text(saveButtonText),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    onPressed: onDiscard,
                    child: Text(discardButtonText, style: const TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
