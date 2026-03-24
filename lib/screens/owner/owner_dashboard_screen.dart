import 'package:flutter/material.dart';

import '../../data/services/property_service.dart';
import '../../models/property_model.dart';
import '../../screens/owner/add_property_screen.dart';
import '../../screens/owner/owner_properties_screen.dart';
import '../../screens/owner/owner_profile_screen.dart';
import '../../screens/property_details_screen.dart';
import '../../widgets/filter/filter_panel.dart';
import '../../widgets/owner/owner_dashboard_content.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _currentIndex = 0;
  bool _loading = true;
  bool _isArabic = false;
  bool _isDarkMode = false;
  String _searchQuery = '';
  final String _ownerName = 'Abdulrahman Khamis';
  final String _ownerEmail = 'bdalrhmanhkames@gmail.com';
  final String _ownerPhone = '+20 1201332850';

  List<Property> _properties = [];
  final Set<String> _favorites = {};
  FilterValues _filters = FilterValues(
    priceRange: const RangeValues(0, 5000),
    maxDistance: 20,
    roomTypes: [],
    facilities: [],
  );

  Map<String, String> get _t => _isArabic
      ? {
          'app.title': 'Student Housing Finder',
          'app.subtitle': 'Property Manager',
          'search.placeholder': 'ابحث عن الموقع أو الجامعة...',
          'add.property': 'أضف عقار',
          'properties.available': 'عقار متاح',
          'filter': 'فلتر',
          'notifications': 'الإشعارات',
          'home': 'الرئيسية',
          'favorites': 'المفضلة',
          'messages': 'الرسائل',
          'profile': 'حسابي',
        }
      : {
          'app.title': 'Student Housing Finder',
          'app.subtitle': 'Property Manager',
          'search.placeholder': 'Search by location, university...',
          'add.property': 'Add Property',
          'properties.available': 'Properties Available',
          'filter': 'Filter',
          'notifications': 'Notifications',
          'home': 'Home',
          'favorites': 'Favorites',
          'messages': 'Messages',
          'profile': 'Profile',
        };

  String t(String key) => _t[key] ?? key;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() => _loading = true);

    try {
      final properties = await PropertyService.fetchProperties();
      setState(() {
        _properties = properties;
        if (_properties.isNotEmpty) {
          _favorites.clear();
          _favorites.add(_properties.first.id);
        }
      });
    } catch (_) {
      // If Supabase isn't set up yet, fall back to placeholder data.
      setState(() {
        _properties = [
          Property(
            id: '1',
            title: 'Cozy Studio Apartment Near Campus',
            address: '123 University Ave, College Town',
            price: 650,
            distanceToUniversity: 0.8,
            roomType: 'Studio',
            facilities: ['WiFi', 'AC', 'Washer'],
            imageUrl:
                'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1600&q=80',
            status: 'Available',
          ),
          Property(
            id: '2',
            title: 'Bright 1BR with Study Nook',
            address: '789 College St, Campus District',
            price: 820,
            distanceToUniversity: 1.2,
            roomType: '1BR',
            facilities: ['WiFi', 'Gym', 'Parking'],
            imageUrl:
                'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=1600&q=80',
            status: 'Available',
          ),
        ];
        _favorites.clear();
        if (_properties.isNotEmpty) _favorites.add(_properties.first.id);
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  void _toggleFavorite(String propertyId) {
    setState(() {
      if (_favorites.contains(propertyId)) {
        _favorites.remove(propertyId);
      } else {
        _favorites.add(propertyId);
      }
    });
  }

  void _toggleLanguage() {
    setState(() => _isArabic = !_isArabic);
  }

  void _toggleDarkMode(bool enabled) {
    setState(() => _isDarkMode = enabled);
  }

  void _openFilters() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F1B2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return FilterPanel(
          initialFilters: _filters,
          onApply: (filters) {
            setState(() => _filters = filters);
          },
          onClose: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void _onAddProperty() async {
    final newProperty = await Navigator.of(context).push<Property>(
      MaterialPageRoute(
        builder: (context) => const AddPropertyScreen(),
      ),
    );

    if (newProperty != null) {
      setState(() {
        _properties.insert(0, newProperty);
      });
    }
  }

  void _onOpenNotifications() {
    // TODO: Navigate to notifications screen.
  }

  Future<void> _openMyProperties() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => OwnerPropertiesScreen(
          properties: _properties,
        ),
      ),
    );
    setState(() {});
  }

  void _openPropertyDetails(Property property) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PropertyDetailsScreen(
        property: property,
        isOwner: true,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2A),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: t('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_border),
            label: t('favorites'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat_bubble_outline),
            label: t('messages'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            label: t('profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return OwnerDashboardContent(
          properties: _properties,
          favorites: _favorites,
          onToggleFavorite: _toggleFavorite,
          onAddProperty: _onAddProperty,
          onSearchChanged: (value) => setState(() => _searchQuery = value),
          searchQuery: _searchQuery,
          onOpenFilters: _openFilters,
          onToggleLanguage: _toggleLanguage,
          onOpenNotifications: _onOpenNotifications,
          onPropertyTap: _openPropertyDetails,
          isArabic: _isArabic,
          t: t,
        );
      case 1:
        return Center(
          child: Text(
            t('favorites'),
            style: const TextStyle(color: Colors.white),
          ),
        );
      case 2:
        return Center(
          child: Text(
            t('messages'),
            style: const TextStyle(color: Colors.white),
          ),
        );
      case 3:
      default:
        return OwnerProfileScreen(
          name: _ownerName,
          email: _ownerEmail,
          phone: _ownerPhone,
          isArabic: _isArabic,
          isDarkMode: _isDarkMode,
          onToggleLanguage: _toggleLanguage,
          onToggleTheme: _toggleDarkMode,
          onLogout: () {
            // TODO: Implement logout behavior.
          },
          onMyProperties: _openMyProperties,
        );
    }
  }
}
