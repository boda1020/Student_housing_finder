class Property {
  final String id;
  final String title;
  final String description;
  final double price;
  final List<String> images;
  final String location;
  final String ownerId;
  final Map<String, bool> amenities;
  final DateTime? createdAt;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.location,
    required this.ownerId,
    this.amenities = const {},
    this.createdAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      location: json['location'] ?? '',
      ownerId: json['owner_id'] ?? '',
      amenities: Map<String, bool>.from(json['amenities'] ?? {}),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}
