import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cocafe/screens/feed/post.dart';

import '../custom_save_dialog.dart';

class ResumeDraftDialog {
  static Future<void> show({
    required BuildContext context,
    required VoidCallback onDiscardDraft,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomSaveDialog(
        title: '작성 중인 글이 있어요',
        description: '이어 쓰시겠어요?',
        saveButtonText: '이어쓰기',
        discardButtonText: '새로쓰기',
        onSave: () {
          Navigator.of(context).pop();
          Get.to(() => Post());
        },
        onDiscard: () async {
          onDiscardDraft();
          Navigator.of(context).pop();
          Get.to(() => Post());
        },
      ),
    );
  }
}
