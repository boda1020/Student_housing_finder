import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../providers/app_provider.dart';
import 'package:provider/provider.dart';
import '../../data/services/property_service.dart';

class PropertyCard extends StatefulWidget {
  final Property property;
  final VoidCallback onTap;
  final Widget? actionButtons;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    this.actionButtons,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  final _propertyService = PropertyService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final status = await _propertyService.isFavorite(widget.property.id);
    if (mounted) setState(() => _isFavorite = status);
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isFavorite = !_isFavorite);
    final newStatus = await _propertyService.toggleFavorite(widget.property.id);
    if (mounted && newStatus != _isFavorite) {
      setState(() => _isFavorite = newStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = appProvider.isDarkMode;
    
    final cardBg = isDark ? const Color(0xFF1E2530) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1C1E);
    final priceColor = const Color(0xFF6366F1);
    final locationColor = isDark ? Colors.white60 : const Color(0xFF64748B);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        // Fixed height to ensure the Stack behaves and allows the overlap
        height: 440, 
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Image (The Base)
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.network(
                widget.property.images.isNotEmpty ? widget.property.images[0] : 'https://api.placeholder.com/400x250',
                height: 320,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            
            // 2. Info Container (THE REAL OVERLAP)
            Positioned(
              top: 220, // This is where the magic happens (320 image height - 220 = 100px overlap)
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.5 : 0.12),
                      blurRadius: 30,
                      spreadRadius: 2,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.property.title,
                            style: TextStyle(color: titleColor, fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${widget.property.price.toInt()} ${appProvider.translate('currency')}', style: TextStyle(color: priceColor, fontWeight: FontWeight.w900, fontSize: 18)),
                            Text(appProvider.translate('per.month') ?? 'PER MONTH', style: TextStyle(color: locationColor, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 16, color: priceColor),
                        const SizedBox(width: 6),
                        Expanded(child: Text(widget.property.location, style: TextStyle(color: locationColor, fontSize: 13, fontWeight: FontWeight.w500))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Icon(Icons.bed_rounded,
                              size: 16, color: priceColor.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Text(
                              '${widget.property.rooms} ${appProvider.translate('rooms')}',
                              style: TextStyle(
                                  color: titleColor.withOpacity(0.8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(width: 16),
                          Icon(Icons.king_bed_rounded,
                              size: 16, color: priceColor.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Text(
                              '${widget.property.bedsCount} ${appProvider.translate('beds.count')}',
                              style: TextStyle(
                                  color: titleColor.withOpacity(0.8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          // White Status Chip (Bottom) - The one that was at the top
                          _buildModernChip(
                            appProvider.translate(widget.property.isAvailable
                                ? 'available.now'
                                : 'rented'),
                            Colors.white,
                            widget.property.isAvailable
                                ? Colors.green
                                : Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. TOP Status Chips - The one that was at the bottom goes here
            PositionedDirectional(
              top: 20,
              start: 20,
              child: Row(
                children: [
                  _buildModernChip(
                    appProvider.translate(
                        widget.property.isAvailable ? 'available' : 'rented'),
                    widget.property.isAvailable ? Colors.green : Colors.red,
                    Colors.white,
                    elevation: 8,
                  ),
                  const SizedBox(width: 8),
                  _buildModernChip(
                    appProvider.translate(widget.property.propertyType),
                    Colors.black.withOpacity(0.6),
                    Colors.white,
                    elevation: 8,
                    icon: Icon(
                      widget.property.propertyType == 'apartment'
                          ? Icons.apartment_rounded
                          : widget.property.propertyType == 'villa'
                              ? Icons.villa_rounded
                              : Icons.home_work_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),

            // 4. Favorite Button
            PositionedDirectional(
              top: 20,
              end: 20,
              child: widget.actionButtons ?? GestureDetector(
                onTap: _toggleFavorite,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                  child: Icon(_isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: Colors.red, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernChip(String label, Color bg, Color text, {double elevation = 0, Widget? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: elevation > 0 ? [BoxShadow(color: Colors.black26, blurRadius: elevation, offset: Offset(0, elevation/2))] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon, const SizedBox(width: 6)],
          Text(label, style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
