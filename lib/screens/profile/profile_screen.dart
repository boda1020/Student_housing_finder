import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // الألوان المستخرجة من التصميم في الصورة
    const Color primaryBlue = Color(0xFF5C61F2);
    const Color textDark = Color(0xFF1A1D21);
    const Color textGrey = Color(0xFF7D848D);
    const Color iconBg = Color(0xFFE0E7FF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: textDark),
          onPressed: () {},
        ),
        title: const Text(
          'HousingFinder',
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // صورة الملف الشخصي
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 55,
                    backgroundColor: Color(0xFF2C3E50),
                    child: Icon(Icons.person, size: 70, color: Colors.white54),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // الاسم والبريد الإلكتروني
            const Text(
              'Alex Henderson',
              style: TextStyle(
                color: textDark,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'alex.henderson@university.edu',
              style: TextStyle(color: textGrey, fontSize: 16),
            ),
            const SizedBox(height: 30),

            // كارت "Property Owner Mode"
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F5FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.grid_view_rounded, color: primaryBlue),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Property Owner Mode',
                          style: TextStyle(
                            color: textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Manage your listings and leads',
                          style: TextStyle(color: textGrey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Go to Dashboard', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // قائمة الخيارات
            _buildOptionItem(
              icon: Icons.person_outline_rounded,
              title: 'Personal Info',
              iconColor: primaryBlue,
              onTap: () {},
            ),
            _buildOptionItem(
              icon: Icons.star_border_rounded,
              title: 'My Reviews',
              iconColor: primaryBlue,
              onTap: () {},
            ),
            _buildOptionItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              iconColor: primaryBlue,
              onTap: () {},
            ),
            _buildOptionItem(
              icon: Icons.help_outline_rounded,
              title: 'Help Center',
              iconColor: primaryBlue,
              onTap: () {},
            ),
            const SizedBox(height: 20),

            // زر تسجيل الخروج
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFFE5E5)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textGrey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.messenger_outline), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F5FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1A1D21),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF7D848D)),
      ),
    );
  }
}
