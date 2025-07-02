/// ──────────────────────────────────────────────────────────────
///  “좋아요” 마커에 필요한 데이터만 담는 초경량 모델
/// ──────────────────────────────────────────────────────────────
class LikedMarkerData {
  final String  postId;          // 문서 ID
  final double  lat;
  final double  lng;
  final List<String> tags;       // 필터용 태그들

  LikedMarkerData({
    required this.postId,
    required this.lat,
    required this.lng,
    required this.tags,
  });

  /// fromFirestore helper
  factory LikedMarkerData.fromMap(String id, Map<String, dynamic> m) {
    return LikedMarkerData(
      postId: id,
      lat   : double.parse(m['lat'].toString()),
      lng   : double.parse(m['lng'].toString()),
      tags  : List<String>.from(m['tags'] ?? []),
    );
  }
}
