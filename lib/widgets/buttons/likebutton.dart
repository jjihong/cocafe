import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/likecontroller.dart';

// 좋아요 버튼
class LikeButton extends StatelessWidget {
  const LikeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LikeController>(
      builder: (controller) {
        return GestureDetector(
          onTap: () {
            controller.toggleLike(); // 상태 변경
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200), // 부드러운 전환
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: controller.isLiked ? Colors.pink.shade50 : Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  controller.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: controller.isLiked ? Colors.pink : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  "좋아요!",
                  style: TextStyle(
                    fontSize: 16,
                    color: controller.isLiked ? Colors.pink : Colors.black87,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "${controller.likeCount}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
