import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/auth_service.dart';
import '../../providers/app_provider.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  int _role = 0; // 0 = Student, 1 = Property Owner
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _universityController = TextEditingController();
  bool _isLoading = false;

  final _authService = AuthService();

  Future<void> _handleSignUp(AppProvider appProvider) async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appProvider.translate('fill.all.fields'))),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final role = _role == 0 ? 'student' : 'owner';
      await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        university: role == 'student' ? _universityController.text.trim() : null,
        role: role,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appProvider.translate('account.created'))),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final isAr = appProvider.isArabic;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: _isLoading 
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.primaryColor.withOpacity(0.1),
                    theme.scaffoldBackgroundColor,
                  ],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(isAr ? Icons.arrow_forward_ios : Icons.arrow_back_ios, color: theme.primaryColor),
                    ),
                    const SizedBox(height: 20),
                    
                    // Welcome Text
                    Text(
                      appProvider.translate('signup'),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appProvider.translate('signup.subtitle'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Role Selection
                    Text(
                      appProvider.translate('i.am.a'),
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _RoleCard(
                            label: appProvider.translate('student'),
                            icon: Icons.school_outlined,
                            isSelected: _role == 0,
                            onTap: () => setState(() => _role = 0),
                            theme: theme,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _RoleCard(
                            label: appProvider.translate('property.owner'),
                            icon: Icons.business_outlined,
                            isSelected: _role == 1,
                            onTap: () => setState(() => _role = 1),
                            theme: theme,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Form
                    _buildLabel(appProvider.translate('name'), theme),
                    const SizedBox(height: 8),
                    _buildTextField(hint: appProvider.translate('name.hint'), icon: Icons.person_outline, controller: _nameController, theme: theme),
                    const SizedBox(height: 16),

                    _buildLabel(appProvider.translate('email'), theme),
                    const SizedBox(height: 8),
                    _buildTextField(hint: appProvider.translate('email.hint'), icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, controller: _emailController, theme: theme),
                    const SizedBox(height: 16),

                    _buildLabel(appProvider.translate('password'), theme),
                    const SizedBox(height: 8),
                    _buildTextField(hint: appProvider.translate('password.hint'), icon: Icons.lock_outline_rounded, obscure: true, controller: _passwordController, theme: theme),
                    const SizedBox(height: 16),

                    _buildLabel(appProvider.translate('phone'), theme),
                    const SizedBox(height: 8),
                    _buildTextField(hint: appProvider.translate('phone.hint'), icon: Icons.phone_outlined, keyboardType: TextInputType.phone, controller: _phoneController, theme: theme),
                    
                    if (_role == 0) ...[
                      const SizedBox(height: 16),
                      _buildLabel('University', theme),
                      const SizedBox(height: 8),
                      _buildTextField(hint: appProvider.translate('university.hint'), icon: Icons.school_outlined, controller: _universityController, theme: theme),
                    ],
                    
                    const SizedBox(height: 32),

                    _buildPrimaryButton(appProvider.translate('signup'), () => _handleSignUp(appProvider), theme),
                    const SizedBox(height: 24),

                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: appProvider.translate('already.have.account'),
                            style: theme.textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: appProvider.translate('login'),
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildLabel(String text, ThemeData theme) => Text(
    text,
    style: theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurface.withOpacity(0.8),
    ),
  );

  Widget _buildTextField({
    required String hint, 
    required IconData icon, 
    bool obscure = false, 
    TextInputType keyboardType = TextInputType.text, 
    required TextEditingController controller,
    required ThemeData theme,
  }) =>
      TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 22),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      );

  Widget _buildPrimaryButton(String label, VoidCallback onTap, ThemeData theme) => Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
          ),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
}

class _RoleCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _RoleCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.primaryColor : theme.dividerColor.withOpacity(0.1),
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : theme.primaryColor,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
