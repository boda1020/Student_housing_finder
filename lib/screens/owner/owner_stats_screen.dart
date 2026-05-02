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
                _buildStatCard(
                  appProvider.translate('total.views'),
                  '$totalViews',
                  Icons.visibility_rounded,
                  Colors.orange,
                  appProvider.translate('30days'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        appProvider.translate('my.properties'),
                        '${properties.length}',
                        Icons.home_work_rounded,
                        Colors.blue,
                        null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        appProvider.translate('monthly.price'),
                        '${avgPrice.toStringAsFixed(0)} ${appProvider.translate('currency')}',
                        Icons.payments_rounded,
                        Colors.purple,
                        null,
                      ),
                    ),
                  ],
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
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (subtitle != null)
                Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value, 
            style: TextStyle(
              fontSize: 28, 
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            )
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
