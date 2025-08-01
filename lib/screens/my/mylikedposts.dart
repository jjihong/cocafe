import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/mylikedpostscontroller.dart';
import '../../widgets/post/listitems/post_listitem.dart';
import '../feed/detail.dart';

class MyLikedPostsScreen extends StatelessWidget {
  const MyLikedPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MyLikedPostsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('내가 좋아요 한 글'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: GetBuilder<MyLikedPostsController>(
        builder: (c) {
          if (c.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (c.myLikedPosts.isEmpty) {
            return const Center(child: Text('좋아요한 글이 없습니다.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: c.myLikedPosts.length,
            itemBuilder: (context, index) {
              final post = c.myLikedPosts[index];
              return GestureDetector(
                onTap: () {
                  Get.to(() => PostDetail(postId: post.id));
                },
                child: PostListItem(
                  thumbnailUrl: post.photos.isNotEmpty
                      ? post.photos.first
                      : 'https://via.placeholder.com/300',
                  title: post.title,
                  shopName: post.shopName,
                  likeCount: post.likeCount,
                  tags: post.tags,
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
          );
        },
      ),
    );
  }
}
