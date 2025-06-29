import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/postcontroller.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostController>();
    return Obx(() => Container(
          width: double.infinity,
          margin: const EdgeInsets.only(left: 4, right: 4, top: 3, bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: controller.isUploading.value
                  ? null
                  : controller.submitPost, // ✅ 업로드 중일 땐 비활성화
              child: controller.isUploading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ) // ✨ 로딩 인디케이터
                  : const Text(
                      '올리기',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ),
        ));
  }
}
