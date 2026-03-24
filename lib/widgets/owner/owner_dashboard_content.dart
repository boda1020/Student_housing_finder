import 'package:flutter/material.dart';

import '../../models/property_model.dart';
import '../property/property_card.dart';

/// The main content area for the Owner Dashboard.
///
/// This keeps the screen lean and makes it easier to reuse parts of the UI.
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

  @override
  Widget build(BuildContext context) {
    final filteredProperties = properties.where((property) {
      if (searchQuery.isNotEmpty) {
        final lower = searchQuery.toLowerCase();
        if (!property.title.toLowerCase().contains(lower) &&
            !property.address.toLowerCase().contains(lower)) {
          return false;
        }
      }
      return true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DashboardHeader(
            isArabic: isArabic,
            onToggleLanguage: onToggleLanguage,
            onOpenNotifications: onOpenNotifications,
            t: t,
          ),
          const SizedBox(height: 20),
          _SearchRow(
            value: searchQuery,
            onChanged: onSearchChanged,
            onFilterTap: onOpenFilters,
            t: t,
          ),
          const SizedBox(height: 20),
          AddPropertyButton(onPressed: onAddProperty, label: t('add.property')),
          const SizedBox(height: 20),
          _PropertiesCount(count: filteredProperties.length, t: t),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: filteredProperties.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final property = filteredProperties[index];
                return PropertyCard(
                  property: property,
                  isFavorite: favorites.contains(property.id),
                  onToggleFavorite: () => onToggleFavorite(property.id),
                  onTap: () => onPropertyTap(property),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.isArabic,
    required this.onToggleLanguage,
    required this.onOpenNotifications,
    required this.t,
  });

  final bool isArabic;
  final VoidCallback onToggleLanguage;
  final VoidCallback onOpenNotifications;
  final String Function(String key) t;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('app.title'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                t('app.subtitle'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[300],
                    ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: onOpenNotifications,
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              tooltip: t('notifications'),
            ),
            const SizedBox(width: 6),
            OutlinedButton(
              onPressed: onToggleLanguage,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                isArabic ? 'EN' : 'ع',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.value,
    required this.onChanged,
    required this.onFilterTap,
    required this.t,
  });

  final String value;
  final void Function(String) onChanged;
  final VoidCallback onFilterTap;
  final String Function(String) t;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: t('search.placeholder'),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF1E2A3A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: const Color(0xFF1E2A3A),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onFilterTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              child: const Icon(Icons.tune, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

class AddPropertyButton extends StatelessWidget {
  const AddPropertyButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onPressed,
        icon: const Icon(Icons.add),
        label: Text(label),
      ),
    );
  }
}

class _PropertiesCount extends StatelessWidget {
  const _PropertiesCount({
    required this.count,
    required this.t,
  });

  final int count;
  final String Function(String key) t;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$count ${t('properties.available')}',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
