// lib/views/post/post_detail.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _likeInitialized = false;
  bool _scrollRestored = false;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  final DetailController detailController = Get.put(DetailController());

  @override
  void initState() {
    super.initState();
    // 1. 이 화면만의 전용 LikeController를 만듭니다. (ID로 구분)
    Get.put(LikeController(), tag: widget.postId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      detailController.fetchPost(widget.postId);
    });
  }

  void _restoreScrollPosition() {
    if (widget.initialScrollOffset > 0 && _scrollController.hasClients) {
      _scrollController.jumpTo(widget.initialScrollOffset);
    }
  }

  void _handleBackPressed() {
    if (widget.historyStack.isNotEmpty) {
      final previousItem = widget.historyStack.last;
      final newHistory = List<HistoryItem>.from(widget.historyStack)..removeLast();
      Navigator.pushReplacement(
        context,
        SlideLeftRoute(
          page: PostDetail(
            postId: previousItem.postId,
            historyStack: newHistory,
            initialScrollOffset: previousItem.scrollOffset,
          ),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();

    // 2. 이 화면의 전용 LikeController만 찾아서 삭제합니다.
    if (Get.isRegistered<LikeController>(tag: widget.postId)) {
      if (Get.isRegistered<LikedMarkerService>()) {
        Get.find<LikedMarkerService>().refresh();
      }
      Get.delete<LikeController>(tag: widget.postId);
    }

    if (Get.isRegistered<DetailController>()) {
      Get.delete<DetailController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBackPressed();
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            GetBuilder<DetailController>(
              builder: (controller) {
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!_scrollRestored) {
                  _scrollRestored = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _restoreScrollPosition();
                  });
                }

                final authC = Get.find<AuthController>();
                final post = controller.post;
                final user = controller.user;
                final photos = post?['photos'] ?? [];

                if (post == null) {
                  return const Center(child: Text('게시글을 불러올 수 없습니다.'));
                }

                if (!_likeInitialized && Get.isRegistered<LikeController>(tag: post['id'])) {
                  _likeInitialized = true;
                  // 3. 내 전용 컨트롤러를 찾아서 초기화합니다.
                  Get.find<LikeController>(tag: post['id']).init(
                    postId_: post['id'],
                    uid_: authC.uid!,
                    initialLiked: detailController.currentUserLikedPosts.contains(post['id']),
                    initialCount: post['like_count'] ?? 0,
                  );
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollUpdateNotification) {
                      setState(() {
                        _scrollOffset = notification.metrics.pixels;
                      });
                    }
                    return true;
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 300.0,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              PageView.builder(
                                controller: _pageController,
                                itemCount: photos.length,
                                onPageChanged: (index) {
                                  setState(() => _currentPage = index);
                                },
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ImageViewer(photos: List<String>.from(photos), initialIndex: index))),
                                    child: Image.network(photos[index], fit: BoxFit.cover, width: double.infinity),
                                  );
                                },
                              ),
                              if (photos.length > 1)
                                Positioned(
                                  bottom: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(24)),
                                    child: Text('${_currentPage + 1} / ${photos.length}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (user != null)
                                  GestureDetector(
                                    onTap: () => Get.to(() => MyPostsScreen(uid: user['uid'], userName: user['name'] ?? '사용자')),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16)),
                                      child: Row(
                                        children: [
                                          CircleAvatar(radius: 24, backgroundImage: NetworkImage(user['profile_img'] ?? ''), backgroundColor: Colors.grey[300]),
                                          const SizedBox(width: 16),
                                          Text(user['name'] ?? '알 수 없음', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 24),
                                Text(post['title'] ?? '', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.5)),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 1.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(children: [Icon(Icons.store, size: 18, color: Colors.grey[600]), const SizedBox(width: 8), Expanded(child: Text(post['shop_name'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)))]),
                                              const SizedBox(height: 8),
                                              Row(children: [Icon(Icons.location_on, size: 16, color: Colors.grey[500]), const SizedBox(width: 8), Expanded(child: Text(post['address'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 14)))]),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            final query = Uri.encodeComponent(post['shop_name'] ?? post['address'] ?? '');
                                            final url = Uri.parse('https://map.naver.com/v5/search/$query');
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(url, mode: LaunchMode.externalApplication);
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12)),
                                            child: Icon(Icons.map_outlined, color: Colors.green[600], size: 24),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(post['content'] ?? '', style: const TextStyle(fontSize: 18, height: 1.6, color: Colors.black87)),
                                const SizedBox(height: 24),
                                if (post['recommend_menu'] != null && post['recommend_menu'].toString().trim().isNotEmpty && post['recommend_menu'] != '없음') ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange[200]!)),
                                    child: Row(
                                      children: [
                                        Icon(Icons.restaurant_menu, color: Colors.orange[700], size: 20),
                                        const SizedBox(width: 12),
                                        Text("추천메뉴", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.orange[700])),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(post['recommend_menu'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                if (post['tags'] != null && (post['tags'] as List).isNotEmpty) ...[
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    children: (post['tags'] as List<dynamic>).map<Widget>((tag) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue[200]!)),
                                        child: Text('#$tag', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.blue[700])),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text('좋아요 15가 넘으면\n검토 후 추천 마크에 추가됩니다.', style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w600, height: 1.2))),
                                      const SizedBox(width: 8),
                                      // 4. LikeButton에게 이 게시물의 ID를 알려줍니다.
                                      LikeButton(postId: post['id']),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 40),
                                RecommendationGrid(
                                  recommendedPosts: controller.recommendedPosts,
                                  currentPostId: widget.postId,
                                  historyStack: widget.historyStack,
                                  scrollController: _scrollController,
                                  onNavigateToPost: (postId, historyStack, initialScrollOffset) {
                                    return PostDetail(postId: postId, historyStack: historyStack, initialScrollOffset: initialScrollOffset);
                                  },
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Builder(
                builder: (context) {
                  final double imageHeight = 300.0;
                  final double statusBarHeight = MediaQuery.of(context).padding.top;
                  final double appBarHeight = kToolbarHeight;
                  const double transitionDistance = 60.0;
                  final double transitionEndOffset = imageHeight - (appBarHeight + statusBarHeight);
                  final double transitionStartOffset = transitionEndOffset - transitionDistance;
                  double progress = 0.0;
                  if (_scrollOffset >= transitionStartOffset) {
                    progress = ((_scrollOffset - transitionStartOffset) / transitionDistance).clamp(0.0, 1.0);
                  }
                  final Color backgroundColor = Color.lerp(Colors.transparent, Colors.white, progress)!;
                  final Color iconColor = Color.lerp(Colors.white, Colors.black, progress)!;
                  final double elevation = progress * 3.0;
                  final SystemUiOverlayStyle statusBarStyle = SystemUiOverlayStyle(
                    statusBarColor: backgroundColor,
                    statusBarIconBrightness: progress > 0.5 ? Brightness.dark : Brightness.light,
                    statusBarBrightness: progress > 0.5 ? Brightness.light : Brightness.dark,
                  );
                  return AnnotatedRegion<SystemUiOverlayStyle>(
                    value: statusBarStyle,
                    child: Container(
                      height: statusBarHeight + kToolbarHeight,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        boxShadow: elevation > 0 ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: elevation, offset: Offset(0, elevation / 2))] : null,
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            IconButton(icon: Icon(Icons.arrow_back, color: iconColor), onPressed: _handleBackPressed),
                            IconButton(
                              icon: Icon(Icons.home_rounded, color: iconColor),
                              onPressed: () => Get.offAllNamed('/'),
                            ),
                            const Spacer(),
                            GetBuilder<DetailController>(
                              builder: (controller) {
                                if (!controller.isMyPost) return const SizedBox.shrink();
                                return PopupMenuButton<String>(
                                  icon: Icon(Icons.more_vert, color: iconColor),
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                    const PopupMenuItem<String>(value: 'edit', child: Text('수정')),
                                    PopupMenuItem<String>(
                                      enabled: false,
                                      height: 1,
                                      child: Container(margin: const EdgeInsets.symmetric(horizontal: 16), height: 0.5, color: Colors.grey[300]),
                                    ),
                                    const PopupMenuItem<String>(value: 'delete', child: Text('삭제')),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}