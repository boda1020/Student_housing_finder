import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../data/services/property_service.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _roomsController = TextEditingController();
  final _bedsController = TextEditingController(text: '1');
  final _otherAmenityController = TextEditingController();
  final _propertyService = PropertyService();
  
  String _selectedType = 'Apartment';
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _hasReception = false;
  bool _hasSalon = false;
  bool _isFurnished = false;

  final Map<String, bool> _essentials = {
    'WiFi': false, 'Fridge': false, 'Washing Machine': false, 'TV': false,
    'Kitchen': false, 'AC': false, 'Water Heater': false, 'Study Desk': false,
  };

  final Map<String, IconData> _amenityIcons = {
    'WiFi': Icons.wifi_rounded, 'Fridge': Icons.kitchen_rounded,
    'Washing Machine': Icons.local_laundry_service_rounded, 'TV': Icons.tv_rounded,
    'Kitchen': Icons.restaurant_rounded, 'AC': Icons.ac_unit_rounded,
    'Water Heater': Icons.hot_tub_rounded, 'Study Desk': Icons.desk_rounded,
  };

  Future<void> _pickImages() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      setState(() => _images.addAll(selectedImages.map((xFile) => File(xFile.path)).toList()));
    }
  }

  Future<void> _submitProperty() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appProvider.translate('at_least_one_photo'))));
      return;
    }

    setState(() => _isLoading = true);
    try {
      List<String> imageUrls = [];
      for (var imageFile in _images) {
        final url = await _propertyService.uploadImage(imageFile);
        imageUrls.add(url);
      }

      final Map<String, bool> finalAmenities = {};
      if (_isFurnished) {
        _essentials.forEach((key, value) { if (value) finalAmenities[key] = true; });
      }
      if (_otherAmenityController.text.isNotEmpty) finalAmenities[_otherAmenityController.text] = true;

      await _propertyService.addProperty(
        title: _titleController.text, description: _descriptionController.text,
        price: double.parse(_priceController.text), location: _locationController.text,
        rooms: int.tryParse(_roomsController.text) ?? 1, type: _selectedType,
        imageUrls: imageUrls, amenities: finalAmenities, hasReception: _hasReception,
        hasSalon: _hasSalon, isFurnished: _isFurnished,
        bedsCount: _isFurnished ? (int.tryParse(_bedsController.text) ?? 1) : 0,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appProvider.translate('published_success'))));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${appProvider.translate('error')}: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final isDark = appProvider.isDarkMode;
    const primaryColor = Color(0xFF5C61F2);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      appBar: AppBar(
        title: Text(appProvider.translate('add_property_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: appProvider.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(appProvider.translate('add_photos'), Icons.camera_alt_rounded, primaryColor, textColor),
                    const SizedBox(height: 12),
                    _buildImagePicker(primaryColor, appProvider),
                    
                    const SizedBox(height: 32),
                    _buildSectionHeader(appProvider.translate('general_info'), Icons.info_outline_rounded, primaryColor, textColor),
                    const SizedBox(height: 16),
                    _buildTextField(_titleController, appProvider.translate('property_title'), Icons.title_rounded, isDark),
                    _buildCategorySelector(appProvider, primaryColor, isDark),
                    _buildTextField(_descriptionController, appProvider.translate('description'), Icons.description_rounded, isDark, maxLines: 3),
                    
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_priceController, appProvider.translate('price'), Icons.payments_rounded, isDark, keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField(_roomsController, appProvider.translate('rooms'), Icons.bed_rounded, isDark, keyboardType: TextInputType.number)),
                      ],
                    ),
                    _buildTextField(_locationController, appProvider.translate('location'), Icons.location_on_rounded, isDark),

                    const SizedBox(height: 32),
                    _buildSectionHeader(appProvider.translate('furnishing'), Icons.chair_rounded, primaryColor, textColor),
                    const SizedBox(height: 16),
                    _buildFurnishingSelector(appProvider, primaryColor, isDark),
                    
                    if (_isFurnished) ...[
                      const SizedBox(height: 24),
                      _buildSectionHeader(appProvider.translate('amenities_features'), Icons.star_rounded, primaryColor, textColor),
                      const SizedBox(height: 16),
                      _buildAmenitiesChips(primaryColor, isDark, appProvider),
                      const SizedBox(height: 20),
                      _buildTextField(_bedsController, appProvider.translate('beds_count'), Icons.king_bed_rounded, isDark, keyboardType: TextInputType.number),
                      _buildFeatureSwitches(appProvider, primaryColor, isDark),
                    ],
                    
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
            if (_isLoading) Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator(color: primaryColor))),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAction(primaryColor, isDark, appProvider),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color primary, Color text) {
    return Row(
      children: [
        Icon(icon, color: primary, size: 20),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: text)),
      ],
    );
  }

  Widget _buildImagePicker(Color primaryColor, AppProvider appProvider) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length + 1,
        itemBuilder: (context, index) {
          if (index == _images.length) {
            return GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryColor.withOpacity(0.2), style: BorderStyle.values[1]),
                ),
                child: Icon(Icons.add_photo_alternate_rounded, color: primaryColor, size: 30),
              ),
            );
          }
          return Container(
            width: 100,
            margin: const EdgeInsetsDirectional.only(end: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(image: FileImage(_images[index]), fit: BoxFit.cover),
            ),
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const CircleAvatar(backgroundColor: Colors.red, radius: 12, child: Icon(Icons.close, size: 14, color: Colors.white)),
                onPressed: () => setState(() => _images.removeAt(index)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isDark, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF5C61F2), size: 20),
          filled: true,
          fillColor: isDark ? const Color(0xFF1E2530) : Colors.grey[50],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF5C61F2), width: 1.5)),
        ),
        validator: (v) => (v == null || v.isEmpty) ? '' : null,
      ),
    );
  }

  Widget _buildCategorySelector(AppProvider appProvider, Color primaryColor, bool isDark) {
    final types = {'Apartment': appProvider.translate('apartment'), 'Studio': appProvider.translate('studio'), 'Shared': appProvider.translate('shared_room')};
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: types.entries.map((e) {
          final isSelected = _selectedType == e.key;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 10),
            child: ChoiceChip(
              label: Text(e.value),
              selected: isSelected,
              onSelected: (v) => setState(() => _selectedType = e.key),
              selectedColor: primaryColor,
              backgroundColor: isDark ? const Color(0xFF1E2530) : Colors.grey[200],
              labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54), fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFurnishingSelector(AppProvider appProvider, Color primaryColor, bool isDark) {
    return Row(
      children: [
        _expandChoice(appProvider.translate('unfurnished'), !_isFurnished, () => setState(() => _isFurnished = false), primaryColor, isDark),
        const SizedBox(width: 12),
        _expandChoice(appProvider.translate('furnished'), _isFurnished, () => setState(() => _isFurnished = true), primaryColor, isDark),
      ],
    );
  }

  Widget _expandChoice(String label, bool sel, VoidCallback onTap, Color prim, bool dark) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: sel ? prim : (dark ? const Color(0xFF1E2530) : Colors.grey[100]),
            borderRadius: BorderRadius.circular(15),
            boxShadow: sel ? [BoxShadow(color: prim.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(color: sel ? Colors.white : (dark ? Colors.white70 : Colors.black54), fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildAmenitiesChips(Color primaryColor, bool isDark, AppProvider appProvider) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _essentials.keys.map((key) {
        final isSelected = _essentials[key]!;
        return FilterChip(
          label: Text(appProvider.translate(key.toLowerCase().replaceAll(' ', '_')) ?? key),
          avatar: Icon(_amenityIcons[key], size: 16, color: isSelected ? Colors.white : primaryColor),
          selected: isSelected,
          onSelected: (v) => setState(() => _essentials[key] = v),
          selectedColor: primaryColor,
          backgroundColor: isDark ? const Color(0xFF1E2530) : Colors.grey[100],
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87), fontSize: 12, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: isSelected ? primaryColor : Colors.transparent),
        );
      }).toList(),
    );
  }

  Widget _buildFeatureSwitches(AppProvider appProvider, Color primaryColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          _simpleToggle(appProvider.translate('reception'), _hasReception, (v) => setState(() => _hasReception = v), primaryColor, isDark),
          const SizedBox(width: 12),
          _simpleToggle(appProvider.translate('salon'), _hasSalon, (v) => setState(() => _hasSalon = v), primaryColor, isDark),
        ],
      ),
    );
  }

  Widget _simpleToggle(String label, bool val, Function(bool) onChanged, Color prim, bool dark) {
    return Expanded(
      child: InkWell(
        onTap: () => onChanged(!val),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF1E2530) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: val ? prim : Colors.transparent),
          ),
          child: Row(
            children: [
              Icon(val ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, color: val ? prim : Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction(Color primaryColor, bool isDark, AppProvider appProvider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1117) : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: ElevatedButton(
        onPressed: _submitProperty,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 5,
          shadowColor: primaryColor.withOpacity(0.4),
        ),
        child: Text(appProvider.translate('publish_now'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
