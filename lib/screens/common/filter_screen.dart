import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/property_provider.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key, required this.initialFilters, required this.onApply});

  final FilterValues initialFilters;
  final void Function(FilterValues) onApply;

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late FilterValues filters;

  @override
  void initState() {
    super.initState();
    filters = FilterValues(
      priceRange: widget.initialFilters.priceRange,
      maxDistance: widget.initialFilters.maxDistance,
      roomTypes: List.of(widget.initialFilters.roomTypes),
      facilities: List.of(widget.initialFilters.facilities),
    );
  }

  void _reset() {
    setState(() {
      filters = FilterValues(
        priceRange: const RangeValues(0, 5000),
        maxDistance: 20,
        roomTypes: [],
        facilities: [],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appProvider = Provider.of<AppProvider>(context);
    final t = appProvider.translate;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Filters',
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customize your search to find the perfect property',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            
            const Text(
              'Price Range',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            RangeSlider(
              values: filters.priceRange,
              min: 0,
              max: 5000,
              divisions: 50,
              activeColor: const Color(0xFF2979FF),
              inactiveColor: isDark ? Colors.white12 : Colors.black12,
              labels: RangeLabels(
                '\$${filters.priceRange.start.toInt()}',
                '\$${filters.priceRange.end.toInt()}',
              ),
              onChanged: (values) => setState(() => filters.priceRange = values),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$0', style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text('\$5000', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
            
            const SizedBox(height: 32),
            const Text(
              'Max Distance (km)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Slider(
              value: filters.maxDistance,
              min: 1,
              max: 50,
              divisions: 49,
              activeColor: const Color(0xFF2979FF),
              inactiveColor: isDark ? Colors.white12 : Colors.black12,
              onChanged: (value) => setState(() => filters.maxDistance = value),
            ),
            Text('Up to ${filters.maxDistance.toInt()} km', 
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
            
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Reset Filters', 
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(filters);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2979FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
