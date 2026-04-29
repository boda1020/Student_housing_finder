class Property {
  final String id;
  final String title;
  final String description;
  final double price;
  final List<String> images;
  final String location;
  final String ownerId;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.location,
    required this.ownerId,
  });
}
