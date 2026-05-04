import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = appProvider.isDarkMode;
    final isAr = appProvider.isArabic;
    final theme = Theme.of(context);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(appProvider.translate('settings'), style: const TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSettingTile(
              context,
              title: appProvider.translate('language'),
              subtitle: isAr ? appProvider.translate('arabic') : appProvider.translate('english'),
              icon: Icons.language_rounded,
              trailing: Switch(
                value: isAr,
                onChanged: (value) => appProvider.toggleLanguage(),
                activeColor: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              context,
              title: appProvider.translate('dark_mode'),
              subtitle: isDark ? appProvider.translate('enabled') : appProvider.translate('disabled'),
              icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              trailing: Switch(
                value: isDark,
                onChanged: (value) => appProvider.toggleTheme(),
                activeColor: theme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget trailing,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: theme.primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        trailing: trailing,
      ),
    );
  }
}
