class CafeModel {
  final int id;
  final String name;
  final String location;
  final double lat;
  final double lng;
  final String description;
  final List<String> imgUrls;
  final List<String> tags;
  final DateTime createdAt;

  CafeModel({
    required this.id,
    required this.name,
    required this.location,
    required this.lat,
    required this.lng,
    required this.description,
    required this.imgUrls,
    required this.tags,
    required this.createdAt,
  });

  factory CafeModel.fromJson(Map<String, dynamic> json) {
    return CafeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      location: json['location'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      description: json['description'] as String,
      imgUrls: List<String>.from(json['img_url'] as List),
      tags: List<String>.from(json['tags'] as List? ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'lat': lat,
      'lng': lng,
      'description': description,
      'img_url': imgUrls,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
    };
  }
}