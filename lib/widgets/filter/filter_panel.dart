import 'package:flutter/material.dart';
import '../../providers/property_provider.dart';

class FilterPanel extends StatefulWidget {
  const FilterPanel({
    super.key,
    required this.initialFilters,
    required this.onApply,
    required this.onClose,
  });

  final FilterValues initialFilters;
  final void Function(FilterValues) onApply;
  final VoidCallback onClose;

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
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
    
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 24,
        right: 24,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1117) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: widget.onClose,
                icon: Icon(Icons.close, color: isDark ? Colors.white54 : Colors.black54),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Customize your search to find the perfect property',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 32),
          
          Text(
            'Price Range',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
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
          Text(
            'Max Distance (km)',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
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
                    widget.onClose();
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
    );
  }
}
