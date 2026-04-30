import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/app_provider.dart';

class OwnerStatsScreen extends StatelessWidget {
  const OwnerStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final isDark = appProvider.isDarkMode;
    final isArabic = appProvider.isArabic;
    final primaryColor = theme.primaryColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final bgColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardTheme.color ?? Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          isArabic ? 'الإحصائيات التحليلية' : 'Analytics & Stats',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(isArabic ? 'نظرة عامة' : 'Performance Overview', textColor),
            const SizedBox(height: 16),
            _buildMainChart(cardColor, theme.primaryColor, isDark, isArabic),
            const SizedBox(height: 24),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client
                  .from('properties')
                  .stream(primaryKey: ['id'])
                  .eq('owner_id', Supabase.instance.client.auth.currentUser?.id ?? ''),
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return Row(
                  children: [
                    Expanded(child: _buildMiniStatCard(isArabic ? 'عقاراتي' : 'My Properties', '$count', Icons.home_work_rounded, Colors.blue, cardColor, textColor)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildMiniStatCard(isArabic ? 'المشاهدات' : 'Total Views', '${count * 12}', Icons.visibility_rounded, Colors.orange, cardColor, textColor)),
                  ],
                );
              }
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client
                  .from('messages')
                  .stream(primaryKey: ['id'])
                  .eq('receiver_id', Supabase.instance.client.auth.currentUser?.id ?? ''),
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return Row(
                  children: [
                    Expanded(child: _buildMiniStatCard(isArabic ? 'الرسائل' : 'Inquiries', '$count', Icons.chat_bubble_rounded, Colors.green, cardColor, textColor)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildMiniStatCard(isArabic ? 'متوسط السعر' : 'Avg Price', '\$750', Icons.payments_rounded, Colors.purple, cardColor, textColor)),
                  ],
                );
              }
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(isArabic ? 'أكثر العقارات زيارة' : 'Most Viewed Properties', textColor),
            const SizedBox(height: 16),
            _buildTopPropertyRow('Luxury Studio - Cairo', '850', '1.2k views', primaryColor, cardColor, textColor),
            const SizedBox(height: 12),
            _buildTopPropertyRow('Shared Room - Giza', '450', '850 views', primaryColor, cardColor, textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
    );
  }

  Widget _buildMainChart(Color cardColor, Color primaryColor, bool isDark, bool isArabic) {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 10, 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'النشاط' : 'Activity',
                style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz, color: Colors.grey),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                onSelected: (value) {
                  // هنا ممكن تضيف أكشن مستقبلاً
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'weekly',
                    child: Text(isArabic ? 'أسبوعي' : 'Weekly'),
                  ),
                  PopupMenuItem(
                    value: 'monthly',
                    child: Text(isArabic ? 'شهري' : 'Monthly'),
                  ),
                  PopupMenuItem(
                    value: 'yearly',
                    child: Text(isArabic ? 'سنوي' : 'Yearly'),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Mock Chart Representation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final heights = [40.0, 70.0, 50.0, 90.0, 60.0, 80.0, 45.0];
              return Container(
                width: 15,
                height: heights[index],
                decoration: BoxDecoration(
                  color: index == 3 ? primaryColor : primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) => Text(d, style: TextStyle(color: Colors.grey[500], fontSize: 10))).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(String label, String value, IconData icon, Color color, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTopPropertyRow(String title, String price, String views, Color primaryColor, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.home_work_rounded, color: primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                Text(views, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Text('\$$price', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
