// post_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String title;
  final String shopName;
  final String address;
  final String content;
  final String recommendMenu;
  final List<String> tags;
  final List<String> photos; // 이제 이 필드를 사용
  final int likeCount;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String lat;
  final String lng;
  final String region1; // ✏️ 추가
  final String region2; // ✏️ 추가
  final String region3; // ✏️ 추가
  final String bcode;   // ✏️ 추가

  PostModel({
    required this.id,
    required this.title,
    required this.shopName,
    required this.address,
    required this.content,
    required this.recommendMenu,
    required this.tags,
    required this.photos,
    required this.likeCount,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.lat,
    required this.lng,
    required this.region1,
    required this.region2,
    required this.region3,
    required this.bcode,
  });

  /// Firestore 읽기용
  factory PostModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;

    return PostModel(
      id: snap.id,
      title: data['title'] ?? '',
      shopName: data['shop_name'] ?? '',
      address: data['address'] ?? '',
      content: data['content'] ?? '',
      recommendMenu: data['recommend_menu'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      photos: List<String>.from(data['photos'] ?? []),
      likeCount: data['like_count'] ?? 0,
      userId: data['user_id'] ?? '',
      lat: data['lat'] ?? '',
      lng: data['lng'] ?? '',
      region1: data['region1'] ?? '',
      region2: data['region2'] ?? '',
      region3: data['region3'] ?? '',
      bcode: data['bcode'] ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
    );
  }

  /// Firestore 쓰기용
  Map<String, dynamic> toJson() => {
    'title': title,
    'shop_name': shopName,
    'address': address,
    'content': content,
    'recommend_menu': recommendMenu,
    'tags': tags,
    'photos': photos,
    'like_count': likeCount,
    'user_id': userId,
    'lat': lat,
    'lng': lng,
    'region1': region1,
    'region2': region2,
    'region3': region3,
    'bcode': bcode,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
