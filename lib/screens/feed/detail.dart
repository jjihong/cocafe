// post_detail.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/authcontroller.dart';
import '../../controllers/detailcontroller.dart';
import '../../controllers/likecontroller.dart';
import '../../services/likedmarkerservice.dart';
import '../../widgets/post/image_viewer.dart';
import '../../widgets/common/buttons/likebutton.dart';
import '../../widgets/navigation/slide_routes.dart';
import '../../widgets/post/recommendation_grid.dart';
import '../my/mypost.dart';
import 'post.dart';

class PostDetail extends StatefulWidget {
  final String postId;
  final List<HistoryItem> historyStack;
  final double initialScrollOffset;
  
  const PostDetail({
    super.key, 
    required this.postId,
    this.historyStack = const [],
    this.initialScrollOffset = 0.0,
  });

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  // 이미지 뷰어 관련 설정 (pagecontroller)
  final PageController _pageController = PageController();
  int _currentPage = 0;
  // 좋아요 버튼 호출 판별
  bool _likeInitialized = false;
  // 스크롤 위치 복원 완료 판별
  bool _scrollRestored = false;
  
  // 스크롤 위치 관리
  final ScrollController _scrollController = ScrollController();

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
  
  // 스크롤 위치 복원 함수
  void _restoreScrollPosition() {
    if (widget.initialScrollOffset > 0 && _scrollController.hasClients) {
      print('📚 스크롤 위치 즉시 복원: ${widget.initialScrollOffset}');
      _scrollController.jumpTo(widget.initialScrollOffset);
      print('📚 스크롤 위치 복원 완료: ${_scrollController.offset}');
    }
  }

  // 커스텀 뒤로가기 처리
  void _handleBackPressed() {
    if (widget.historyStack.isNotEmpty) {
      // 히스토리에서 이전 글 정보 가져오기
      final previousItem = widget.historyStack.last;
      final newHistory = List<HistoryItem>.from(widget.historyStack)..removeLast();
      
      print('📚 히스토리에서 복원: ${widget.postId} → ${previousItem.postId}');
      print('📚 스크롤 위치 복원: ${previousItem.scrollOffset}');
      print('📚 남은 히스토리: ${newHistory.length}개');
      
      // 뒤로가기는 왼쪽에서 슬라이드 애니메이션
      Navigator.pushReplacement(
        context,
        SlideLeftRoute(
          page: PostDetail(
            postId: previousItem.postId,
            historyStack: newHistory,
            initialScrollOffset: previousItem.scrollOffset,
          ),
        ),
      ).then((_) {
        print('📚 백 네비게이션 완료');
      }).catchError((e) {
        print('📚 백 네비게이션 오류: $e');
      });
    } else {
      print('📚 히스토리 비어있음 - Feed로 복귀');
      Navigator.pop(context); // Feed로 복귀
    }
  }

  // 종료 시
  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    if (Get.isRegistered<LikeController>()) {

      // 지도용 마커 리스트도 새로 불러오기
      if (Get.isRegistered<LikedMarkerService>()) {
        Get.find<LikedMarkerService>().refresh();
      }

      Get.delete<LikeController>();
    }
    // DetailController도 정리
    if (Get.isRegistered<DetailController>()) {
      Get.delete<DetailController>();
    }
    super.dispose();
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('📚 WillPopScope 트리거 - 시스템 뒤로가기');
        _handleBackPressed();
        return false; // 기본 뒤로가기 동작 차단
      },
      child: Scaffold(
      // GetBuilder는 page를 update하기 위해 사용
      body: GetBuilder<DetailController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 데이터 로딩 완료 후 스크롤 위치 복원 (한 번만)
          if (!_scrollRestored) {
            _scrollRestored = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _restoreScrollPosition();
            });
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
            controller: _scrollController,
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
                elevation: 0,
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
                        // 커스텀 뒤로가기 버튼
                        top: MediaQuery.of(context).padding.top - 20,
                        left: 4,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 24, weight: 700),
                          onPressed: _handleBackPressed,
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top - 20,
                        right: 4,
                        child: GetBuilder<DetailController>(
                          builder: (controller) {
                            if (!controller.isMyPost) return const SizedBox.shrink();
                            return PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: Colors.white, size: 24, weight: 700),
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    Get.to(() => Post(postId: controller.post!['id']));
                                    return;
                                  }
                                  if (value == 'delete') {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('게시글 삭제'),
                                        content: const Text('정말 삭제하시겠습니까?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
                                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('삭제')),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await controller.deletePost();
                                      Get.back();
                                      Get.snackbar('삭제 완료', '게시글이 삭제되었습니다.');
                                    }
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Text('수정'),
                                  ),
                                  PopupMenuItem<String>(
                                    enabled: false,
                                    height: 1,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 16),
                                      height: 0.5,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Text('삭제'),
                                  ),
                                ],
                            );
                          },
                        ),
                      ),
                      if (photos.length > 1)
                        Positioned(
                          bottom: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              '${_currentPage + 1} / ${photos.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
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
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundImage: NetworkImage(
                                      user['profile_img'] ?? '',
                                    ),
                                    backgroundColor: Colors.grey[300],
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    user['name'] ?? '알 수 없음',
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Text(
                          post['title'] ?? '',
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.0),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.store, size: 18, color: Colors.grey[600]),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              post['shop_name'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              post['address'] ?? '',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
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
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.map_outlined,
                                      color: Colors.blue[600],
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          post['content'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.restaurant_menu, color: Colors.orange[700], size: 20),
                              const SizedBox(width: 12),
                              Text(
                                "추천메뉴",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange[700],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  post['recommend_menu'] ?? '없음',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // 태그 표시 섹션
                        if (post['tags'] != null && (post['tags'] as List).isNotEmpty) ...[
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: (post['tags'] as List<dynamic>).map<Widget>((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        const SizedBox(height: 16),
                        Center(
                          child: LikeButton(),
                        ),
                        const SizedBox(height: 40),
                        
                        // "이 동네 다른 카페" 섹션
                        RecommendationGrid(
                          recommendedPosts: controller.recommendedPosts,
                          currentPostId: widget.postId,
                          historyStack: widget.historyStack,
                          scrollController: _scrollController,
                          onNavigateToPost: (postId, historyStack, initialScrollOffset) {
                            return PostDetail(
                              postId: postId,
                              historyStack: historyStack,
                              initialScrollOffset: initialScrollOffset,
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }
}