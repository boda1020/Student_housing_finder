import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  String _selectedType = 'Apartment';
  int _selectedRooms = 1;
  final List<String> _amenities = [];

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = appProvider.isDarkMode;
    final isArabic = appProvider.isArabic;
    final primaryColor = const Color(0xFF5C61F2);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final bgColor = isDark ? const Color(0xFF0D1217) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isArabic ? 'الفلترة' : 'Filters',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _minPriceController.clear();
                _maxPriceController.clear();
                _amenities.clear();
                _selectedRooms = 1;
              });
            },
            child: Text(
              isArabic ? 'إعادة ضبط' : 'Reset',
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'فئة السكن' : 'Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [
                _buildTypeChip('Apartment', isArabic ? 'شقة' : 'Apartment'),
                _buildTypeChip('Studio', isArabic ? 'استوديو' : 'Studio'),
                _buildTypeChip('Shared', isArabic ? 'سكن مشترك' : 'Shared'),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              isArabic ? 'عدد الغرف' : 'Number of Rooms',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildRoomButton(1),
                const SizedBox(width: 12),
                _buildRoomButton(2),
                const SizedBox(width: 12),
                _buildRoomButton(3),
                const SizedBox(width: 12),
                _buildRoomButton(4, label: '4+'),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              isArabic ? 'نطاق السعر' : 'Price Range',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPriceField(
                    controller: _minPriceController,
                    label: isArabic ? 'الحد الأدنى' : 'Min Price',
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  height: 2,
                  width: 12,
                  color: Colors.grey.withOpacity(0.5),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPriceField(
                    controller: _maxPriceController,
                    label: isArabic ? 'الحد الأقصى' : 'Max Price',
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              isArabic ? 'المرافق والخدمات' : 'Amenities & Services',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 16),
            _buildAmenityTile(Icons.wifi, isArabic ? 'واي فاي مجاني' : 'Free Wifi'),
            _buildAmenityTile(Icons.flash_on, isArabic ? 'شامل الكهرباء' : 'Electricity Included'),
            _buildAmenityTile(Icons.local_laundry_service, isArabic ? 'غسالة ملابس' : 'Washing Machine'),
            _buildAmenityTile(Icons.kitchen, isArabic ? 'مطبخ مشترك' : 'Shared Kitchen'),
            _buildAmenityTile(Icons.cleaning_services, isArabic ? 'خدمة تنظيف' : 'Cleaning Service'),
            _buildAmenityTile(Icons.security, isArabic ? 'أمن 24 ساعة' : '24/7 Security'),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  isArabic ? 'تطبيق الفلترة' : 'Apply Filters',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceField({
    required TextEditingController controller,
    required String label,
    required bool isDark,
  }) {
    final primaryColor = const Color(0xFF5C61F2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: label.contains('Min') || label.contains('الأدنى') ? '200' : '2000',
            hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
            prefixText: '\$ ',
            prefixStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF5C61F2), width: 2),
            ),
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomButton(int count, {String? label}) {
    final isSelected = _selectedRooms == count;
    final primaryColor = const Color(0xFF5C61F2);
    return InkWell(
      onTap: () => setState(() => _selectedRooms = count),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? primaryColor : Colors.grey.withOpacity(0.3)),
        ),
        alignment: Alignment.center,
        child: Text(
          label ?? count.toString(),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String value, String label) {
    final isSelected = _selectedType == value;
    final primaryColor = const Color(0xFF5C61F2);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (v) => setState(() => _selectedType = value),
      selectedColor: primaryColor,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold),
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? primaryColor : Colors.grey.withOpacity(0.3)),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildAmenityTile(IconData icon, String label) {
    final isSelected = _amenities.contains(label);
    final primaryColor = const Color(0xFF5C61F2);
    return CheckboxListTile(
      title: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 15)),
        ],
      ),
      value: isSelected,
      onChanged: (v) {
        setState(() {
          if (v!) {
            _amenities.add(label);
          } else {
            _amenities.remove(label);
          }
        });
      },
      activeColor: primaryColor,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}
