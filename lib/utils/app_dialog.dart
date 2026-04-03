import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class AppDialog {
  static Future<void> showConfirmDialog({
    required String title,
    required String message,
    required VoidCallback onOk,
    String okText = "Yes",
    String cancelText = "No",
    bool autoClose = true,
  }) async {
    await Get.dialog(
      CupertinoAlertDialog(
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Get.back(),
            child: Text(
              cancelText,
              style: const TextStyle(color: CupertinoColors.systemRed),
            ),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              if (autoClose) Get.back();
              onOk();
            },
            child: Text(
              okText,
              style: const TextStyle(color: CupertinoColors.systemRed),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
