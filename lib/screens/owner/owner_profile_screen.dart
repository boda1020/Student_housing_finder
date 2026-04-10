import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/app_provider.dart';
import '../chat/chat_list_screen.dart';
import '../auth/login_screen.dart';

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.isArabic,
    required this.isDarkMode,
    required this.onToggleLanguage,
    required this.onToggleTheme,
    required this.onLogout,
    required this.onMyProperties,
  });

  final String name;
  final String email;
  final String phone;
  final bool isArabic;
  final bool isDarkMode;
  final VoidCallback onToggleLanguage;
  final ValueChanged<bool> onToggleTheme;
  final VoidCallback onLogout;
  final VoidCallback onMyProperties;

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  final _supabase = Supabase.instance.client;
  String? _avatarUrl;
  String _fullName = '';
  String _phone = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fullName = widget.name;
    _phone = widget.phone;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      final data = await _supabase.from('profiles').select().eq('id', userId).maybeSingle();
      if (data != null && mounted) {
        setState(() {
          _fullName = data['full_name'] ?? widget.name;
          _phone = data['phone'] ?? widget.phone;
          _avatarUrl = data['avatar_url'];
        });
      }
    }
  }

  Future<void> _updateAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    
    if (image != null) {
      setState(() => _isLoading = true);
      try {
        final userId = _supabase.auth.currentUser!.id;
        final file = File(image.path);
        final fileName = '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        await _supabase.storage.from('avatars').upload(fileName, file);
        final url = _supabase.storage.from('avatars').getPublicUrl(fileName);
        
        await _supabase.from('profiles').update({'avatar_url': url}).eq('id', userId);
        setState(() => _avatarUrl = url);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final t = appProvider.translate;
    final isDark = appProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A6CF7), Color(0xFFB030B0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: _updateAvatar,
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white24,
                          backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                          child: _avatarUrl == null 
                            ? Text(_fullName.isNotEmpty ? _fullName[0].toUpperCase() : 'A', 
                                style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold))
                            : null,
                        ),
                      ),
                      if (_isLoading)
                        const Positioned.fill(child: CircularProgressIndicator(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(_fullName, 
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(widget.email, 
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.business_center, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text('Property Owner', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSectionCard(
                    isDark,
                    children: [
                      _buildListTile(isDark, Icons.apartment, t('my.properties'), widget.onMyProperties),
                      const Divider(height: 1, color: Colors.white10),
                      _buildListTile(isDark, Icons.chat_bubble_outline, t('messages'), () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListScreen()));
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildSectionHeader(isDark, t('account.settings')),
                  _buildSectionCard(
                    isDark,
                    children: [
                      _buildSettingTile(
                        isDark, 
                        Icons.language, 
                        t('language'), 
                        widget.isArabic ? 'العربية' : 'English',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFF2979FF).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(widget.isArabic ? 'English' : 'العربية', style: const TextStyle(color: Color(0xFF2979FF), fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        onTap: widget.onToggleLanguage,
                      ),
                      const Divider(height: 1, color: Colors.white10),
                      _buildSettingTile(
                        isDark, 
                        Icons.dark_mode_outlined, 
                        t('theme'), 
                        appProvider.isDarkMode ? 'Dark' : 'Light',
                        trailing: Switch(
                          value: appProvider.isDarkMode,
                          onChanged: widget.onToggleTheme,
                          activeColor: const Color(0xFF2979FF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildSectionHeader(isDark, t('account.details')),
                  _buildSectionCard(
                    isDark,
                    children: [
                      _buildDetailRow(isDark, t('name'), _fullName),
                      const Divider(height: 1, color: Colors.white10),
                      _buildDetailRow(isDark, t('phone'), _phone),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Action for edit profile
                            },
                            icon: const Icon(Icons.edit_outlined),
                            label: Text(t('edit.profile'), style: const TextStyle(fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? Colors.white : Colors.black,
                              side: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Supabase.instance.client.auth.signOut();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (route) => false,
                              );
                            },
                            icon: const Icon(Icons.logout),
                            label: Text(t('logout'), style: const TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE53935),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Version 1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(bool isDark, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSectionCard(bool isDark, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE9ECEF)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile(bool isDark, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: isDark ? Colors.white70 : Colors.black54),
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w500, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildSettingTile(bool isDark, IconData icon, String title, String value, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: isDark ? Colors.white70 : Colors.black54),
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w500, fontSize: 15)),
      subtitle: Text(value, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildDetailRow(bool isDark, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
