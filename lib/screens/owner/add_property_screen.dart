import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/property_model.dart';
import '../../data/services/property_service.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({
    super.key,
    this.property,
  });

  final Property? property;

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _distanceController = TextEditingController();
  final _addressController = TextEditingController();

  String _roomType = 'Single Room';
  String _status = 'Available';
  String? _initialImageUrl;
  bool _isLoading = false;

  final Map<String, bool> _facilities = {
    'WiFi': false,
    'Parking': false,
    'Laundry': false,
    'Furnished': false,
    'Air Conditioning': false,
    'Kitchen': false,
    'Gym': false,
    'Swimming Pool': false,
  };

  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  final _propertyService = PropertyService();

  @override
  void initState() {
    super.initState();
    final property = widget.property;
    if (property != null) {
      _titleController.text = property.title;
      _descriptionController.text = property.description;
      _priceController.text = property.price.toStringAsFixed(0);
      _distanceController.text = property.distanceToUniversity.toStringAsFixed(1);
      _addressController.text = property.address;
      _roomType = property.roomType;
      _status = property.status;
      _initialImageUrl = property.imageUrl;

      for (final facility in property.facilities) {
        if (_facilities.containsKey(facility)) {
          _facilities[facility] = true;
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _distanceController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _image = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String imageUrl = _initialImageUrl ?? 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1600&q=80';
      
      // If a new image is selected, we should ideally upload it to Supabase Storage first
      // For now, if _image is not null, we'd call an upload method
      // if (_image != null) {
      //   imageUrl = await _propertyService.uploadPropertyImage(_image!) ?? imageUrl;
      // }

      final property = Property(
        id: widget.property?.id ?? '',
        title: _titleController.text.trim(),
        address: _addressController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0,
        distanceToUniversity: double.tryParse(_distanceController.text.trim()) ?? 0,
        roomType: _roomType,
        facilities: _facilities.entries.where((entry) => entry.value).map((entry) => entry.key).toList(),
        imageUrl: imageUrl,
        status: _status,
        description: _descriptionController.text.trim(),
      );

      if (widget.property == null) {
        await _propertyService.addProperty(property);
      } else {
        await _propertyService.updateProperty(property);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        elevation: 0,
        title: Text(widget.property == null ? 'Add Property' : 'Edit Property', style: const TextStyle(color: Colors.white)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF2979FF)))
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildImageSection(),
                const SizedBox(height: 20),
                _buildTextField('Title', _titleController, 'e.g. Modern Studio'),
                const SizedBox(height: 16),
                _buildTextField('Description', _descriptionController, 'Describe your property...', maxLines: 3),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField('Price (\$)', _priceController, '500', isNumber: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField('Distance (km)', _distanceController, '1.2', isNumber: true)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField('Address', _addressController, '123 University St'),
                const SizedBox(height: 16),
                _buildDropdown('Room Type', ['Single Room', 'Studio', '1BR', '2BR', '3BR'], _roomType, (val) => setState(() => _roomType = val!)),
                const SizedBox(height: 16),
                const Text('Facilities', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildFacilitiesGrid(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
    );
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: _image != null 
          ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(File(_image!.path), fit: BoxFit.cover))
          : _initialImageUrl != null
            ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(_initialImageUrl!, fit: BoxFit.cover))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_a_photo_outlined, color: Colors.white54, size: 40),
                  SizedBox(height: 8),
                  Text('Add Property Image', style: TextStyle(color: Colors.white54)),
                ],
              ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {bool isNumber = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFF1E2530),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          dropdownColor: const Color(0xFF161B22),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E2530),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildFacilitiesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 4),
      itemCount: _facilities.length,
      itemBuilder: (context, index) {
        String key = _facilities.keys.elementAt(index);
        bool isSelected = _facilities[key]!;
        return InkWell(
          onTap: () => setState(() => _facilities[key] = !isSelected),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (val) => setState(() => _facilities[key] = val!),
                activeColor: const Color(0xFF2979FF),
                side: const BorderSide(color: Colors.white24),
              ),
              Text(key, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(widget.property == null ? 'Add Property' : 'Save Changes', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
