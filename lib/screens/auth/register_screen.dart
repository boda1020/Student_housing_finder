import 'package:flutter/material.dart';

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
        ],
      ),
      body: SingleChildScrollView(
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
                  const SizedBox(height: 6),
                  const Text('Create an account to get started',
                      style: TextStyle(color: _textDim, fontSize: 13)),
                  const SizedBox(height: 20),

                  // Role selector
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
                  _buildTextField(hint: 'John Doe', icon: Icons.person_outline),
                  const SizedBox(height: 14),

                  _buildLabel('Email'),
                  const SizedBox(height: 6),
                  _buildTextField(hint: 'student@university.edu', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 14),

                  _buildLabel('Password'),
                  const SizedBox(height: 6),
                  _buildTextField(hint: '••••••••', icon: Icons.lock_outline, obscure: true),
                  const SizedBox(height: 14),

                  _buildLabel('Phone Number'),
                  const SizedBox(height: 6),
                  _buildTextField(hint: '+1234567890', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                  const SizedBox(height: 14),

                  _buildLabel('University'),
                  const SizedBox(height: 6),
                  _buildTextField(hint: 'University Name', icon: Icons.school_outlined),
                  const SizedBox(height: 22),

                  _buildPrimaryButton('Sign Up', () {
                    // TODO: handle sign up
                  }),
                  const SizedBox(height: 14),
                  _buildGoogleButton('Sign up with Google'),
                  const SizedBox(height: 20),

                  Center(
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Navigate to LoginScreen
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

  Widget _buildTextField({required String hint, required IconData icon, bool obscure = false, TextInputType keyboardType = TextInputType.text}) =>
      TextField(
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _textDim, fontSize: 14),
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

  Widget _buildGoogleButton(String label) => SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: () {},
          icon: const Text('G', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
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