import 'package:flutter/material.dart';

import '../../models/property_model.dart';
import '../../screens/owner/add_property_screen.dart';
import '../../screens/property_details_screen.dart';

class OwnerPropertiesScreen extends StatefulWidget {
  const OwnerPropertiesScreen({
    super.key,
    required this.properties,
  });

  final List<Property> properties;

  @override
  State<OwnerPropertiesScreen> createState() => _OwnerPropertiesScreenState();
}

class _OwnerPropertiesScreenState extends State<OwnerPropertiesScreen> {
  Future<void> _addProperty() async {
    final newProperty = await Navigator.of(context).push<Property>(
      MaterialPageRoute(builder: (context) => const AddPropertyScreen()),
    );

    if (newProperty != null) {
      setState(() {
        widget.properties.insert(0, newProperty);
      });
    }
  }

  Future<void> _editProperty(Property property) async {
    final updatedProperty = await Navigator.of(context).push<Property>(
      MaterialPageRoute(
        builder: (context) => AddPropertyScreen(property: property),
      ),
    );

    if (updatedProperty != null) {
      setState(() {
        final idx = widget.properties.indexWhere((p) => p.id == updatedProperty.id);
        if (idx != -1) {
          widget.properties[idx] = updatedProperty;
        }
      });
    }
  }

  void _shareProperty(Property property) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share "${property.title}" (not implemented)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openPropertyDetails(Property property) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PropertyDetailsScreen(
        property: property,
        isOwner: true,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1B2A),
        elevation: 0,
        leading: const BackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Properties'),
            const SizedBox(height: 4),
            Text(
              '${widget.properties.length} properties',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
            ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add New'),
            ),
          ),
        ],
      ),
      body: widget.properties.isEmpty
          ? _buildEmptyState()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: ListView.separated(
                itemCount: widget.properties.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final property = widget.properties[index];
                  return OwnerPropertyCard(
                    property: property,
                    onTap: () => _openPropertyDetails(property),
                    onEdit: () => _editProperty(property),
                    onShare: () => _shareProperty(property),
                    onStatusChanged: (status) {
                      setState(() {
                        final idx = widget.properties.indexWhere((p) => p.id == property.id);
                        if (idx != -1) {
                          widget.properties[idx] = property.copyWith(status: status);
                        }
                      });
                    },
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "You haven't added any properties yet",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _addProperty,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Property'),
            ),
          ],
        ),
      ),
    );
  }
}

class OwnerPropertyCard extends StatelessWidget {
  const OwnerPropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    required this.onEdit,
    required this.onShare,
    required this.onStatusChanged,
  });

  final Property property;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final ValueChanged<String> onStatusChanged;

  static const statusOptions = ['Available', 'Rented', 'Closed'];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Material(
        color: const Color(0xFF0F1B2A),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      property.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade900,
                        child: const Center(
                          child: Icon(Icons.photo, size: 48, color: Colors.white30),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: property.isAvailable ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        property.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: PopupMenuButton<String>(
                      color: const Color(0xFF0F1B2A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.all(4),
                      iconSize: 18,
                      splashRadius: 22,
                      icon: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(0, 0, 0, 0.6),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.18), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromRGBO(0, 0, 0, 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.more_vert, color: Colors.white, size: 18),
                        ),
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit();
                        } else if (value == 'share') {
                          onShare();
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'share', child: Text('Share')),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            property.address,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade300,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.directions_walk, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${property.distanceToUniversity.toStringAsFixed(1)} km from university',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade300,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '\$${property.price.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                              ),
                              TextSpan(
                                text: '/per month',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade300,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            property.roomType,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: property.status,
                            dropdownColor: const Color(0xFF0F1B2A),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              filled: true,
                              fillColor: const Color(0xFF15202D),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: statusOptions
                                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                onStatusChanged(value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
