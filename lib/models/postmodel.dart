import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String title;
  final String shopName;
  final String address;
  final String content;
  final String recommendMenu;
  final List<String> tags;
  final List<String> photos;    // 이제 이 필드를 사용
  final int likeCount;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String lat;
  final String lng;

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
  });

  /// Firestore 읽기용
  factory PostModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;

    return PostModel(
      id:            snap.id,
      title:         data['title']           ?? '',
      shopName:      data['shop_name']       ?? '',
      address:       data['address']         ?? '',
      content:       data['content']         ?? '',
      recommendMenu: data['recommend_menu']  ?? '',
      tags:          List<String>.from(data['tags']        ?? []),
      photos:     List<String>.from(data['photos'] ?? []),
      likeCount:     data['like_count']      ?? 0,
      userId:        data['user_id']         ?? '',
      lat: data['lat'] ?? '',
      lng: data['lng'] ?? '',
      createdAt:     (data['created_at'] as Timestamp).toDate(),
      updatedAt:     (data['updated_at'] as Timestamp).toDate(),
    );
  }

  /// Firestore 쓰기용
  Map<String, dynamic> toJson() => {
    'title':          title,
    'shop_name':      shopName,
    'address':        address,
    'content':        content,
    'recommend_menu': recommendMenu,
    'tags':           tags,
    'image_urls':     photos,
    'like_count':     likeCount,
    'user_id':        userId,
    'created_at':     createdAt,
    'updated_at':     updatedAt,
    'lat': lat,
    'lng':lng,
  };
}
