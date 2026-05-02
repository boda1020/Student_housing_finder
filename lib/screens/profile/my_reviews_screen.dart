import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('My Reviews')),
      body: FutureBuilder(
        future: Supabase.instance.client
            .from('reviews')
            .select('*, properties(title)')
            .eq('user_id', Supabase.instance.client.auth.currentUser!.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final reviews = snapshot.data as List<dynamic>? ?? [];
          if (reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No reviews yet', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            review['properties']['title'] ?? 'Property',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Row(
                          children: List.generate(5, (i) => Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: i < (review['rating'] ?? 0) ? Colors.orange : Colors.grey[300],
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review['comment'] ?? '',
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
