// post_detail.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/detailcontroller.dart';
import '../../widgets/Imageviewer.dart';
import '../my/mypost.dart';

class PostDetail extends StatefulWidget {
  final String postId;

  const PostDetail({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  final PageController _pageController = PageController();
  final DetailController detailController = Get.put(DetailController());
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      detailController.fetchPost(widget.postId); // ✅ fetchPost는 build 이후 실행
    });
  } // initState 끝

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  } // dispose 끝

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<DetailController>( // ✅ Obx 제거, GetBuilder로 교체
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final post = controller.post;
          final user = controller.user;
          final photos = post?['photos'] ?? [];

          if (post == null) {
            return const Center(child: Text('게시글을 불러올 수 없습니다.'));
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 300.0,
                backgroundColor: Colors.white,
                elevation: 1,
                centerTitle: true,
                title: const Text(''),
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: photos.length,
                        onPageChanged: (index) {
                          _currentPage = index;
                          controller.update(); // ✅ 페이지 갱신
                        },
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ImageViewer(
                                    photos: List<String>.from(photos),
                                    initialIndex: index,
                                  ),
                                ),
                              );
                            },
                            child: Image.network(
                              photos[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_currentPage + 1} / ${photos.length}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (user != null) ...[
                        GestureDetector(
                          onTap: () {
                            final uid = user['uid'];
                            final name = user['name'] ?? '사용자';

                            if (uid != null) {
                              Get.to(() => MyPostsScreen(uid: uid, userName: name));
                            } else {
                              print('uid 없음');
                            }
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(
                                  user['profile_img'] ?? '',
                                ),
                                backgroundColor: Colors.grey[300],
                              ),
                              const SizedBox(width: 12),
                              Text(
                                user['name'] ?? '알 수 없음',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        post['title'] ?? '',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post['shop_name'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    post['address'] ?? '',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final String query = Uri.encodeComponent(post['shop_name'] ?? post['address'] ?? '');
                                final Uri url = Uri.parse('https://map.naver.com/v5/search/$query');

                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                } else {
                                  print('네이버 지도 열기 실패');
                                }
                              },
                              child: Image.asset(
                                'asset/gotomap.png',
                                width: 56,
                                height: 56,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        post['content'] ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Text("추천메뉴: ${post['recommend_menu'] ?? '없음'}"),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.favorite_border, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            (post['like_count'] ?? 0).toString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
