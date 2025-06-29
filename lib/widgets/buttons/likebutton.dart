// widgets/buttons/likebutton.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../controllers/likecontroller.dart';

class LikeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ctrl = Get.find<LikeController>();
      return GestureDetector(
        onTap: ctrl.toggleLike,              // ) onTap
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200), // ) duration
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // ) padding
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300), // ) border
            borderRadius: BorderRadius.circular(8),          // ) borderRadius
            color: ctrl.isLiked.value
                ? Colors.pink.shade50
                : Colors.white,
          ), // ) BoxDecoration
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                ctrl.isLiked.value
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: ctrl.isLiked.value
                    ? Colors.pink
                    : Colors.grey,
              ), // ) Icon
              const SizedBox(width: 6), // ) SizedBox
              Text("좋아요!"),            // ) Text
              const SizedBox(width: 6), // ) SizedBox
              Text("${ctrl.likeCount.value}"), // ) Text
            ], // ) children
          ), // ) Row
        ), // ) AnimatedContainer
      ); // ) GestureDetector
    }); // ) Obx
  } // ) build()
} // ) class LikeButton 끝