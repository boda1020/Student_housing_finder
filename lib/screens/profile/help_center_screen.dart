import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isArabic = appProvider.isArabic;
    
    return Scaffold(
      appBar: AppBar(title: Text(appProvider.translate('help_center'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHelpTile(
            context,
            appProvider.translate('faq'),
            Icons.question_answer_outlined,
            appProvider.translate('faq_desc'),
            isArabic,
          ),
          const SizedBox(height: 12),
          _buildHelpTile(
            context,
            appProvider.translate('contact_support'),
            Icons.support_agent_rounded,
            appProvider.translate('contact_support_desc'),
            isArabic,
          ),
          const SizedBox(height: 12),
          _buildHelpTile(
            context,
            appProvider.translate('privacy_policy'),
            Icons.privacy_tip_outlined,
            appProvider.translate('privacy_policy_desc'),
            isArabic,
          ),
          const SizedBox(height: 12),
          _buildHelpTile(
            context,
            appProvider.translate('terms_service'),
            Icons.description_outlined,
            appProvider.translate('terms_service_desc'),
            isArabic,
          ),
        ],
      ),
    );
  }

  Widget _buildHelpTile(BuildContext context, String title, IconData icon, String subtitle, bool isArabic) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.primaryColor, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        ),
        trailing: Icon(
          isArabic ? Icons.arrow_back_ios_new_rounded : Icons.arrow_forward_ios_rounded,
          size: 14, 
          color: Colors.grey[400],
        ),
        onTap: () {
          // Add specific navigation or logic if needed
        },
      ),
    );
  }
}
