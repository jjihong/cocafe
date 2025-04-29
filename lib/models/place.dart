class Place {
  final String name;
  final String address;
  final String? roadAddress;
  final String? phone;

  Place({
    required this.name,
    required this.address,
    this.roadAddress,
    this.phone,
  });

  factory Place.fromJson(Map<String, dynamic> json) => Place(
    name: json['place_name'] as String,
    address: json['address_name'] as String,
    roadAddress: json['road_address_name'] as String?,
    phone: json['phone'] as String?,
  );
}
