import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../data/services/property_service.dart';

class EditPropertyScreen extends StatefulWidget {
  final dynamic property;
  const EditPropertyScreen({super.key, required this.property});

  @override
  State<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _locationController;
  late TextEditingController _roomsController;
  late TextEditingController _bedsController;
  late TextEditingController _otherAmenityController;
  final _propertyService = PropertyService();
  
  String _selectedType = 'Apartment';
  List<dynamic> _existingImages = [];
  final List<File> _newImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isAvailable = true;
  bool _hasReception = false;
  bool _hasSalon = false;
  bool _isFurnished = false;

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

  @override
  void initState() {
    super.initState();
    final p = widget.property;
    _titleController = TextEditingController(text: p['title']);
    _descriptionController = TextEditingController(text: p['description']);
    _priceController = TextEditingController(text: p['price'].toString());
    _locationController = TextEditingController(text: p['location']);
    _roomsController = TextEditingController(text: p['rooms'].toString());
    _bedsController = TextEditingController(text: (p['beds_count'] ?? 1).toString());
    _otherAmenityController = TextEditingController();
    
    _selectedType = (p['property_type'] as String).substring(0, 1).toUpperCase() + (p['property_type'] as String).substring(1);
    _existingImages = List.from(p['images'] ?? []);
    _isAvailable = p['is_available'] ?? true;
    _hasReception = p['has_reception'] ?? false;
    _hasSalon = p['has_salon'] ?? false;
    _isFurnished = p['is_furnished'] ?? false;
    
    List<dynamic> ams = p['amenities'] ?? [];
    List<String> customAmenities = [];
    for (var a in ams) {
      if (_essentials.containsKey(a)) {
        _essentials[a] = true;
      } else {
        customAmenities.add(a.toString());
      }
    }
    if (customAmenities.isNotEmpty) {
      _otherAmenityController.text = customAmenities.join(', ');
    }
  }

  String _translateAmenity(String key, AppProvider appProvider) {
    switch (key) {
      case 'WiFi': return appProvider.translate('wifi');
      case 'Fridge': return appProvider.translate('fridge');
      case 'Washing Machine': return appProvider.translate('washing.machine');
      case 'TV': return appProvider.translate('tv');
      case 'Kitchen': return appProvider.translate('kitchen');
      case 'AC': return appProvider.translate('ac');
      case 'Water Heater': return appProvider.translate('water.heater');
      case 'Study Desk': return appProvider.translate('study.desk');
      default: return key;
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      setState(() {
        _newImages.addAll(selectedImages.map((xFile) => File(xFile.path)).toList());
      });
    }
  }

  Future<void> _submitUpdate(AppProvider appProvider) async {
    if (!_formKey.currentState!.validate()) return;
    if (_existingImages.isEmpty && _newImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appProvider.translate('at.least.one.image') ?? 'At least one image is required')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      List<String> finalUrls = List<String>.from(_existingImages);
      
      for (var imageFile in _newImages) {
        final url = await _propertyService.uploadImage(imageFile);
        finalUrls.add(url);
      }

      final Map<String, bool> finalAmenities = {};
      _essentials.forEach((key, value) {
        if (value) finalAmenities[key] = true;
      });
      
      if (_otherAmenityController.text.isNotEmpty) {
        finalAmenities[_otherAmenityController.text] = true;
      }

      await _propertyService.updateProperty(
        id: widget.property['id'].toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        location: _locationController.text,
        rooms: int.tryParse(_roomsController.text) ?? 1,
        type: _selectedType,
        imageUrls: finalUrls,
        amenities: finalAmenities,
        hasReception: _hasReception,
        hasSalon: _hasSalon,
        isFurnished: _isFurnished,
        bedsCount: int.tryParse(_bedsController.text) ?? 1,
        isAvailable: _isAvailable,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appProvider.translate('property.updated') ?? 'Property updated successfully')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${appProvider.translate('error') ?? 'Error'}: $e')));
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
    final textColor = theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);

