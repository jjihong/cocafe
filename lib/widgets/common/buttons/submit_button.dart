import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/postcontroller.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostController>();
    return Obx(() {
      final isUploading = controller.isUploading.value;
      final isEditMode = controller.isEditMode.value;
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(left: 4, right: 4, top: 3, bottom: 24),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: isUploading
                ? null
                : (isEditMode ? controller.updatePost : controller.createPost),
            child: isUploading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Text(
              isEditMode ? '수정 완료' : '올리기',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      );
    });
  }
}
