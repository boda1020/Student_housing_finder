import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/property_model.dart';

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

  final List<XFile> _images = [];
  int _mainImageIndex = 0;
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;

    setState(() {
      _images
        ..clear()
        ..addAll(picked);
      _mainImageIndex = 0;
    });
  }

  void _setMainImage(int index) {
    setState(() {
      _mainImageIndex = index;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final imageUrl = _images.isNotEmpty
        ? _images[_mainImageIndex].path
        : _initialImageUrl ??
            'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1600&q=80';

    final property = Property(
      id: widget.property?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      address: _addressController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      distanceToUniversity:
          double.tryParse(_distanceController.text.trim()) ?? 0,
      roomType: _roomType,
      facilities: _facilities.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList(),
      imageUrl: imageUrl,
      status: _status,
      description: _descriptionController.text.trim(),
    );

    Navigator.of(context).pop(property);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal,
          fontSize: 16,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF0F1B2A),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Colors.white24),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Colors.white24),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Colors.white70, width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1B2A),
        elevation: 0,
        title: Text(widget.property == null ? 'Add Property' : 'Edit Property'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              _buildImageUploadSection(),
              const SizedBox(height: 16),
              _buildPropertyDetailsSection(),
              const SizedBox(height: 16),
              _buildRoomAndFacilitiesSection(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF15202D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(64),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Upload Images'),
          const Text(
            'Drag to reorder images. Click star to set main image.',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.cloud_upload, size: 28, color: Colors.white54),
                  SizedBox(width: 10),
                  Text(
                    'Tap to select images from gallery',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_images.isEmpty)
            Container(
              width: double.infinity,
              height: 170,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.image, size: 42, color: Colors.white24),
                  SizedBox(height: 8),
                  Text(
                    'No images selected yet',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(_images[_mainImageIndex].path),
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ReorderableListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = _images.removeAt(oldIndex);
                    _images.insert(newIndex, item);

                    if (_mainImageIndex == oldIndex) {
                      _mainImageIndex = newIndex;
                    } else if (oldIndex < _mainImageIndex &&
                        newIndex >= _mainImageIndex) {
                      _mainImageIndex -= 1;
                    } else if (oldIndex > _mainImageIndex &&
                        newIndex <= _mainImageIndex) {
                      _mainImageIndex += 1;
                    }
                  });
                },
                children: List.generate(_images.length, (index) {
                  final file = File(_images[index].path);
                  return Padding(
                    key: ValueKey(_images[index].path),
                    padding: const EdgeInsets.only(right: 10),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            file,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 120,
                              height: 120,
                              color: Colors.white10,
                              child: const Center(
                                child: Icon(Icons.broken_image,
                                    color: Colors.white54),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () => _setMainImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0x66000000),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                index == _mainImageIndex
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 18,
                                color: index == _mainImageIndex
                                    ? Colors.yellow
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPropertyDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF15202D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(64),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Property Title'),
          TextFormField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: _buildInputDecoration(
                hintText: 'e.g., Cozy Studio near Campus'),
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Title is required' : null,
          ),
          const SizedBox(height: 14),
          _buildSectionHeader('Description'),
          TextFormField(
            controller: _descriptionController,
            style: const TextStyle(color: Colors.white),
            maxLines: 4,
            decoration:
                _buildInputDecoration(hintText: 'Describe your property...'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monthly Price (\$)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(hintText: '500'),
                      validator: (value) {
                        final v = double.tryParse(value ?? '');
                        if (v == null || v <= 0) {
                          return 'Enter a valid price';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Distance to University (km)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(hintText: '2.5'),
                      validator: (value) {
                        final v = double.tryParse(value ?? '');
                        if (v == null || v < 0) {
                          return 'Enter a valid distance';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Address',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _addressController,
            style: const TextStyle(color: Colors.white),
            decoration: _buildInputDecoration(hintText: '123 Main St, City'),
          ),
          const SizedBox(height: 14),
          _buildSectionHeader('Status'),
          DropdownButtonFormField<String>(
            initialValue: _status,
            dropdownColor: const Color(0xFF0F1B2A),
            decoration: _buildInputDecoration(),
            items: const [
              DropdownMenuItem(value: 'Available', child: Text('Available')),
              DropdownMenuItem(value: 'Rented', child: Text('Rented')),
              DropdownMenuItem(value: 'Closed', child: Text('Closed')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _status = value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoomAndFacilitiesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF15202D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(64),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Room Type'),
          DropdownButtonFormField<String>(
            initialValue: _roomType,
            dropdownColor: const Color(0xFF0F1B2A),
            decoration: _buildInputDecoration(),
            items: const [
              DropdownMenuItem(
                  value: 'Single Room', child: Text('Single Room')),
              DropdownMenuItem(value: 'Studio', child: Text('Studio')),
              DropdownMenuItem(value: '1BR', child: Text('1BR')),
              DropdownMenuItem(value: '2BR', child: Text('2BR')),
              DropdownMenuItem(value: '3BR', child: Text('3BR')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _roomType = value);
              }
            },
          ),
          const SizedBox(height: 14),
          _buildSectionHeader('Facilities'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _facilities.keys.map((facility) {
              final selected = _facilities[facility] ?? false;
              return GestureDetector(
                onTap: () => setState(() => _facilities[facility] = !selected),
                child: Container(
                  width: 150,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white10 : const Color(0xFF0F1B2A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: selected,
                        onChanged: (value) => setState(
                            () => _facilities[facility] = value ?? false),
                        activeColor: Colors.white,
                        checkColor: Colors.black,
                        side: const BorderSide(color: Colors.white24),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      Expanded(
                        child: Text(
                          facility,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: _submit,
        child: Text(widget.property == null ? 'Submit' : 'Save'),
      ),
    );
  }
}
