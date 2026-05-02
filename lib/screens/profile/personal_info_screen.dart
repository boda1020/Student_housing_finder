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
          throw Exception(appProvider.isArabic ? 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل' : 'Password must be at least 6 characters');
        }
        await _supabase.auth.updateUser(
          UserAttributes(password: _passwordController.text),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appProvider.isArabic ? 'تم تحديث الملف الشخصي بنجاح! ✅' : 'Profile Updated Successfully! ✅')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${appProvider.isArabic ? 'خطأ' : 'Error'}: $e')));
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
          title: Text(isAr ? 'المعلومات الشخصية' : 'Personal Info', style: const TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(isAr ? 'المعلومات العامة' : 'General Information', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTextField(isAr ? 'الاسم الكامل' : 'Full Name', _nameController, Icons.person_outline_rounded),
                const SizedBox(height: 16),
                _buildTextField(isAr ? 'رقم الهاتف' : 'Phone Number', _phoneController, Icons.phone_android_rounded, keyboardType: TextInputType.phone),
                
                const SizedBox(height: 32),
                Text(isAr ? 'الأمان' : 'Security', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTextField(
                  isAr ? 'كلمة مرور جديدة' : 'New Password', 
                  _passwordController, 
                  Icons.lock_outline_rounded,
                  isPassword: true,
                  hint: isAr ? 'اتركه فارغاً للاحتفاظ بالحالية' : 'Leave blank to keep current',
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
                  child: Text(isAr ? 'حفظ التغييرات' : 'Save Changes', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
