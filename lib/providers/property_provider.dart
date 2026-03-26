import 'package:flutter/material.dart';
import '../data/services/property_service.dart';
import '../models/property_model.dart';

class PropertyProvider extends ChangeNotifier {
  List<Property> _properties = [];
  bool _isLoading = false;
  String _searchQuery = '';
  FilterValues _filters = FilterValues(
    priceRange: const RangeValues(0, 5000),
    maxDistance: 20,
    roomTypes: [],
    facilities: [],
  );

  List<Property> get properties => _properties;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  FilterValues get filters => _filters;

  // Filtered properties based on search and filters
  List<Property> get filteredProperties {
    return _properties.where((property) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final lowerQuery = _searchQuery.toLowerCase();
        if (!property.title.toLowerCase().contains(lowerQuery) &&
            !property.address.toLowerCase().contains(lowerQuery)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Future<void> loadProperties() async {
    _isLoading = true;
    notifyListeners();

    try {
      // استخدام مباشر للـ static method
      _properties = await PropertyService.fetchProperties();
    } catch (e) {
      print('Error loading properties: $e');
      _properties = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilters(FilterValues newFilters) {
    _filters = newFilters;
    notifyListeners();
  }

  void toggleFavorite(String propertyId) {
    // TODO: هتنفذها لما نعمل FavoriteProvider
    notifyListeners();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadProperties();
  }
}

// Filter class
class FilterValues {
  FilterValues({
    required this.priceRange,
    required this.maxDistance,
    required this.roomTypes,
    required this.facilities,
  });

  RangeValues priceRange;
  double maxDistance;
  List<String> roomTypes;
  List<String> facilities;
}