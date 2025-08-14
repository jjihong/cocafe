import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/likedmarkercontroller.dart';
import '../../../controllers/maplinkcontroller.dart';
import '../../../screens/feed/detail.dart';

class LikedMarkerModal extends StatelessWidget {
  final String postId;
  const LikedMarkerModal({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    // ✅ 인스턴스를 바로 주입
    final LikedMarkerController c =
    Get.put(LikedMarkerController(postId), tag: postId);

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Obx(() {
          if (c.isLoading.value) {
            return const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (c.errorMsg.isNotEmpty || c.post.value == null) {
            return _ErrorArea(
                msg: c.errorMsg.isNotEmpty ? c.errorMsg.value : '게시글 정보가 없습니다.');
          }

          final post = c.post.value!;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.orange[50],
                    ),
                    child:
                    const Icon(Icons.location_on, color: Colors.orange, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.shopName,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(post.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                            TextStyle(fontSize: 14, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
              
              // 이미지들
              if (post.photos.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: PageView.builder(
                    itemCount: post.photos.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            post.photos[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[100],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[100],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '이미지를 불러올 수 없습니다',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (post.photos.length > 1) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      post.photos.length,
                      (index) => Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
              
              const SizedBox(height: 16),
              Row(
                children: [
                  _ActionBtn(
                    colors: [Colors.green[400]!, Colors.green[600]!],
                    label: '지도보기',
                    icon: Icons.map_outlined,
                    onTap: () async =>
                        MapLinkController().openNaverMapSearch(postId),
                  ),
                  const SizedBox(width: 12),
                  _ActionBtn(
                    colors: [Colors.pink[300]!, Colors.pink[500]!],
                    label: '글보기',
                    icon: Icons.article_outlined,
                    onTap: () => Get.to(() => PostDetail(postId: postId)),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ErrorArea extends StatelessWidget {
  final String msg;
  const _ErrorArea({required this.msg});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 120,
    child: Center(child: Text(msg, textAlign: TextAlign.center)),
  );
}

class _ActionBtn extends StatelessWidget {
  final List<Color> colors;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.colors,
        required this.label,
        required this.icon,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 20),
          label: Text(label,
              style:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
