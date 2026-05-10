import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/app_provider.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/property_service.dart';
import '../../data/services/chat_service.dart';
import '../auth/login_screen.dart';
import 'settings_screen.dart';
import 'personal_info_screen.dart';
import 'my_reviews_screen.dart';
import 'help_center_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  final _authService = AuthService();
  final _propertyService = PropertyService();
  final _chatService = ChatService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  File? _imageFile;

  // Dynamic Stats for Owner
  int _savedCount = 0;
  int _reviewsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final data = await _supabase.from('profiles').select().eq('id', user.id).single();
        if (mounted) {
          setState(() { 
            _userData = data; 
            _isLoading = false; 
          });
          
          // Load dynamic stats if user is an owner
          if (data['role'] == 'owner') {
            _loadOwnerStats();
          }
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadOwnerStats() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Get owner's properties
      final properties = await _supabase.from('properties').select('id').eq('owner_id', user.id);
      final List<dynamic> propIds = (properties as List).map((p) => p['id']).toList();

      int savedCount = 0;
      int reviewsCount = 0;

      if (propIds.isNotEmpty) {
        // Count how many times these properties were favorited by students
        final favs = await _supabase.from('favorites').select('id').filter('property_id', 'in', propIds);
        savedCount = favs.length;

        // Count reviews for these properties
        final reviews = await _supabase.from('reviews').select('id').filter('property_id', 'in', propIds);
        reviewsCount = reviews.length;
      }

      if (mounted) {
        setState(() {
          _savedCount = savedCount;
          _reviewsCount = reviewsCount;
        });
      }
    } catch (e) {
      debugPrint('Error loading owner stats: $e');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
      _uploadAvatar(File(pickedFile.path));
    }
  }

  Future<void> _uploadAvatar(File file) async {
    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final imageUrl = await _propertyService.uploadImage(file);
      await _supabase.from('profiles').update({'avatar_url': imageUrl}).eq('id', user.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(Provider.of<AppProvider>(context, listen: false).translate('profile_picture_updated') ?? 'Profile picture updated'),
        ));
        _loadUserData();
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = Provider.of<AppProvider>(context, listen: false).translate('upload_failed');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$errorMsg$e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = appProvider.isDarkMode;
    final theme = Theme.of(context);
    final isAr = appProvider.isArabic;
    
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final name = _userData?['full_name'] ?? (isAr ? 'مستخدم' : 'User');
    final email = _supabase.auth.currentUser?.email ?? '';
    final avatarUrl = _userData?['avatar_url'];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(appProvider.translate('profile'), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 20),
          Center(
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.primaryColor.withOpacity(0.2), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    backgroundImage: _imageFile != null 
                        ? FileImage(_imageFile!) 
                        : (avatarUrl != null ? NetworkImage(avatarUrl) : null) as ImageProvider?,
                    child: avatarUrl == null && _imageFile == null
                        ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'U', style: TextStyle(fontSize: 40, color: theme.primaryColor, fontWeight: FontWeight.bold))
                        : null,
                  ),
                ),
                PositionedDirectional(
                  bottom: 5,
                  end: 5,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: theme.primaryColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(email, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          
          if (_userData?['role'] == 'owner') ...[
            StreamBuilder<int>(
              stream: _chatService.getTotalUnreadCount(),
              builder: (context, snapshot) {
                final unreadCount = snapshot.data ?? 0;
                return Row(
                  children: [
                    _buildStatItem(appProvider.translate('saved'), '$_savedCount', Icons.favorite_rounded, Colors.redAccent, theme),
                    _buildStatItem(appProvider.translate('messages'), '$unreadCount', Icons.chat_bubble_rounded, theme.primaryColor, theme),
                    _buildStatItem(appProvider.translate('my_reviews'), '$_reviewsCount', Icons.star_rounded, Colors.orange, theme),
                  ],
                );
              }
            ),
            const SizedBox(height: 30),
          ],
          
          _buildCardSection([
            _buildActionTile(Icons.person_outline_rounded, appProvider.translate('personal_info') ?? "Personal Info", theme, isAr, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalInfoScreen()));
            }),
            _buildActionTile(Icons.star_outline_rounded, appProvider.translate('my_reviews') ?? "My Reviews", theme, isAr, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyReviewsScreen()));
            }),
            _buildActionTile(Icons.settings_outlined, appProvider.translate('settings') ?? "Settings", theme, isAr, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            }),
            _buildActionTile(Icons.help_outline_rounded, appProvider.translate('help_center') ?? "Help Center", theme, isAr, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterScreen()));
            }),
          ], theme),
          
          const SizedBox(height: 24),
          
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.redAccent.withOpacity(0.1)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  await _authService.signOut();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
                    const SizedBox(width: 12),
                    Text(appProvider.translate('logout'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCardSection(List<Widget> children, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActionTile(IconData icon, String title, ThemeData theme, bool isAr, {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap ?? () {},
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: theme.primaryColor, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: Icon(isAr ? Icons.arrow_back_ios_rounded : Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, ThemeData theme) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