    return Scaffold(
      appBar: AppBar(
        title: Text(appProvider.translate('edit.property') ?? 'Edit Property'),
        iconTheme: IconThemeData(color: isDark ? Colors.white : primaryColor),
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
                  _buildImageSection(primaryColor, appProvider, isDark),
                  const SizedBox(height: 24),
                  _buildTextField(_titleController, appProvider.translate('property.title') ?? 'Property Title', Icons.title, appProvider, isDark),
                  const SizedBox(height: 16),
                  _buildTextField(_descriptionController, appProvider.translate('description') ?? 'Description', Icons.description, appProvider, isDark, maxLines: 3),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          _priceController,
                          '${appProvider.translate('price') ?? 'Price'} (${appProvider.translate('currency')})',
                          Icons.payments_rounded,
                          appProvider,
                          isDark,
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
                          appProvider.translate('rooms') ?? 'Rooms',
                          Icons.bed_rounded,
                          appProvider,
                          isDark,
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
                  const SizedBox(height: 16),
                  _buildTextField(_locationController, appProvider.translate('location') ?? 'Location', Icons.location_on, appProvider, isDark),
                  const SizedBox(height: 24),
                  
                  Text(appProvider.translate('furnishing') ?? 'Furnishing Status', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _choiceChip(appProvider.translate('unfurnished') ?? 'Unfurnished', !_isFurnished, () => setState(() => _isFurnished = false), primaryColor, theme, isDark)),
                      const SizedBox(width: 12),
                      Expanded(child: _choiceChip(appProvider.translate('furnished') ?? 'Furnished', _isFurnished, () => setState(() => _isFurnished = true), primaryColor, theme, isDark)),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  Text(appProvider.translate('amenities.features') ?? 'Amenities & Features', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 12),
                  _buildAmenitiesGrid(primaryColor, theme, appProvider, isDark),
                  
                  const SizedBox(height: 24),
                  _buildTextField(_bedsController, appProvider.translate('beds.count') ?? 'Beds Count', Icons.king_bed_rounded, appProvider, isDark, keyboardType: TextInputType.number),
                  
                  const SizedBox(height: 16),
                  Text(appProvider.translate('other.features') ?? 'Other Features', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 12),
                  _buildFeatureSwitches(appProvider, primaryColor, theme, isDark),
                  
                  const SizedBox(height: 16),
                  _buildTextField(_otherAmenityController, appProvider.translate('other') ?? 'Other', Icons.add_circle_outline_rounded, appProvider, isDark),
                  
                  const SizedBox(height: 24),
                  _buildAvailabilityToggle(appProvider, primaryColor, theme, isDark),
                  
                  const SizedBox(height: 32),
                  _buildUpdateButtonStyle(primaryColor, appProvider),
                ],
              ),
            ),
          ),
          if (_isLoading) Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSwitches(AppProvider appProvider, Color primaryColor, ThemeData theme, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _featureToggle(
            appProvider.translate('reception') ?? 'Reception',
            _hasReception,
            (val) => setState(() => _hasReception = val),
            primaryColor, theme, isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _featureToggle(
            appProvider.translate('salon') ?? 'Salon',
            _hasSalon,
            (val) => setState(() => _hasSalon = val),
            primaryColor, theme, isDark,
          ),
        ),
      ],
    );
  }

  Widget _featureToggle(String label, bool value, Function(bool) onChanged, Color primaryColor, ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: value ? primaryColor.withOpacity(0.1) : (isDark ? const Color(0xFF1E2530) : theme.cardTheme.color),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: value ? primaryColor : Colors.grey.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            Icon(
              value ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: value ? primaryColor : Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityToggle(AppProvider appProvider, Color primaryColor, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2530) : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _isAvailable ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(
            _isAvailable ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: _isAvailable ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appProvider.translate('property.status') ?? 'Property Status',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _isAvailable 
                    ? (appProvider.translate('available.for.rent') ?? 'Available for Rent')
                    : (appProvider.translate('rented.closed') ?? 'Rented/Closed'),
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAvailable,
            onChanged: (val) => setState(() => _isAvailable = val),
            activeColor: Colors.green,
            activeTrackColor: Colors.green.withOpacity(0.3),
            inactiveThumbColor: Colors.red,
            inactiveTrackColor: Colors.red.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(Color primaryColor, AppProvider appProvider, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(appProvider.translate('images') ?? 'Images', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._existingImages.map((url) => _imagePreview(url, true, appProvider)),
              ..._newImages.map((file) => _imagePreview(file, false, appProvider)),
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1), 
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor.withOpacity(0.2), style: BorderStyle.solid)
                  ),
                  child: Icon(Icons.add_a_photo, color: primaryColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _imagePreview(dynamic source, bool isUrl, AppProvider appProvider) {
    return Stack(
      children: [
        Container(
          width: 100,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: isUrl ? NetworkImage(source) : FileImage(source) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        PositionedDirectional(
          top: 4,
          end: 12,
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isUrl) _existingImages.remove(source);
                else _newImages.remove(source);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    AppProvider appProvider,
    bool isDark, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        labelStyle:
            TextStyle(color: isDark ? Colors.white60 : Colors.grey[700]),
        errorStyle: const TextStyle(height: 0),
      ),
      validator: validator ??
          (v) =>
              v!.isEmpty ? (appProvider.translate('required') ?? 'Required') : null,
    );
  }

  Widget _buildUpdateButtonStyle(Color primaryColor, AppProvider appProvider) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () => _submitUpdate(appProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          appProvider.translate('update.data') ?? 'Update Data', 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
        ),
      ),
    );
  }

  Widget _choiceChip(String label, bool selected, VoidCallback onTap, Color primaryColor, ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? primaryColor : (isDark ? const Color(0xFF1E2530) : theme.cardTheme.color),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? primaryColor : Colors.grey.withOpacity(0.1)),
        ),
        alignment: Alignment.center,
        child: Text(
          label, 
          style: TextStyle(
            color: selected ? Colors.white : (isDark ? Colors.white70 : theme.textTheme.bodyLarge?.color), 
            fontWeight: selected ? FontWeight.bold : FontWeight.normal
          )
        ),
      ),
    );
  }

  Widget _buildAmenitiesGrid(Color primaryColor, ThemeData theme, AppProvider appProvider, bool isDark) {
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
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : (isDark ? const Color(0xFF1E2530) : theme.cardTheme.color), 
              borderRadius: BorderRadius.circular(12), 
              border: Border.all(color: isSelected ? primaryColor : Colors.grey.withOpacity(0.1))
            ),
            child: Row(children: [
              Icon(_amenityIcons[key], color: isSelected ? Colors.white : primaryColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _translateAmenity(key, appProvider), 
                  style: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : theme.textTheme.bodyLarge?.color), 
                    fontSize: 11
                  ), 
                  overflow: TextOverflow.ellipsis
                )
              ),
            ]),
          ),
        );
      },
    );
  }
}
