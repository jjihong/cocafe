// widgets/post/recommendation_grid.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../navigation/slide_routes.dart';

class RecommendationGrid extends StatelessWidget {
  final List<Map<String, dynamic>> recommendedPosts;
  final String currentPostId;
  final List<HistoryItem> historyStack;
  final ScrollController scrollController;
  final Widget Function(String postId, List<HistoryItem> historyStack, double initialScrollOffset) onNavigateToPost;

  const RecommendationGrid({
    super.key,
    required this.recommendedPosts,
    required this.currentPostId,
    required this.historyStack,
    required this.scrollController,
    required this.onNavigateToPost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue[600], size: 22),
              const SizedBox(width: 12),
              Text(
                "이 동네 다른 카페",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recommendedPosts.isEmpty)
            Container(
              height: 100,
              child: Center(
                child: Text(
                  "이 동네에 다른 카페 글이 없습니다",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: recommendedPosts.length,
              itemBuilder: (context, index) {
                final post = recommendedPosts[index];
                final photos = List<String>.from(post['photos'] ?? []);
                final thumbnailUrl = photos.isNotEmpty ? photos[0] : '';
                
                return InkWell(
                  onTap: () {
                    _handleRecommendationTap(context, post);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: thumbnailUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: thumbnailUrl,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image),
                                    ),
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image),
                                  ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  post['shop_name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  post['title'] ?? '',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _handleRecommendationTap(BuildContext context, Map<String, dynamic> post) {
    // 현재 스크롤 위치 저장
    final currentScrollOffset = scrollController.hasClients 
        ? scrollController.offset : 0.0;
    
    // 현재 글을 히스토리에 추가 (스크롤 위치 포함)
    final newHistory = List<HistoryItem>.from(historyStack)
      ..add(HistoryItem(
        postId: currentPostId, 
        scrollOffset: currentScrollOffset,
      ));
    
    print('📚 추천글 탭 시작');
    print('📚 현재 스크롤 위치 저장: $currentScrollOffset');
    print('📚 히스토리 업데이트: $currentPostId → ${post['id']}');
    print('📚 새 히스토리 스택: ${newHistory.length}개');
    
    // 앞으로가기는 오른쪽에서 슬라이드 애니메이션
    Navigator.pushReplacement(
      context,
      SlideRightRoute(
        page: onNavigateToPost(
          post['id'],
          newHistory,
          0.0, // 새 글은 맨 위부터
        ),
      ),
    ).then((_) {
      print('📚 Navigator.pushReplacement 완료');
    }).catchError((e) {
      print('📚 Navigator 오류: $e');
    });
  }
}