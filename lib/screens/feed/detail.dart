import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class PostDetail extends StatefulWidget {
  final String postId;
  const PostDetail({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  final PageController _pageController = PageController(); // ✅ 페이지 추적 컨트롤러
  int _currentPage = 0; // ✅ 현재 페이지 인덱스

  @override
  void dispose() {
    _pageController.dispose(); // ✅ 메모리 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('posts').doc(widget.postId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final post = snapshot.data!.data() as Map<String, dynamic>;
          final List<dynamic> photos = post['photos'] ?? [];

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 300.0,
                backgroundColor: Colors.white,
                elevation: 1,
                centerTitle: true,
                title: Text(
                  post['shop_name'] ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
                foregroundColor: Colors.black,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: photos.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          }); // ✅ 페이지 바뀌면 상태 갱신
                        },
                        itemBuilder: (context, index) {
                          return Image.network(
                            photos[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
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

              // ✅ 본문 영역
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['title'] ?? '',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        post['address'] ?? '',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        post['content'] ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Text("추천메뉴: ${post['recommend_menu'] ?? '없음'}"),
                      const SizedBox(height: 16),

                      // ✅ 좋아요 아이콘 + 수
                      Row(
                        children: [
                          Icon(Icons.favorite_border, color: Colors.red),
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
