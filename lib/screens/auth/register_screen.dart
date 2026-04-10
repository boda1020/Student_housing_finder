import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import 'login_screen.dart';
import '../owner/owner_dashboard_screen.dart';

const _bgColor = Color(0xFF0D1117);
const _cardColor = Color(0xFF161B22);
const _fieldColor = Color(0xFF1E2530);
const _blueAccent = Color(0xFF2979FF);
const _textDim = Color(0xFF8B949E);

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

  Future<void> _handleSignUp() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
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
        // بعد الساين أب، نبلغ المستخدم بالنجاح ونوجهه للوجن
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully! Please login.')),
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
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _blueAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.home_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Student Housing Finder',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('العربية', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: _blueAccent))
        : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sign Up',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Create an account to get started',
                      style: TextStyle(color: _textDim, fontSize: 13)),
                  const SizedBox(height: 24),

                  const Text('I am a',
                      style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _RadioOption(
                        label: 'Student',
                        selected: _role == 0,
                        onTap: () => setState(() => _role = 0),
                      ),
                      const SizedBox(width: 24),
                      _RadioOption(
                        label: 'Property Owner',
                        selected: _role == 1,
                        onTap: () => setState(() => _role = 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Name'),
                  const SizedBox(height: 6),
                  _buildTextField(hint: 'Your Name', icon: Icons.person_outline, controller: _nameController),
                  const SizedBox(height: 14),

                  _buildLabel('Email'),
                  const SizedBox(height: 6),
                  _buildTextField(hint: 'Your Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, controller: _emailController),
                  const SizedBox(height: 14),

                  _buildLabel('Password'),
                  const SizedBox(height: 6),
                  _buildTextField(hint: 'Your Password', icon: Icons.lock_outline, obscure: true, controller: _passwordController),
                  const SizedBox(height: 14),

                  _buildLabel('Phone Number'),
                  const SizedBox(height: 6),
                  _buildTextField(hint: 'Your Phone Number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone, controller: _phoneController),
                  
                  if (_role == 0) ...[
                    const SizedBox(height: 14),
                    _buildLabel('University'),
                    const SizedBox(height: 6),
                    _buildTextField(hint: 'Your University Name', icon: Icons.school_outlined, controller: _universityController),
                  ],
                  
                  const SizedBox(height: 22),

                  _buildPrimaryButton('Sign Up', _handleSignUp),
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
                        text: const TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(color: _textDim, fontSize: 13),
                          children: [
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(color: _blueAccent, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text,
      style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500));

  Widget _buildTextField({required String hint, required IconData icon, bool obscure = false, TextInputType keyboardType = TextInputType.text, required TextEditingController controller}) =>
      TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _textDim, fontSize: 14, fontStyle: FontStyle.italic),
          prefixIcon: Icon(icon, color: _textDim, size: 18),
          filled: true,
          fillColor: _fieldColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _blueAccent)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      );

  Widget _buildPrimaryButton(String label, VoidCallback onTap) => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      );
}

class _RadioOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioOption({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: selected ? _blueAccent : Colors.white38, width: 2),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: _blueAccent, shape: BoxShape.circle),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(color: selected ? Colors.white : Colors.white60, fontSize: 14)),
        ],
      ),
    );
  }
}