import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/auth_service.dart';
import '../../providers/app_provider.dart';
import 'register_screen.dart';
import 'forgot_password.dart';
import '../home/owner_dashboard_screen.dart';
import '../home/student_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final _authService = AuthService();

  Future<void> _handleLogin(AppProvider appProvider) async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appProvider.translate('enter.email.pass'))),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      final isOwner = await _authService.isOwner();

      if (mounted) {
        if (isOwner) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const OwnerDashboardScreen()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const StudentHomeScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${appProvider.translate('login.failed')}: ${e.toString()}')),
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
                    // Header
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primaryColor.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 40),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            appProvider.translate('app.title'),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    
                    // Welcome Text
                    Text(
                      appProvider.translate('login'),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appProvider.translate('login.subtitle'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Form
                    _buildLabel(appProvider.translate('email'), theme),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hint: appProvider.translate('email.hint'),
                      icon: Icons.email_outlined,
                      controller: _emailController,
                      theme: theme,
                    ),
                    const SizedBox(height: 20),
                    
                    _buildLabel(appProvider.translate('password'), theme),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hint: appProvider.translate('password.hint'),
                      icon: Icons.lock_outline_rounded,
                      obscure: true,
                      controller: _passwordController,
                      theme: theme,
                    ),
                    
                    const SizedBox(height: 12),
                    Align(
                      alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                          );
                        },
                        child: Text(
                          appProvider.translate('forgot.password'),
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Login Button
                    _buildPrimaryButton(
                      appProvider.translate('login'),
                      () => _handleLogin(appProvider),
                      theme,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Footer
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpScreen()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: appProvider.translate('dont.have.account'),
                            style: theme.textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: appProvider.translate('signup'),
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
    required TextEditingController controller,
    required ThemeData theme,
  }) =>
      TextField(
        controller: controller,
        obscureText: obscure,
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
