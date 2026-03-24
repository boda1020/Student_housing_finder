class Property {
  Property({
    required this.id,
    required this.title,
    required this.address,
    required this.price,
    required this.distanceToUniversity,
    required this.roomType,
    required this.facilities,
    required this.imageUrl,
    this.status = 'Available',
    this.description = '',
  });

  final String id;
  final String title;
  final String address;
  final double price;
  final double distanceToUniversity;
  final String roomType;
  final List<String> facilities;
  final String imageUrl;
  final String status;
  final String description;

  bool get isAvailable => status.toLowerCase() == 'available';

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      address: json['address'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      distanceToUniversity: (json['distance_to_university'] as num?)?.toDouble() ?? 0.0,
      roomType: json['room_type'] ?? '',
      facilities: List<String>.from(json['facilities'] ?? []),
      imageUrl: json['image_url'] ?? '',
      status: json['status'] ?? 'Available',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'price': price,
      'distance_to_university': distanceToUniversity,
      'room_type': roomType,
      'facilities': facilities,
      'image_url': imageUrl,
      'status': status,
      'description': description,
    };
  }

  Property copyWith({
    String? id,
    String? title,
    String? address,
    double? price,
    double? distanceToUniversity,
    String? roomType,
    List<String>? facilities,
    String? imageUrl,
    String? status,
    String? description,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      address: address ?? this.address,
      price: price ?? this.price,
      distanceToUniversity: distanceToUniversity ?? this.distanceToUniversity,
      roomType: roomType ?? this.roomType,
      facilities: facilities ?? this.facilities,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      description: description ?? this.description,
    );
  }
}
