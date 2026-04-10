import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/property_service.dart';
import '../../models/property_model.dart';
import '../../providers/app_provider.dart';
import '../../screens/owner/add_property_screen.dart';
import '../../screens/owner/owner_properties_screen.dart';
import '../../screens/owner/owner_profile_screen.dart';
import '../../screens/property_details_screen.dart';
import '../../screens/common/notifications_screen.dart';
import '../../screens/chat/chat_list_screen.dart';
import '../../widgets/filter/filter_panel.dart';
import '../../widgets/owner/owner_dashboard_content.dart';
import '../../providers/property_provider.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _currentIndex = 0;
  bool _loading = true;
  String _searchQuery = '';
  
  final String _ownerName = 'Abdulrahman Khamis';
  final String _ownerEmail = 'bdalrhmanhkames@gmail.com';
  final String _ownerPhone = '+20 1201332850';

  List<Property> _properties = [];
  final Set<String> _favorites = {};
  final _propertyService = PropertyService();

  FilterValues _filters = FilterValues(
    priceRange: const RangeValues(0, 5000),
    maxDistance: 20,
    roomTypes: [],
    facilities: [],
  );

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() => _loading = true);
    try {
      final properties = await _propertyService.fetchOwnerProperties();
      setState(() {
        _properties = properties;
      });
    } catch (e) {
      debugPrint('Error loading owner properties: $e');
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

  void _openFilters() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddPropertyScreen()),
    );

    if (result == true) {
      _loadProperties();
    }
  }

  void _onOpenNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
  }

  Future<void> _openMyProperties() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const OwnerPropertiesScreen()),
    );
    _loadProperties();
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
    final appProvider = Provider.of<AppProvider>(context);
    final t = appProvider.translate;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).cardColor,
        selectedItemColor: const Color(0xFF2979FF),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_filled), label: t('home')),
          BottomNavigationBarItem(icon: const Icon(Icons.favorite), label: t('favorites')),
          BottomNavigationBarItem(icon: const Icon(Icons.chat_bubble), label: t('messages')),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: t('profile')),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2979FF)))
            : _buildBody(appProvider, t),
      ),
    );
  }

  Widget _buildBody(AppProvider appProvider, String Function(String) t) {
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
          onToggleLanguage: appProvider.toggleLanguage,
          onOpenNotifications: _onOpenNotifications,
          onPropertyTap: _openPropertyDetails,
          isArabic: appProvider.isArabic,
          t: t,
          filters: _filters,
        );
      case 1:
        return Center(child: Text(t('favorites'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface)));
      case 2:
        return const ChatListScreen();
      case 3:
      default:
        return OwnerProfileScreen(
          name: _ownerName,
          email: _ownerEmail,
          phone: _ownerPhone,
          isArabic: appProvider.isArabic,
          isDarkMode: appProvider.isDarkMode,
          onToggleLanguage: appProvider.toggleLanguage,
          onToggleTheme: (val) => appProvider.toggleTheme(),
          onLogout: () {
            // Implement logout logic
          },
          onMyProperties: _openMyProperties,
        );
    }
  }
}
