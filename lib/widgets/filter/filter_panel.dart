import 'package:flutter/material.dart';

class FilterValues {
  FilterValues({
    required this.priceRange,
    required this.maxDistance,
    required this.roomTypes,
    required this.facilities,
  });

  RangeValues priceRange;
  double maxDistance;
  List<String> roomTypes;
  List<String> facilities;
}

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
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 12,
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
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Filters',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Price range',
              style: TextStyle(color: Colors.white70),
            ),
            RangeSlider(
              values: filters.priceRange,
              min: 0,
              max: 5000,
              divisions: 20,
              labels: RangeLabels(
                '\$${filters.priceRange.start.toInt()}',
                '\$${filters.priceRange.end.toInt()}',
              ),
              onChanged: (values) => setState(() => filters.priceRange = values),
            ),
            const SizedBox(height: 12),
            const Text(
              'Max distance (km)',
              style: TextStyle(color: Colors.white70),
            ),
            Slider(
              value: filters.maxDistance,
              min: 1,
              max: 20,
              divisions: 19,
              label: '${filters.maxDistance.toStringAsFixed(0)} km',
              onChanged: (value) => setState(() => filters.maxDistance = value),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white38),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(filters);
                      widget.onClose();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
