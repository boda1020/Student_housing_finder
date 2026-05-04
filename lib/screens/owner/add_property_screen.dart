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

  // Essential Amenities for Students
  final Map<String, bool> _essentials = {
    'WiFi': false,
    'Fridge': false,
    'Washing Machine': false,
    'TV': false,
    'Kitchen': false,
    'AC': false,
    'Water Heater': false,
    'Study Desk': false,
  };

  final Map<String, IconData> _amenityIcons = {
    'WiFi': Icons.wifi_rounded,
    'Fridge': Icons.kitchen_rounded,
    'Washing Machine': Icons.local_laundry_service_rounded,
    'TV': Icons.tv_rounded,
    'Kitchen': Icons.restaurant_rounded,
    'AC': Icons.ac_unit_rounded,
    'Water Heater': Icons.hot_tub_rounded,
    'Study Desk': Icons.desk_rounded,
  };

  Future<void> _pickImages() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      setState(() {
        _images.addAll(selectedImages.map((xFile) => File(xFile.path)).toList());
      });
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
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
      
      // If furnished, add selected essentials
      if (_isFurnished) {
        _essentials.forEach((key, value) {
          if (value) finalAmenities[key] = true;
        });
      }
      
      // Always allow "Other"
      if (_otherAmenityController.text.isNotEmpty) {
        finalAmenities[_otherAmenityController.text] = true;
      }

      await _propertyService.addProperty(
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        location: _locationController.text,
        rooms: int.tryParse(_roomsController.text) ?? 1,
        type: _selectedType,
        imageUrls: imageUrls,
        amenities: finalAmenities,
        hasReception: _isFurnished ? _hasReception : false,
        hasSalon: _isFurnished ? _hasSalon : false,
        isFurnished: _isFurnished,
        bedsCount: _isFurnished ? (int.tryParse(_bedsController.text) ?? 1) : 0,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appProvider.translate('published_success'))));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${appProvider.translate('error')}$e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final isDark = appProvider.isDarkMode;
    final primaryColor = theme.primaryColor;
    final cardColor = theme.cardTheme.color ?? Colors.white;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
        appBar: AppBar(
          title: Text(appProvider.translate('add_property_title')),
          centerTitle: true,
        ),
      body: Directionality(
        textDirection: appProvider.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImagePicker(primaryColor, appProvider),
                    const SizedBox(height: 24),
                    _buildTextField(_titleController, appProvider.translate('property_title'), Icons.title_rounded, cardColor, textColor),
                    _buildCategorySelector(appProvider, primaryColor, cardColor, textColor),
                    _buildTextField(_descriptionController, appProvider.translate('description'), Icons.description_rounded, cardColor, textColor, maxLines: 3),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            _priceController,
                            '${appProvider.translate('price')} (${appProvider.translate('currency')})',
                            Icons.payments_rounded,
                            cardColor,
                            textColor,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) return '';
                              final n = double.tryParse(value);
                              if (n == null || n <= 0) return '';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            _roomsController,
                            appProvider.translate('rooms'),
                            Icons.bed_rounded,
                            cardColor,
                            textColor,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) return '';
                              final n = int.tryParse(value);
                              if (n == null || n <= 0) return '';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    _buildTextField(_locationController, appProvider.translate('location'), Icons.location_on_rounded, cardColor, textColor),
                    
                    const Divider(height: 40),
                    
                    _sectionTitle(appProvider.translate('furnishing'), textColor),
                    const SizedBox(height: 12),
                    _buildFurnishingSelector(appProvider, primaryColor, cardColor, textColor),
                    
                    if (_isFurnished) ...[
                      const SizedBox(height: 24),
                      _sectionTitle(appProvider.translate('amenities_features'), textColor),
                      const SizedBox(height: 12),
                      _buildAmenitiesGrid(primaryColor, cardColor, textColor),
                      const SizedBox(height: 16),
                      _buildTextField(_bedsController, appProvider.translate('beds_count'), Icons.king_bed_rounded, cardColor, textColor, keyboardType: TextInputType.number),
                      const SizedBox(height: 16),
                      _buildFeatureSwitches(appProvider, primaryColor, cardColor, textColor),
                    ],
                    
                    const SizedBox(height: 16),
                    _buildTextField(_otherAmenityController, appProvider.translate('other'), Icons.add_circle_outline_rounded, cardColor, textColor),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomAction(primaryColor, isDark, appProvider),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color textColor) => Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor));

  Widget _buildImagePicker(Color primaryColor, AppProvider appProvider) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length + 1,
        itemBuilder: (context, index) {
          if (index == _images.length) {
            return GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: 110,
                decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryColor.withValues(alpha: 0.2))),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.add_a_photo_rounded, color: primaryColor, size: 28),
                  Text(appProvider.translate('add_photos'), style: TextStyle(color: primaryColor, fontSize: 11)),
                ]),
              ),
            );
          }
          return Stack(children: [
            Container(width: 110, margin: const EdgeInsetsDirectional.only(end: 12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), image: DecorationImage(image: FileImage(_images[index]), fit: BoxFit.cover))),
            PositionedDirectional(top: 4, end: 4, child: GestureDetector(onTap: () => _removeImage(index), child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle), child: const Icon(Icons.close_rounded, color: Colors.white, size: 14)))),
          ]);
        },
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    Color cardColor,
    Color textColor, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1))),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(color: textColor, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF5C61F2), size: 18),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          errorStyle: const TextStyle(height: 0),
        ),
        validator: validator ??
            (value) => (value == null || value.isEmpty) ? '' : null,
      ),
    );
  }

  Widget _buildCategorySelector(AppProvider appProvider, Color primaryColor, Color cardColor, Color textColor) {
    final types = {'Apartment': appProvider.translate('apartment'), 'Studio': appProvider.translate('studio'), 'Shared': appProvider.translate('shared_room')};
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(children: types.entries.map((entry) => Expanded(child: GestureDetector(onTap: () => setState(() => _selectedType = entry.key), child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: _selectedType == entry.key ? primaryColor : cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: _selectedType == entry.key ? primaryColor : Colors.grey.withValues(alpha: 0.1))), alignment: Alignment.center, child: Text(entry.value, style: TextStyle(color: _selectedType == entry.key ? Colors.white : textColor, fontSize: 12)))))).toList()),
    );
  }

  Widget _buildFurnishingSelector(AppProvider appProvider, Color primaryColor, Color cardColor, Color textColor) {
    return Row(
      children: [
        Expanded(child: _choiceChip(appProvider.translate('unfurnished'), !_isFurnished, () => setState(() => _isFurnished = false), primaryColor, cardColor, textColor)),
        const SizedBox(width: 12),
        Expanded(child: _choiceChip(appProvider.translate('furnished'), _isFurnished, () => setState(() => _isFurnished = true), primaryColor, cardColor, textColor)),
      ],
    );
  }

  Widget _choiceChip(String label, bool selected, VoidCallback onTap, Color primaryColor, Color cardColor, Color textColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: selected ? primaryColor : cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? primaryColor : Colors.grey.withValues(alpha: 0.1))),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: selected ? Colors.white : textColor, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _buildAmenitiesGrid(Color primaryColor, Color cardColor, Color textColor) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3, mainAxisSpacing: 10, crossAxisSpacing: 10),
      itemCount: _essentials.length,
      itemBuilder: (context, index) {
        String key = _essentials.keys.elementAt(index);
        bool isSelected = _essentials[key]!;
        return GestureDetector(
          onTap: () => setState(() => _essentials[key] = !isSelected),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: isSelected ? primaryColor : cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? primaryColor : Colors.grey.withValues(alpha: 0.1))),
            child: Row(children: [
              Icon(_amenityIcons[key], color: isSelected ? Colors.white : primaryColor, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(_translateAmenity(key, appProvider), style: TextStyle(color: isSelected ? Colors.white : textColor, fontSize: 11), overflow: TextOverflow.ellipsis)),
            ]),
          ),
        );
      },
    );
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
      default: return key;
    }
  }

  Widget _buildFeatureSwitches(AppProvider appProvider, Color primaryColor, Color cardColor, Color textColor) {
    return Row(children: [
      Expanded(child: _toggle(appProvider.translate('reception'), _hasReception, (v) => setState(() => _hasReception = v), primaryColor, cardColor, textColor)),
      const SizedBox(width: 12),
      Expanded(child: _toggle(appProvider.translate('salon'), _hasSalon, (v) => setState(() => _hasSalon = v), primaryColor, cardColor, textColor)),
    ]);
  }

  Widget _toggle(String label, bool value, Function(bool) onChanged, Color primaryColor, Color cardColor, Color textColor) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: value ? primaryColor.withValues(alpha: 0.1) : cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: value ? primaryColor : Colors.grey.withValues(alpha: 0.1))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: TextStyle(color: textColor, fontSize: 13)),
          Icon(value ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: value ? primaryColor : Colors.grey[400], size: 20),
        ]),
      ),
    );
  }

  Widget _buildBottomAction(Color primaryColor, bool isDark, AppProvider appProvider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF0D1217) : Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))]),
      child: ElevatedButton(
        onPressed: _submitProperty,
        style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: Text(appProvider.translate('publish_now'), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
