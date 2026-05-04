import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _supabase = Supabase.instance.client;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = true;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final data = await _supabase.from('profiles').select().eq('id', user.id).single();
        _nameController.text = data['full_name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile(AppProvider appProvider) async {
    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Update Profile Info
      await _supabase.from('profiles').update({
        'full_name': _nameController.text,
        'phone': _phoneController.text,
      }).eq('id', user.id);

      // Update Password if provided
      if (_passwordController.text.isNotEmpty) {
        if (_passwordController.text.length < 6) {
          throw Exception(appProvider.translate('password_short_error'));
        }
        await _supabase.auth.updateUser(
          UserAttributes(password: _passwordController.text),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appProvider.translate('update_success'))));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${appProvider.translate('error')}: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appProvider = Provider.of<AppProvider>(context);
    final isAr = appProvider.isArabic;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(appProvider.translate('personal_info'), style: const TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(appProvider.translate('general_info'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTextField(appProvider.translate('full_name'), _nameController, Icons.person_outline_rounded),
                const SizedBox(height: 16),
                _buildTextField(appProvider.translate('phone_number'), _phoneController, Icons.phone_android_rounded, keyboardType: TextInputType.phone),
                
                const SizedBox(height: 32),
                Text(appProvider.translate('security'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTextField(
                  appProvider.translate('new_password'), 
                  _passwordController, 
                  Icons.lock_outline_rounded,
                  isPassword: true,
                  hint: appProvider.translate('password_blank_hint'),
                ),
  
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => _updateProfile(appProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 2,
                  ),
                  child: Text(appProvider.translate('save'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, 
    IconData icon, 
    {TextInputType keyboardType = TextInputType.text, bool isPassword = false, String? hint}
  ) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword && !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword ? IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
    );
  }
}
