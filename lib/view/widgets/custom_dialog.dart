import 'package:flutter/material.dart';

Future<void> showCustomConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  String cancelText = "Batal",
  String confirmText = "Ya",
  Color confirmColor = Colors.red,
  VoidCallback? onConfirm,
  bool dismissible = false,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: dismissible,
    useSafeArea: true,
    useRootNavigator: true,
    builder:
        (BuildContext context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: Text(cancelText),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onConfirm != null) onConfirm();
              },
              child: Text(
                confirmText,
                style: const TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(confirmColor),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: confirmColor),
                  ),
                ),
              ),
            ),
          ],
        ),
  );
}
