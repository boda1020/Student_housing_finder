import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../data/services/property_service.dart';
import 'edit_property_screen.dart';

class OwnerPropertiesScreen extends StatefulWidget {
  const OwnerPropertiesScreen({super.key});

  @override
  State<OwnerPropertiesScreen> createState() => _OwnerPropertiesScreenState();
}

class _OwnerPropertiesScreenState extends State<OwnerPropertiesScreen> {
  final _propertyService = PropertyService();
  bool _isLoading = true;
  List<dynamic> _properties = [];

  @override
  void initState() {
    super.initState();
    _fetchProperties();
  }

  Future<void> _fetchProperties() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _propertyService.getOwnerProperties();
      if (mounted) {
        setState(() {
          _properties = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final appProvider = Provider.of<AppProvider>(context, listen: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${appProvider.translate('error_loading_properties')}: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteProperty(String id) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appProvider.translate('delete_property_title')),
        content: Text(appProvider.translate('delete_property_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(appProvider.translate('cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(appProvider.translate('delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _propertyService.deleteProperty(id);
        _fetchProperties();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(appProvider.translate('deleted_success')))
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${appProvider.translate('error_deleting')}$e'))
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isAr = appProvider.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(appProvider.translate('my_properties_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: RefreshIndicator(
          onRefresh: _fetchProperties,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _properties.isEmpty
                  ? Center(child: Text(appProvider.translate('no_properties_listed')))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _properties.length,
                      itemBuilder: (context, index) {
                        final property = _properties[index];
                        return _buildPropertyCard(property, isAr, appProvider);
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildPropertyCard(dynamic property, bool isAr, AppProvider appProvider) {
    final images = property['images'] as List?;
    final imageUrl = (images != null && images.isNotEmpty) ? images[0] : null;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1)),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: isDark ? const Color(0xFF252932) : Colors.grey[100],
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                          },
                          errorBuilder: (context, error, stackTrace) => 
                            Icon(Icons.broken_image_outlined, size: 50, color: Colors.grey.withOpacity(0.5)),
                        )
                      : Icon(Icons.image_outlined, size: 50, color: Colors.grey.withOpacity(0.5)),
                ),
              ),
              PositionedDirectional(
                top: 12,
                end: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, color: Colors.orange, size: 16),
                      SizedBox(width: 4),
                      Text('4.8', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        property['title'] ?? 'No Title',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        appProvider.translate('active'),
                        style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(property['location'] ?? 'Location', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${property['price']} ${appProvider.translate('currency')}',
                            style: TextStyle(
                              fontSize: 22, 
                              fontWeight: FontWeight.bold, 
                              color: theme.primaryColor
                            ),
                          ),
                          TextSpan(
                            text: isAr ? ' /شهرياً' : ' /mo',
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _buildActionButton(Icons.edit_outlined, Colors.grey, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditPropertyScreen(property: property)),
                          ).then((_) => _fetchProperties());
                        }),
                        const SizedBox(width: 12),
                        _buildActionButton(Icons.delete_outline_rounded, Colors.red, () {
                          _deleteProperty(property['id'].toString());
                        }),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
