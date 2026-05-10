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
import '../../models/property_model.dart';
import '../auth/login_screen.dart';
import 'filter_screen.dart';
import '../../data/services/chat_service.dart';

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
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProperties();
  }

  Future<void> _fetchProperties() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      var query = supabase.from('properties').select('*, profiles(full_name, phone, avatar_url)').eq('is_available', true);
      
      if (_searchQuery.isNotEmpty) {
        query = query.or('title.ilike.%$_searchQuery%,location.ilike.%$_searchQuery%');
      }

      String? filterType;
      if (_selectedCategoryIndex == 1) filterType = 'apartment';
      else if (_selectedCategoryIndex == 2) filterType = 'studio';
      else if (_selectedCategoryIndex == 3) filterType = 'shared';
      else if (_selectedCategoryIndex == 4) filterType = 'villa';

      if (filterType != null) query = query.eq('property_type', filterType);

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
    final isArabic = appProvider.isArabic;

    final List<Widget> screens = [
      _buildExploreBody(appProvider),
      const FavoritesScreen(),
      const ChatListScreen(),
      const ProfileScreen(),
    ];

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        drawer: _buildDrawer(appProvider),
        body: IndexedStack(index: _currentNavIndex, children: screens),
        bottomNavigationBar: _buildBottomNav(appProvider),
      ),
    );
  }

  Widget _buildExploreBody(AppProvider appProvider) {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: _fetchProperties,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded, size: 28),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: Text(appProvider.translate('app_title') ?? "Housing Finder", 
              style: const TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            actions: [
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: supabase
                    .from('notifications')
                    .stream(primaryKey: ['id'])
                    .eq('user_id', supabase.auth.currentUser?.id ?? ''),
                builder: (context, snapshot) {
                  final unreadCount = (snapshot.data ?? []).where((n) => n['is_read'] == false).length;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                        ),
                        icon: const Icon(Icons.notifications_none_rounded),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildSearchRow(appProvider),
                  const SizedBox(height: 24),
                  _buildCategoryChips(appProvider),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => PropertyCard(
                    property: _properties[index],
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: _properties[index]))),
                  ),
                  childCount: _properties.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchRow(AppProvider appProvider) {
    final theme = Theme.of(context);
    final isDark = appProvider.isDarkMode;
    
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2530) : Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _searchController,
              onSubmitted: (val) { 
                setState(() => _searchQuery = val); 
                _fetchProperties(); 
              },
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: appProvider.translate('search_placeholder') ?? 'Search...',
                hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, color: theme.primaryColor, size: 24),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterScreen())),
            icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(AppProvider appProvider) {
    final theme = Theme.of(context);
    final categories = ['all_housing', 'apartments', 'studio', 'shared', 'villas'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(categories.length, (index) {
          final selected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () { setState(() => _selectedCategoryIndex = index); _fetchProperties(); },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF5C61F2) : theme.cardTheme.color,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                appProvider.translate(categories[index]) ?? categories[index],
                style: TextStyle(color: selected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomNav(AppProvider appProvider) {
    return BottomNavigationBar(
      currentIndex: _currentNavIndex,
      onTap: (i) => setState(() => _currentNavIndex = i),
      selectedItemColor: const Color(0xFF5C61F2),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.explore_rounded), 
          label: appProvider.translate('explore')
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.favorite_rounded), 
          label: appProvider.translate('saved')
        ),
        BottomNavigationBarItem(
          icon: StreamBuilder<List<Map<String, dynamic>>>(
            stream: ChatService().getMyChats(),
            builder: (context, snapshot) {
              final chats = snapshot.data ?? [];
              int totalUnread = 0;
              for (var chat in chats) {
                totalUnread += (chat['unread_count'] as int? ?? 0);
              }
              return Badge(
                label: Text(totalUnread.toString()),
                isLabelVisible: totalUnread > 0,
                child: const Icon(Icons.chat_bubble_rounded),
              );
            },
          ),
          label: appProvider.translate('messages'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_rounded), 
          label: appProvider.translate('profile')
        ),
      ],
    );
  }

  Widget _buildDrawer(AppProvider appProvider) {
    final user = supabase.auth.currentUser;
    return Drawer(
      backgroundColor: const Color(0xFF1A1C20),
      child: Column(
        children: [
          // Header matching screenshot: Blue background with Profile Info
          StreamBuilder<Map<String, dynamic>>(
            stream: supabase.from('profiles').stream(primaryKey: ['id']).eq('id', user?.id ?? '').map((l) => l.isNotEmpty ? l.first : {}),
            builder: (context, snapshot) {
              final name = snapshot.data?['full_name'] ?? "User";
              final avatarUrl = snapshot.data?['avatar_url'];
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, bottom: 30),
                color: const Color(0xFF5C61F2),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white24,
                      backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
                      child: (avatarUrl == null || avatarUrl.isEmpty)
                          ? const Icon(Icons.person, size: 45, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "BODA",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          // Language Toggle
          ListTile(
            leading: const Icon(Icons.translate, color: Color(0xFF5C61F2)),
            title: Text(
              appProvider.isArabic ? "English" : "العربية",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            onTap: () => appProvider.toggleLanguage(),
          ),
          // Dark Mode Toggle
          ListTile(
            leading: Icon(
              appProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: const Color(0xFF5C61F2),
            ),
            title: Text(
              appProvider.isArabic
                  ? (appProvider.isDarkMode ? "الوضع الفاتح" : "الوضع الداكن")
                  : (appProvider.isDarkMode ? "Light Mode" : "Dark Mode"),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            trailing: Switch(
              value: appProvider.isDarkMode,
              onChanged: (val) => appProvider.toggleTheme(),
              activeColor: const Color(0xFF5C61F2),
            ),
          ),
          const Spacer(),
          const Divider(color: Colors.white10),
          // Logout at the bottom as seen in screenshot
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: Text(
              appProvider.translate('logout') ?? "Logout",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            onTap: () async {
              await supabase.auth.signOut();
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
}
