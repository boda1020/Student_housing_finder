import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/property_model.dart';
import '../../widgets/property/property_card.dart';
import '../../data/services/property_service.dart';
import '../property/property_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final PropertyService _propertyService = PropertyService();
  List<dynamic> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final data = await _propertyService.getFavorites();
      if (mounted) {
        setState(() {
          // فلترة العقارات المتاحة فقط
          _favorites = data.where((f) => 
            f['properties'] != null && f['properties']['is_available'] == true
          ).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final isAr = appProvider.isArabic;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAr ? 'المفضلة' : 'Favorites',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _favorites.isEmpty
          ? _buildEmptyState(appProvider, theme)
          : RefreshIndicator(
              onRefresh: _loadFavorites,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  final favorite = _favorites[index];
                  final propertyData = favorite['properties'];
                  final property = Property.fromJson(propertyData);
                  return PropertyCard(
                    property: property,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PropertyDetailsScreen(property: property),
                        ),
                      ).then((_) => _loadFavorites());
                    },
                    actionButtons: GestureDetector(
                      onTap: () async {
                        await _propertyService.toggleFavorite(property.id);
                        _loadFavorites();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite, color: Colors.redAccent, size: 20),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState(AppProvider appProvider, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 80,
            color: theme.primaryColor.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            appProvider.isArabic ? 'لا توجد مفضلات' : 'No Favorites Yet',
            style: theme.textTheme.titleLarge?.copyWith(color: theme.textTheme.bodySmall?.color),
          ),
          const SizedBox(height: 8),
          Text(
            appProvider.isArabic ? 'استكشف العقارات واضغط على أيقونة القلب!' : 'Explore properties and tap the heart icon!',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(
    BuildContext context,
    Map<String, dynamic> property,
    ThemeData theme,
    AppProvider appProvider,
  ) {
    final images = property['images'] as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty ? images[0] : 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=500';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetailsScreen(property: Property.fromJson(property)),
          ),
        ).then((_) => _loadFavorites()); // Refresh after coming back
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: appProvider.isArabic ? null : 12,
                  left: appProvider.isArabic ? 12 : null,
                  child: GestureDetector(
                    onTap: () async {
                      await _propertyService.toggleFavorite(property['id'].toString());
                      _loadFavorites();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite, color: Colors.redAccent, size: 20),
                    ),
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
                        '${property['price']} ${appProvider.translate('currency')}',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            "4.8", // Static for now
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property['title'] ?? '',
                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: theme.primaryColor.withOpacity(0.6), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        property['location'] ?? '',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
