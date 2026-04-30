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
  final _propertyService = PropertyService();
  
  String _selectedType = 'Apartment';
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Amenities matched with FilterScreen
  final Map<String, bool> _amenities = {
    'WiFi': false,
    'Electricity Inc.': false,
    'Laundry': false,
    'Kitchen': false,
    'Cleaning Service': false,
    'Security': false,
  };

  final Map<String, IconData> _amenityIcons = {
    'WiFi': Icons.wifi_rounded,
    'Electricity Inc.': Icons.bolt_rounded,
    'Laundry': Icons.local_laundry_service_rounded,
    'Kitchen': Icons.restaurant_rounded,
    'Cleaning Service': Icons.cleaning_services_rounded,
    'Security': Icons.security_rounded,
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
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _submitProperty() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Upload images to Supabase Storage
      List<String> imageUrls = [];
      for (var imageFile in _images) {
        final url = await _propertyService.uploadImage(imageFile);
        imageUrls.add(url);
      }

      // 2. Save property data to database
      await _propertyService.addProperty(
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        location: _locationController.text,
        rooms: int.tryParse(_roomsController.text) ?? 1,
        type: _selectedType,
        imageUrls: imageUrls,
        amenities: _amenities,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property published successfully! 🚀')),
        );
        Navigator.pop(context, true); // Return true to trigger refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final isDark = appProvider.isDarkMode;
    final isArabic = appProvider.isArabic;
    final primaryColor = theme.primaryColor;
    final bgColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardTheme.color ?? Colors.white;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isArabic ? 'إضافة عقار جديد' : 'Add New Property',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(isArabic ? 'صور العقار' : 'Property Photos', textColor),
                  const SizedBox(height: 16),
                  _buildImagePicker(cardColor, primaryColor),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle(isArabic ? 'المعلومات الأساسية' : 'Basic Information', textColor),
                  const SizedBox(height: 16),
                  _buildTextField(_titleController, isArabic ? 'عنوان العقار' : 'Property Title', Icons.title_rounded, isDark, cardColor, textColor),
                  const SizedBox(height: 16),
                  
                  _buildSectionTitle(isArabic ? 'فئة السكن' : 'Property Category', textColor),
                  const SizedBox(height: 12),
                  _buildCategorySelector(isArabic, primaryColor, cardColor, textColor),
                  const SizedBox(height: 16),

                  _buildTextField(_descriptionController, isArabic ? 'الوصف' : 'Description', Icons.description_rounded, isDark, cardColor, textColor, maxLines: 4),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(_priceController, isArabic ? 'السعر (ج.م)' : 'Price (\$)', Icons.payments_rounded, isDark, cardColor, textColor, keyboardType: TextInputType.number),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(_roomsController, isArabic ? 'الغرف' : 'Rooms', Icons.bed_rounded, isDark, cardColor, textColor, keyboardType: TextInputType.number),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(_locationController, isArabic ? 'الموقع' : 'Location', Icons.location_on_rounded, isDark, cardColor, textColor),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle(isArabic ? 'المرافق والخدمات' : 'Amenities & Features', textColor),
                  const SizedBox(height: 16),
                  _buildAmenitiesGrid(primaryColor, cardColor, textColor, isDark),
                  
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomAction(primaryColor, isArabic, isDark),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(child: CircularProgressIndicator(color: primaryColor)),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor),
    );
  }

  Widget _buildImagePicker(Color cardColor, Color primaryColor) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length + 1,
        itemBuilder: (context, index) {
          if (index == _images.length) {
            return GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: 120,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryColor.withOpacity(0.2), style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_rounded, color: primaryColor, size: 30),
                    const SizedBox(height: 8),
                    Text('Add Photos', style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          }
          return Stack(
            children: [
              Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(image: FileImage(_images[index]), fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: 8,
                right: 20,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isDark, Color cardColor, Color textColor, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF5C61F2), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) => value!.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildAmenitiesGrid(Color primaryColor, Color cardColor, Color textColor, bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.8,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: _amenities.length,
      itemBuilder: (context, index) {
        String key = _amenities.keys.elementAt(index);
        bool isSelected = _amenities[key]!;
        
        // Use translation keys if possible or hardcoded for now to match exactly
        String label = key;
        if (key == 'WiFi') label = 'Free WiFi';
        if (key == 'Electricity Inc.') label = 'Electricity Inc.';
        
        return GestureDetector(
          onTap: () => setState(() => _amenities[key] = !isSelected),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? primaryColor : Colors.grey.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(_amenityIcons[key], color: isSelected ? Colors.white : primaryColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : textColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategorySelector(bool isArabic, Color primaryColor, Color cardColor, Color textColor) {
    final types = {
      'Apartment': isArabic ? 'شقة' : 'Apartment',
      'Studio': isArabic ? 'استوديو' : 'Studio',
      'Shared': isArabic ? 'سكن مشترك' : 'Shared',
    };

    return Row(
      children: types.entries.map((entry) {
        bool isSelected = _selectedType == entry.key;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedType = entry.key),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? primaryColor : Colors.grey.withOpacity(0.1)),
              ),
              alignment: Alignment.center,
              child: Text(
                entry.value,
                style: TextStyle(
                  color: isSelected ? Colors.white : textColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomAction(Color primaryColor, bool isArabic, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1217) : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: ElevatedButton(
        onPressed: _submitProperty,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(
          isArabic ? 'نشر العقار الآن' : 'Publish Property Now',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
