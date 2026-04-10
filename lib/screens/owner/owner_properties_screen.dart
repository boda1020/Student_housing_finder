import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../data/services/property_service.dart';
import '../../screens/owner/add_property_screen.dart';
import '../../screens/property_details_screen.dart';

class OwnerPropertiesScreen extends StatefulWidget {
  const OwnerPropertiesScreen({super.key});

  @override
  State<OwnerPropertiesScreen> createState() => _OwnerPropertiesScreenState();
}

class _OwnerPropertiesScreenState extends State<OwnerPropertiesScreen> {
  final _propertyService = PropertyService();
  List<Property> _properties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() => _isLoading = true);
    try {
      final properties = await _propertyService.fetchOwnerProperties();
      setState(() => _properties = properties);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load properties: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addProperty() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddPropertyScreen()),
    );
    _loadProperties();
  }

  Future<void> _editProperty(Property property) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddPropertyScreen(property: property),
      ),
    );
    _loadProperties();
  }

  void _openPropertyDetails(Property property) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PropertyDetailsScreen(
        property: property,
        isOwner: true,
      ),
    ));
  }

  Future<void> _updateStatus(Property property, String status) async {
    try {
      final updated = property.copyWith(status: status);
      await _propertyService.updateProperty(updated);
      _loadProperties();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Properties', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text('${_properties.length} properties', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _addProperty,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add New'),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2979FF)))
          : _properties.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadProperties,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _properties.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final property = _properties[index];
                      return OwnerPropertyCard(
                        property: property,
                        onTap: () => _openPropertyDetails(property),
                        onEdit: () => _editProperty(property),
                        onStatusChanged: (status) => _updateStatus(property, status),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("No properties added yet", style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _addProperty,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
            child: const Text('Add Your First Property'),
          ),
        ],
      ),
    );
  }
}

class OwnerPropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final ValueChanged<String> onStatusChanged;

  const OwnerPropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    required this.onEdit,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: property.imageUrl.isNotEmpty
                        ? Image.network(property.imageUrl, fit: BoxFit.cover)
                        : Container(color: Colors.white10, child: const Icon(Icons.image, color: Colors.white30, size: 48)),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: IconButton(
                    icon: const CircleAvatar(backgroundColor: Colors.black54, child: Icon(Icons.edit, color: Colors.white, size: 18)),
                    onPressed: onEdit,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(property.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white54, size: 14),
                      const SizedBox(width: 4),
                      Text(property.address, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${property.price}/mo', style: const TextStyle(color: Color(0xFF2979FF), fontWeight: FontWeight.bold)),
                      DropdownButton<String>(
                        value: property.status,
                        dropdownColor: const Color(0xFF161B22),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        underline: Container(),
                        items: ['Available', 'Rented', 'Pending'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) => val != null ? onStatusChanged(val) : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
