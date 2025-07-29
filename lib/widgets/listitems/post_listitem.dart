import 'package:flutter/material.dart';

class PostListItem extends StatelessWidget {
  final String thumbnailUrl;
  final String title;
  final String shopName;
  final int likeCount;

  const PostListItem({
    super.key,
    required this.thumbnailUrl,
    required this.title,
    required this.shopName,
    required this.likeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white70,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ▷ 1. 이미지가 가로로 꽉 차게
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: thumbnailUrl.startsWith('asset/')
                ? Image.asset(
              thumbnailUrl,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            )
                : Image.network(
              thumbnailUrl,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: double.infinity,
                height: 180,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),

          // ▷ 2. 텍스트 및 좋아요
          Padding(
            padding: const EdgeInsets.all(12),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(shopName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(title,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.favorite, size: 16, color: Colors.red),
                        const SizedBox(width: 4),
                        Text('$likeCount', style: const TextStyle(fontSize: 13)),
                      ],
                    )
                  ],
                ),
                Positioned(
                  top: -14,
                  right: -15,
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      // 수정, 삭제 처리
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('수정')),
                      PopupMenuItem<String>(
                        enabled: false,
                        height: 1,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          height: 0.5,
                          color: Colors.grey[300],
                        ),
                      ),
                      const PopupMenuItem(value: 'delete', child: Text('삭제')),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}