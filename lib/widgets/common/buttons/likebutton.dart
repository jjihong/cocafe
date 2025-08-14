// lib/widgets/common/buttons/likebutton.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/likecontroller.dart';

class LikeButton extends StatelessWidget {
  // postId를 받을 수 있도록 생성자에 추가합니다.
  final String postId;

  const LikeButton({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    // postId를 태그로 사용해 내 전용 컨트롤러를 찾습니다.
    final controller = Get.find<LikeController>(tag: postId);

    return Obx(() {
      return GestureDetector(
        onTap: controller.toggleLike,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: controller.isLiked.value ? Colors.red[400] : Colors.grey[200],
            borderRadius: BorderRadius.circular(24),
            boxShadow: controller.isLiked.value ? [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ] : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                controller.isLiked.value ? Icons.favorite : Icons.favorite_border,
                color: controller.isLiked.value ? Colors.white : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${controller.likeCount.value}',
                style: TextStyle(
                  color: controller.isLiked.value ? Colors.white : Colors.grey[800],
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}