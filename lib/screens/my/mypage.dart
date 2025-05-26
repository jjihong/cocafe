// ✅ mypage.dart (StatefulWidget으로 리팩터링)
import 'package:cocafe/screens/my/mylikedposts.dart';
import 'package:cocafe/screens/my/mypost.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../controllers/authcontroller.dart';
import 'editprofile.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({Key? key}) : super(key: key);

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists) return;

    setState(() {
      userData = doc.data();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cocafe - 노트북 하기 좋은곳을 공유해요!'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundImage: userData?['profile_img'] != null
                            ? NetworkImage(userData!['profile_img'])
                            : AssetImage('asset/copeng.png') as ImageProvider,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          userData?['name'] ?? '이름 없음',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          Get.to(() => ProfileEditScreen(
                                currentName: userData?['name'],
                                currentImageUrl: userData?['profile_img'],
                              ))?.then((result) {
                            if (result == true) {
                              fetchUserProfile(); // ✅ 수정 후 다시 로드
                            }
                          });
                        },
                        child: Text('프로필 수정',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.article_outlined),
                  title: Text('내가 쓴 글'),
                  onTap: () {
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    final name = userData?['name'] ?? '나';
                    if (uid != null) {
                      Get.to(() => MyPostsScreen(uid: uid, userName: name));
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.favorite_border),
                  title: Text('좋아요 한 글'),
                  onTap: () {
                    Get.to(MyLikedPostsScreen());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('로그아웃'),
                  onTap: () async {
                    await authController.signOut();
                    Get.offAllNamed('/login'); // 로그아웃 후 로그인으로 이동
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete_outline),
                  title: Text('회원탈퇴'),
                  onTap: () {},
                ),
              ],
            ),
    );
  }
}
