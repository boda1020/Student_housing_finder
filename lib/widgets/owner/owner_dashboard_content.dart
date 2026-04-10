import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../providers/property_provider.dart';
import '../../screens/common/filter_screen.dart';

class OwnerDashboardContent extends StatelessWidget {
  const OwnerDashboardContent({
    super.key,
    required this.properties,
    required this.favorites,
    required this.onToggleFavorite,
    required this.onAddProperty,
    required this.onSearchChanged,
    required this.searchQuery,
    required this.onOpenFilters,
    required this.onToggleLanguage,
    required this.onOpenNotifications,
    required this.onPropertyTap,
    required this.isArabic,
    required this.t,
    required this.filters,
  });

  final List<Property> properties;
  final Set<String> favorites;
  final void Function(String propertyId) onToggleFavorite;
  final VoidCallback onAddProperty;
  final void Function(String value) onSearchChanged;
  final String searchQuery;
  final VoidCallback onOpenFilters;
  final VoidCallback onToggleLanguage;
  final VoidCallback onOpenNotifications;
  final void Function(Property property) onPropertyTap;
  final bool isArabic;
  final String Function(String key) t;
  final FilterValues filters;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final filteredProperties = properties.where((property) {
      if (searchQuery.isNotEmpty) {
        final lower = searchQuery.toLowerCase();
        if (!property.title.toLowerCase().contains(lower) &&
            !property.address.toLowerCase().contains(lower)) {
          return false;
        }
      }
      if (property.price < filters.priceRange.start || property.price > filters.priceRange.end) {
        return false;
      }
      if (property.distanceToUniversity > filters.maxDistance) {
        return false;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 15, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('app.title'),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          t('app.subtitle'),
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: onOpenNotifications,
                        icon: Icon(Icons.notifications_none, color: isDark ? Colors.white : Colors.black, size: 26),
                      ),
                      TextButton(
                        onPressed: onToggleLanguage,
                        child: Text(
                          isArabic ? 'English' : 'ع',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2530) : const Color(0xFFF0F2F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        onChanged: onSearchChanged,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: t('search.placeholder'),
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FilterScreen(
                            initialFilters: filters,
                            onApply: (newFilters) {
                              onOpenFilters(); // Using callback to notify parent
                            },
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2530) : const Color(0xFFF0F2F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.tune, color: isDark ? Colors.white : Colors.black, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onAddProperty,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.black : Colors.white, // Inverted: Black in Dark, White in Light
                    foregroundColor: isDark ? Colors.white : Colors.black, // Inverted text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 22, color: isDark ? Colors.white : Colors.black),
                      const SizedBox(width: 10),
                      Text(t('add.property'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                '${filteredProperties.length} ${t('properties.available')}',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        Expanded(
          child: filteredProperties.isEmpty 
            ? const Center(child: Text('No properties found'))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: filteredProperties.length,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final property = filteredProperties[index];
                  return _DashboardPropertyCard(
                    property: property,
                    onTap: () => onPropertyTap(property),
                    isDark: isDark,
                  );
                },
              ),
        ),
      ],
    );
  }
}

class _DashboardPropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  final bool isDark;

  const _DashboardPropertyCard({
    required this.property,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE9ECEF)),
          boxShadow: isDark ? null : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    property.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey[900],
                      child: const Icon(Icons.image, color: Colors.white24, size: 50),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C853),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      property.status,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.favorite_border, size: 20, color: Colors.black87),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(property.address, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${property.distanceToUniversity} km from university', 
                        style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '\$${property.price.toInt()}',
                              style: const TextStyle(
                                color: Color(0xFF2979FF),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text: '/per month',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : const Color(0xFFF0F2F5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          property.roomType,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
