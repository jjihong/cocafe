import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/mypostscontroller.dart';
import '../../widgets/listitems/post_listitem.dart';
import '../feed/detail.dart';

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MyPostsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('내가 쓴 글'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: GetBuilder<MyPostsController>(
        builder: (c) {
          if (c.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (c.myPosts.isEmpty) {
            return const Center(child: Text('작성한 글이 없습니다.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: c.myPosts.length,
            itemBuilder: (context, index) {
              final post = c.myPosts[index];
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
