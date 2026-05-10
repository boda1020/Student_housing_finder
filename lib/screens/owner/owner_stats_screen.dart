import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/app_provider.dart';

class OwnerStatsScreen extends StatefulWidget {
  const OwnerStatsScreen({super.key});

  @override
  State<OwnerStatsScreen> createState() => _OwnerStatsScreenState();
}

class _OwnerStatsScreenState extends State<OwnerStatsScreen> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isArabic = appProvider.isArabic;
    final userId = supabase.auth.currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(appProvider.translate('lifetime'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('properties').stream(primaryKey: ['id']).eq('owner_id', userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final properties = snapshot.data ?? [];
          int totalViews = 0;
          double avgPrice = 0.0;
          
          if (properties.isNotEmpty) {
            double totalPrice = 0;
            for (var p in properties) {
              totalPrice += (p['price'] as num).toDouble();
              totalViews += (p['views'] as int? ?? 0);
            }
            avgPrice = totalPrice / properties.length;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Header Card with Gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5C61F2), Color(0xFF8E92FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5C61F2).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.analytics_outlined, color: Colors.white, size: 40),
                      const SizedBox(height: 15),
                      Text(
                        appProvider.translate('total_performance') ?? "Overall Performance",
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$totalViews',
                        style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        appProvider.translate('total_views_stat') ?? "Total Views",
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        appProvider.translate('my_properties_stat'),
                        '${properties.length}',
                        Icons.home_work_rounded,
                        Colors.blue,
                        null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        appProvider.translate('avg_price'),
                        '${avgPrice.toStringAsFixed(0)}',
                        Icons.payments_rounded,
                        Colors.purple,
                        appProvider.translate('currency'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Additional Stats Card
                _buildStatCard(
                  appProvider.translate('status_report') ?? "System Status",
                  appProvider.translate('active_now') ?? "Operational",
                  Icons.check_circle_outline_rounded,
                  Colors.green,
                  "Real-time enabled",
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, String? subtitle) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : theme.dividerColor.withValues(alpha: 0.1)),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (subtitle != null)
                Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
            ],
          ),
          const SizedBox(height: 20),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 22, // تصغير الحجم الأساسي ليتناسب مع المساحة
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
