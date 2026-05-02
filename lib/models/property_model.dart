class Property {
  final String id;
  final String title;
  final String description;
  final double price;
  final List<String> images;
  final String location;
  final String ownerId;
  final List<String> amenities;
  final String propertyType;
  final int views;
  final int rooms;
  final int bedsCount;          // عدد الأسرة
  final bool isFurnished;       // هل العقار مفروش؟
  final bool hasReception;
  final bool hasSalon;
  final bool isAvailable;
  final bool isVerified;
  final DateTime? createdAt;
  final String? ownerName;
  final String? ownerPhone;
  final String? ownerAvatar;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.location,
    required this.ownerId,
    this.amenities = const [],
    this.propertyType = 'apartment',
    this.views = 0,
    this.rooms = 1,
    this.bedsCount = 1,
    this.isFurnished = false,
    this.hasReception = false,
    this.hasSalon = false,
    this.isAvailable = true,
    this.isVerified = false,
    this.createdAt,
    this.ownerName,
    this.ownerPhone,
    this.ownerAvatar,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    String? name;
    String? phone;
    String? avatar;
    if (json['profiles'] != null) {
      name = json['profiles']['full_name'];
      phone = json['profiles']['phone'];
      avatar = json['profiles']['avatar_url'];
    }

    return Property(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      location: json['location'] ?? '',
      ownerId: json['owner_id'] ?? '',
      propertyType: json['property_type'] ?? 'apartment',
      amenities: List<String>.from(json['amenities'] ?? []),
      views: json['views'] ?? 0,
      rooms: json['rooms'] ?? 1,
      bedsCount: json['beds_count'] ?? 1,
      isFurnished: json['is_furnished'] ?? false,
      hasReception: json['has_reception'] ?? false,
      hasSalon: json['has_salon'] ?? false,
      isAvailable: json['is_available'] ?? true,
      isVerified: json['is_verified'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      ownerName: name,
      ownerPhone: phone,
      ownerAvatar: avatar,
    );
  }
}
