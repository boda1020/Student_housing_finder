import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // الألوان المتناسقة مع هوية التطبيق (Dark Theme)
    const Color backgroundColor = Color(0xFF0F1B2A);
    const Color cardColor = Color(0xFF1E2A3A);
    const Color accentBlue = Color(0xFF2979FF);

    // بيانات تجريبية للعقارات المفضلة
    final List<Map<String, dynamic>> favoriteProperties = [
      {
        'title': 'Modern Studio near University',
        'location': 'Downtown, City Center',
        'price': r'$850/mo',
        'image': 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=500',
        'rating': 4.8,
      },
      {
        'title': 'Spacious 2BR Apartment',
        'location': 'North Side, Academic Area',
        'price': r'$1,200/mo',
        'image': 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=500',
        'rating': 4.5,
      },
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Favorites',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: favoriteProperties.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteProperties.length,
              itemBuilder: (context, index) {
                final property = favoriteProperties[index];
                return _buildFavoriteCard(context, property, cardColor, accentBlue);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          const Text(
            'No favorites yet',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Explore properties and tap the heart icon!',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(
    BuildContext context,
    Map<String, dynamic> property,
    Color cardColor,
    Color accentBlue,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  property['image'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite, color: Colors.red, size: 24),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      property['price'],
                      style: TextStyle(
                        color: accentBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          property['rating'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  property['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white38, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      property['location'],
                      style: const TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
