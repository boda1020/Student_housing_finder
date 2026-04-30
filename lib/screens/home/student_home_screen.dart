import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/app_provider.dart';
import '../../models/property_model.dart';
import '../property/property_details_screen.dart';
import '../notifications/notifications_screen.dart';
import '../favorites/favorites_screen.dart';
import '../chat/chat_list_screen.dart';
import '../profile/profile_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchProperties();
  }

  Future<void> _fetchProperties() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);

    try {
      final data = await supabase
          .from('properties')
          .select()
          .order('created_at', ascending: false);
      
      if (mounted) {
        setState(() {
          _properties = (data as List).map((json) => Property.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching properties: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading properties: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = appProvider.isDarkMode;
    final isArabic = appProvider.isArabic;
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    final List<Widget> screens = [
      _buildExploreBody(appProvider, theme),
      const FavoritesScreen(),
      const ChatListScreen(),
      const ProfileScreen(),
    ];

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        key: GlobalKey<ScaffoldState>(), // إضافة مفتاح للتحكم في الـ Scaffold
        appBar: _currentNavIndex == 0 ? AppBar(
          centerTitle: true,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(
                Icons.menu_rounded, 
                size: 28, 
                color: isDark ? Colors.white : primaryColor
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Text(
            appProvider.translate('app.title') ?? 'Housing Finder',
            style: TextStyle(
              color: isDark ? Colors.white : primaryColor,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.notifications_none_rounded, 
                size: 28,
                color: isDark ? Colors.white : primaryColor,
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
            ),
            const SizedBox(width: 8),
          ],
        ) : null,
        drawer: _currentNavIndex == 0 ? _buildDrawer(appProvider, theme) : null,
        body: IndexedStack(
          index: _currentNavIndex,
          children: screens,
        ),
        bottomNavigationBar: _buildBottomNav(appProvider, theme),
      ),
    );
  }

  Widget _buildExploreBody(AppProvider appProvider, ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: appProvider.translate('search.campus'),
                    prefixIcon: const Icon(Icons.search_rounded),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterScreen())),
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Icon(Icons.tune_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildCategoryChip(0, appProvider.translate('all.housing'), theme),
              _buildCategoryChip(1, appProvider.translate('apartments'), theme),
              _buildCategoryChip(2, appProvider.translate('shared'), theme),
              _buildCategoryChip(3, appProvider.translate('villas'), theme),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchProperties,
            color: theme.primaryColor,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Promo Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${appProvider.translate('new.listings')}\n${appProvider.translate('near.mit')}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            appProvider.translate('promo.text'),
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                          ),
                        ],
                      ),
                      Positioned(
                        right: appProvider.isArabic ? null : -10,
                        left: appProvider.isArabic ? -10 : null,
                        bottom: -10,
                        child: Icon(Icons.school_rounded, size: 90, color: Colors.white.withOpacity(0.2)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  appProvider.translate('properties.available'),
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(child: Padding(
                    padding: EdgeInsets.only(top: 50.0),
                    child: CircularProgressIndicator(),
                  ))
                else if (_properties.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Column(
                        children: [
                          Icon(Icons.house_siding_rounded, size: 80, color: theme.primaryColor.withOpacity(0.2)),
                          const SizedBox(height: 16),
                          Text(
                            appProvider.isArabic ? 'لا توجد عقارات متاحة حالياً' : 'No properties available right now',
                            style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._properties.map((property) => _buildPropertyCard(property, appProvider, theme)).toList(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(AppProvider appProvider, ThemeData theme) {
    final isArabic = appProvider.isArabic;
    final isDark = appProvider.isDarkMode;
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Ziad+Ahmed&background=random'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isArabic ? 'زياد أحمد' : 'Ziad Ahmed',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: theme.primaryColor),
            title: Text(
              isDark ? appProvider.translate('light.mode') : appProvider.translate('dark.mode'),
            ),
            trailing: Switch(
              value: isDark,
              onChanged: (value) => appProvider.toggleTheme(),
              activeColor: theme.primaryColor,
            ),
          ),
          ListTile(
            leading: Icon(Icons.translate_rounded, color: theme.primaryColor),
            title: Text(
              isArabic ? 'English Language' : 'اللغة العربية',
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: theme.primaryColor.withOpacity(0.5)),
            onTap: () => appProvider.toggleLanguage(),
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: Text(
              appProvider.translate('logout'),
              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
            onTap: () {},
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(int index, String label, ThemeData theme) {
    final selected = _selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? theme.primaryColor : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: selected ? [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : null,
          border: Border.all(
            color: selected ? theme.primaryColor : theme.dividerColor.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyCard(Property property, AppProvider appProvider, ThemeData theme) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: property)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
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
                    property.images.isNotEmpty ? property.images[0] : 'https://api.placeholder.com/400x200',
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 16,
                  left: appProvider.isArabic ? null : 16,
                  right: appProvider.isArabic ? 16 : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      appProvider.translate('verified'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: appProvider.isArabic ? null : 16,
                  left: appProvider.isArabic ? 16 : null,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(Icons.favorite_rounded, color: theme.primaryColor, size: 20),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '\$${property.price.toInt()}',
                              style: TextStyle(color: theme.primaryColor, fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                            TextSpan(
                              text: appProvider.translate('per.month_short'),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 16, color: theme.primaryColor.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Text(property.location, style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildMiniTag(appProvider.translate('free.wifi'), theme),
                      _buildMiniTag(appProvider.translate('gym'), theme),
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

  Widget _buildMiniTag(String label, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: theme.primaryColor, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildBottomNav(AppProvider appProvider, ThemeData theme) {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.explore_rounded, appProvider.translate('explore'), theme),
          _buildNavItem(1, Icons.favorite_rounded, appProvider.translate('saved'), theme),
          _buildNavItem(2, Icons.chat_bubble_rounded, appProvider.translate('messages'), theme),
          _buildNavItem(3, Icons.person_rounded, appProvider.translate('profile'), theme),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, ThemeData theme) {
    final isActive = _currentNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentNavIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? theme.primaryColor.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon, 
              color: isActive ? theme.primaryColor : theme.textTheme.bodySmall?.color?.withOpacity(0.5),
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? theme.primaryColor : theme.textTheme.bodySmall?.color?.withOpacity(0.5),
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
