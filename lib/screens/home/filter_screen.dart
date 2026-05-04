import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class FilterScreen extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;
  const FilterScreen({super.key, this.initialFilters});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  String _selectedType = 'All';
  String _selectedFurnishing = 'All';
  int _selectedRooms = 0;
  final Map<String, bool> _amenities = {
    'WiFi': false,
    'Fridge': false,
    'Washing Machine': false,
    'TV': false,
    'Kitchen': false,
    'AC': false,
    'Water Heater': false,
    'Study Desk': false,
    'Reception': false,
    'Salon': false,
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialFilters != null) {
      _minPriceController.text = widget.initialFilters?['minPrice']?.toString() ?? '';
      _maxPriceController.text = widget.initialFilters?['maxPrice']?.toString() ?? '';
      _selectedType = widget.initialFilters?['type'] ?? 'All';
      _selectedFurnishing = widget.initialFilters?['furnishing'] ?? 'All';
      _selectedRooms = widget.initialFilters?['rooms'] ?? 0;
      if (widget.initialFilters?['amenities'] != null) {
        final Map<String, bool> savedAmenities = Map<String, bool>.from(widget.initialFilters!['amenities']);
        _amenities.addAll(savedAmenities);
      }
    }
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final isAr = appProvider.isArabic;
    final primaryColor = theme.primaryColor;
    final textColor = theme.textTheme.bodyLarge?.color;
    final cardColor = theme.cardTheme.color;

    return Scaffold(
      appBar: AppBar(
        title: Text(appProvider.translate('filter_results')),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _minPriceController.clear();
                _maxPriceController.clear();
                _selectedType = 'All';
                _selectedFurnishing = 'All';
                _selectedRooms = 0;
                _amenities.updateAll((key, value) => false);
              });
            },
            child: Text(appProvider.translate('reset'), style: TextStyle(color: primaryColor)),
          )
        ],
      ),
      body: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(appProvider.translate('price_range'), theme),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildPriceField(_minPriceController, appProvider.translate('min'), '0 ${appProvider.translate('currency')}', cardColor!, textColor!),
                  ),
                  const SizedBox(width: 16),
                  Text('-', style: TextStyle(color: Colors.grey[400], fontSize: 20)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPriceField(_maxPriceController, appProvider.translate('max'), '10000 ${appProvider.translate('currency')}', cardColor, textColor),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildLabel(appProvider.translate('property_type_filter'), theme),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: ['All', 'Apartment', 'Studio', 'Shared', 'Villa'].map((type) {
                  final isSelected = _selectedType == type;
                  return ChoiceChip(
                    label: Text(_translateType(type, appProvider)),
                    selected: isSelected,
                    selectedColor: primaryColor,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : null),
                    onSelected: (selected) => setState(() => _selectedType = type),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              _buildLabel(appProvider.translate('furnishing'), theme),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: ['All', 'Furnished', 'Unfurnished'].map((f) {
                  final isSelected = _selectedFurnishing == f;
                  return ChoiceChip(
                    label: Text(f == 'All' ? appProvider.translate('all') : appProvider.translate(f.toLowerCase())),
                    selected: isSelected,
                    selectedColor: primaryColor,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : null),
                    onSelected: (selected) => setState(() => _selectedFurnishing = f),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              _buildLabel(appProvider.translate('rooms'), theme),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [0, 1, 2, 3, 4].map((rooms) {
                  final isSelected = _selectedRooms == rooms;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedRooms = rooms),
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? primaryColor : Colors.grey.withOpacity(0.1)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        rooms == 0 ? appProvider.translate('all') : rooms.toString(),
                        style: TextStyle(color: isSelected ? Colors.white : null, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              _buildLabel(appProvider.translate('amenities_features'), theme),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: _amenities.length,
                itemBuilder: (context, index) {
                  String key = _amenities.keys.elementAt(index);
                  bool isSelected = _amenities[key]!;
                  return GestureDetector(
                    onTap: () => setState(() => _amenities[key] = !isSelected),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? primaryColor : Colors.grey.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getAmenityIcon(key),
                            color: isSelected ? Colors.white : primaryColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _translateAmenity(key, appProvider),
                              style: TextStyle(
                                color: isSelected ? Colors.white : textColor,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected) const Icon(Icons.check_circle, color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'minPrice': double.tryParse(_minPriceController.text),
                      'maxPrice': double.tryParse(_maxPriceController.text),
                      'type': _selectedType,
                      'furnishing': _selectedFurnishing,
                      'rooms': _selectedRooms,
                      'amenities': _amenities,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(appProvider.translate('apply_filters'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  String _translateType(String type, AppProvider appProvider) {
    switch (type) {
      case 'All': return appProvider.translate('all');
      case 'Apartment': return appProvider.translate('apartment');
      case 'Studio': return appProvider.translate('studio');
      case 'Shared': return appProvider.translate('shared_room');
      case 'Villa': return appProvider.translate('villa');
      default: return type;
    }
  }

  String _translateAmenity(String key, AppProvider appProvider) {
    switch (key) {
      case 'WiFi': return appProvider.translate('wifi');
      case 'Fridge': return appProvider.translate('fridge');
      case 'Washing Machine': return appProvider.translate('washing_machine');
      case 'TV': return appProvider.translate('tv');
      case 'Kitchen': return appProvider.translate('kitchen');
      case 'AC': return appProvider.translate('ac');
      case 'Water Heater': return appProvider.translate('water_heater');
      case 'Study Desk': return appProvider.translate('study_desk');
      case 'Reception': return appProvider.translate('reception');
      case 'Salon': return appProvider.translate('salon');
      default: return key;
    }
  }


  Widget _buildLabel(String text, ThemeData theme) {
    return Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildPriceField(TextEditingController controller, String label, String hint, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.3)),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAmenityIcon(String key) {
    switch (key) {
      case 'WiFi': return Icons.wifi_rounded;
      case 'Fridge': return Icons.kitchen_rounded;
      case 'Washing Machine': return Icons.local_laundry_service_rounded;
      case 'TV': return Icons.tv_rounded;
      case 'Kitchen': return Icons.restaurant_rounded;
      case 'AC': return Icons.ac_unit_rounded;
      case 'Water Heater': return Icons.hot_tub_rounded;
      case 'Study Desk': return Icons.desk_rounded;
      case 'Reception': return Icons.meeting_room_rounded;
      case 'Salon': return Icons.weekend_rounded;
      default: return Icons.star_rounded;
    }
  }
}
