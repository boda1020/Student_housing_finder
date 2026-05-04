import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/app_provider.dart';
import '../../widgets/property/property_card.dart';
import '../property/property_details_screen.dart';
import '../notifications/notifications_screen.dart';
import '../favorites/favorites_screen.dart';
import '../chat/chat_list_screen.dart';
import '../profile/profile_screen.dart';
import '../../data/services/auth_service.dart';
import '../../models/property_model.dart';
import '../auth/login_screen.dart';
import 'filter_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final supabase = Supabase.instance.client;
  List<Property> _properties = [];
  bool _isLoading = true;
  int _selectedCategoryIndex = 0;
  int _currentNavIndex = 0;
  
  Map<String, dynamic> _activeFilters = {};
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProperties();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProperties() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // جلب العقارات المتاحة فقط للطلاب
      var query = supabase.from('properties').select('*, profiles(full_name, phone, avatar_url)').eq('is_available', true);

      if (_searchQuery.isNotEmpty) {
        query = query.or('title.ilike.%$_searchQuery%,location.ilike.%$_searchQuery%');
      }

      String? filterType;
      if (_selectedCategoryIndex == 1) filterType = 'apartment';
      else if (_selectedCategoryIndex == 2) filterType = 'studio';
      else if (_selectedCategoryIndex == 3) filterType = 'shared';
      else if (_selectedCategoryIndex == 4) filterType = 'villa';

      if (filterType != null) {
        query = query.eq('property_type', filterType);
      } else if (_activeFilters['type'] != null && _activeFilters['type'] != 'All') {
        query = query.eq('property_type', _activeFilters['type'].toString().toLowerCase());
      }

      if (_activeFilters['minPrice'] != null) query = query.gte('price', _activeFilters['minPrice']);
      if (_activeFilters['maxPrice'] != null) query = query.lte('price', _activeFilters['maxPrice']);

      // Furnishing filter
      if (_activeFilters['furnishing'] != null && _activeFilters['furnishing'] != 'All') {
        query = query.eq('is_furnished', _activeFilters['furnishing'] == 'Furnished');
      }

      // Rooms filter
      if (_activeFilters['rooms'] != null && _activeFilters['rooms'] > 0) {
        query = query.eq('rooms', _activeFilters['rooms']);
      }

      // Amenities filter
      if (_activeFilters['amenities'] != null) {
        final Map<String, bool> amenities = Map<String, bool>.from(_activeFilters['amenities']);
        
        // Handle boolean columns separately
        if (amenities['Reception'] == true) query = query.eq('has_reception', true);
        if (amenities['Salon'] == true) query = query.eq('has_salon', true);

        // Filter out boolean columns from the array search
        final List<String> selectedAmenities = amenities.entries
            .where((e) => e.value && e.key != 'Reception' && e.key != 'Salon')
            .map((e) => e.key)
            .toList();
        
        if (selectedAmenities.isNotEmpty) {
          query = query.contains('amenities', selectedAmenities);
        }
      }

      final data = await query.order('created_at', ascending: false);
      
      if (mounted) {
        setState(() {
          _properties = (data as List).map((json) => Property.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = appProvider.isDarkMode;
    final isArabic = appProvider.isArabic;
    final theme = Theme.of(context);

    final List<Widget> screens = [
      _buildExploreBody(appProvider, theme),
      const FavoritesScreen(),
      const ChatListScreen(),
      const ProfileScreen(),
    ];

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: _currentNavIndex == 0 ? AppBar(
          centerTitle: true,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu_rounded, size: 28, color: isDark ? Colors.white : theme.primaryColor),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Text(appProvider.translate('app_title'), style: TextStyle(color: isDark ? Colors.white : theme.primaryColor, fontWeight: FontWeight.bold)),
          actions: [
            _buildNotificationBadge(isDark, theme.primaryColor),
            const SizedBox(width: 8),
          ],
        ) : null,
        drawer: _currentNavIndex == 0 ? _buildDrawer(appProvider, theme) : null,
        body: IndexedStack(index: _currentNavIndex, children: screens),
        bottomNavigationBar: _buildBottomNav(appProvider, theme),
      ),
    );
  }

  Widget _buildNotificationBadge(bool isDark, Color primaryColor) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('notifications').stream(primaryKey: ['id']).eq('user_id', supabase.auth.currentUser?.id ?? ''),
      builder: (context, snapshot) {
        final unreadCount = (snapshot.data ?? []).where((n) => n['is_read'] == false).length;
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.notifications_none_rounded, size: 28, color: isDark ? Colors.white : primaryColor),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8, top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildExploreBody(AppProvider appProvider, ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 10),
        _buildSearchRow(appProvider, theme),
        const SizedBox(height: 20),
        _buildCategoryChips(appProvider, theme),
        const SizedBox(height: 20),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchProperties,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildPromoBanner(appProvider, theme),
                const SizedBox(height: 25),
                Text(appProvider.translate('properties_available'), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                if (_isLoading) const Center(child: Padding(padding: EdgeInsets.only(top: 50.0), child: CircularProgressIndicator()))
                else if (_properties.isEmpty) _buildEmptyState(appProvider, theme)
                else ..._properties.map((property) => PropertyCard(
                  property: property,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: property))),
                )).toList(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchRow(AppProvider appProvider, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) { setState(() => _searchQuery = value); _fetchProperties(); },
              decoration: InputDecoration(
                hintText: appProvider.translate('search_campus'),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); _fetchProperties(); }) : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => FilterScreen(initialFilters: _activeFilters)));
              if (result != null) { setState(() => _activeFilters = result); _fetchProperties(); }
            },
            child: Container(
              height: 56, width: 56,
              decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.tune_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(AppProvider appProvider, ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _categoryChip(0, appProvider.translate('all_housing'), theme),
          _categoryChip(1, appProvider.translate('apartments'), theme),
          _categoryChip(2, appProvider.translate('studio'), theme),
          _categoryChip(3, appProvider.translate('shared'), theme),
          _categoryChip(4, appProvider.translate('villas'), theme),
        ],
      ),
    );
  }

  Widget _categoryChip(int index, String label, ThemeData theme) {
    final selected = _selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () { setState(() => _selectedCategoryIndex = index); _fetchProperties(); },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? theme.primaryColor : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: selected ? theme.primaryColor : theme.dividerColor.withOpacity(0.1)),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : theme.textTheme.bodyMedium?.color?.withOpacity(0.7), fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPromoBanner(AppProvider appProvider, ThemeData theme) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)]), borderRadius: BorderRadius.circular(24)),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${appProvider.translate('new_listings')}\n${appProvider.translate('near_mit')}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              Text(appProvider.translate('promo_text'), style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
            ],
          ),
          PositionedDirectional(end: -10, bottom: -10, child: Icon(Icons.school_rounded, size: 90, color: Colors.white.withOpacity(0.2))),
        ],
      ),
    );
  }

  Widget _buildDrawer(AppProvider appProvider, ThemeData theme) {
    final user = supabase.auth.currentUser;
    return Drawer(
      child: Column(
        children: [
          StreamBuilder<Map<String, dynamic>>(
            stream: supabase.from('profiles').stream(primaryKey: ['id']).eq('id', user?.id ?? '').map((l) => l.isNotEmpty ? l.first : {}),
            builder: (context, snapshot) {
              final name = snapshot.data?['full_name'] ?? appProvider.translate('user');
              final avatarUrl = snapshot.data?['avatar_url'];
              return DrawerHeader(
                decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)])),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 35, 
                        backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null, 
                        child: (avatarUrl == null || avatarUrl.isEmpty) 
                          ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'U', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)) 
                          : null
                      ),
                      const SizedBox(height: 12),
                      Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
              );
            }
          ),
          ListTile(
            leading: Icon(appProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: theme.primaryColor),
            title: Text(appProvider.isDarkMode ? appProvider.translate('light_mode') : appProvider.translate('dark_mode')),
            trailing: Switch(value: appProvider.isDarkMode, onChanged: (value) => appProvider.toggleTheme(), activeColor: theme.primaryColor),
          ),
          ListTile(
            leading: Icon(Icons.translate, color: theme.primaryColor), 
            title: Text(appProvider.isArabic ? 'English' : 'العربية'), 
            onTap: () => appProvider.toggleLanguage()
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: Text(
              appProvider.translate('logout'),
              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              await AuthService().signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBottomNav(AppProvider appProvider, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D23) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (i) => setState(() => _currentNavIndex = i),
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.explore_rounded), label: appProvider.translate('explore')),
          BottomNavigationBarItem(icon: const Icon(Icons.favorite_rounded), label: appProvider.translate('saved')),
          BottomNavigationBarItem(icon: const Icon(Icons.chat_bubble_rounded), label: appProvider.translate('messages')),
          BottomNavigationBarItem(icon: const Icon(Icons.person_rounded), label: appProvider.translate('profile')),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppProvider appProvider, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 60, color: Colors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              appProvider.translate('no_properties_found'),
              style: TextStyle(color: Colors.grey.withValues(alpha: 0.8), fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
