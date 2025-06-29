// post_detail.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/authcontroller.dart';
import '../../controllers/detailcontroller.dart';
import '../../controllers/likecontroller.dart';
import '../../services/likedmarkerservice.dart';
import '../../widgets/imageviewer.dart';
import '../../widgets/buttons/likebutton.dart';
import '../my/mypost.dart';

class PostDetail extends StatefulWidget {
  final String postId;
  const PostDetail({super.key, required this.postId});

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  // 이미지 뷰어 관련 설정 (pagecontroller)
  final PageController _pageController = PageController();
  int _currentPage = 0;
  // 좋아요 버튼 호출 판별
  bool _likeInitialized = false;

  // 게시글 불러오는 DetailController
  final DetailController detailController = Get.put(DetailController());

  // 실행 시
  @override
  void initState() {
    super.initState();
    Get.put(LikeController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      detailController
          .fetchPost(widget.postId); // build 이후 게시글 불러오기(postId, 컨트롤러에 전달)
    });
  }

  // 종료 시
  @override
  void dispose() {
    _pageController.dispose();
    if (Get.isRegistered<LikeController>()) {

      // 지도용 마커 리스트도 새로 불러오기
      if (Get.isRegistered<LikedMarkerService>()) {
        Get.find<LikedMarkerService>().loadLikedMarkers();
      }

      Get.delete<LikeController>();
    }
    super.dispose();
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // GetBuilder는 page를 update하기 위해 사용
      body: GetBuilder<DetailController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }


          final authC = Get.find<AuthController>();

          // getter 함수로 받음.
          final post = controller.post;
          final user = controller.user;
          final photos = post?['photos'] ?? [];

          // post가 null이면 안내.
          if (post == null) {
            return const Center(child: Text('게시글을 불러올 수 없습니다.'));
          }

          /// 좋아요 호출이 안되있거나, LikeController가 등록되지 않으면 true로 바꾸고
          /// init해서 데이터를 넘긴다.
          if (!_likeInitialized && Get.isRegistered<LikeController>()) {
            _likeInitialized = true;
            Get.find<LikeController>().init(
              postId_: post['id'],
              uid_: authC.uid!,      // ← 내 uid 넘기기
              initialLiked: detailController.currentUserLikedPosts.contains(post['id']),
              initialCount: post['like_count'] ?? 0,
            );
          }


          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                // 상태바 지키는 여백
                child: Container(
                  height: MediaQuery.of(context).padding.top,
                  color: Colors.white, // 또는 원하는 배경색
                ),
              ),
              SliverAppBar(
                pinned: true,
                expandedHeight: 300.0,
                backgroundColor: Colors.white,
                elevation: 1,
                centerTitle: true,
                title: const Text(''),
                foregroundColor: Colors.white,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: photos.length,
                        onPageChanged: (index) {
                          _currentPage = index;
                          controller.update();
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
                        // back button
                        top: MediaQuery.of(context).padding.top - 20,
                        left: 4,
                        child: Container(
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () {
                              Get.back();
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
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
                              Get.to(() =>
                                  MyPostsScreen(uid: uid, userName: name));
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
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        post['title'] ?? '',
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1.0),
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
                                final query = Uri.encodeComponent(
                                    post['shop_name'] ?? post['address'] ?? '');
                                final url = Uri.parse(
                                    'https://map.naver.com/v5/search/$query');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url,
                                      mode: LaunchMode.externalApplication);
                                }
                              },
                              child: Transform.translate(
                                offset: const Offset(12, 0), // 픽셀강제 이동
                                child: Image.asset(
                                  'asset/gotomap.png',
                                  width: 56,
                                  height: 56,
                                ),
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
                      Center(
                        // 가운데 정렬
                        child:  LikeButton(),
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
