import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/maplinkcontroller.dart';
import '../../screens/feed/detail.dart';

class LikedMarkerModal extends StatelessWidget {
  final String postId;

  const LikedMarkerModal({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📌 마커 Post ID: $postId',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            // 👉 버튼 1: 네이버 지도 보기
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final controller =
                      MapLinkController(); // 또는 Get.put(MapLinkController())
                  await controller.openNaverMapSearch(postId);
                },
                icon: const Icon(Icons.map),
                label: const Text("네이버 지도에서 보기"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 👉 버튼 2: 좋아요한 글 보기
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => PostDetail(postId: postId));
                },
                icon: const Icon(Icons.favorite),
                label: const Text("좋아요한 글 보기"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
