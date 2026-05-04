import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../providers/app_provider.dart';
import 'package:provider/provider.dart';
import '../../data/services/property_service.dart';

class PropertyCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = appProvider.isDarkMode;
    const primaryColor = Color(0xFF5C61F2);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 260,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          children: [
            // Image Section
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Image.network(
                      property.images.isNotEmpty ? property.images[0] : 'https://api.placeholder.com/400x250',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                  // Availability Badge - Top Start (Left in EN, Right in AR)
                  PositionedDirectional(
                    top: 12,
                    start: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: property.isAvailable ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                      ),
                      child: Text(
                        property.isAvailable ? (appProvider.translate('available') ?? "Available") : (appProvider.translate('rented') ?? "Rented"),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  // Action/Favorite Buttons - Top End (Right in EN, Left in AR)
                  PositionedDirectional(
                    top: 12,
                    end: 12,
                    child: actionButtons ?? _FavoriteButton(propertyId: property.id),
                  ),
                ],
              ),
            ),
            // Info Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            property.title,
                            style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (property.isVerified)
                          const Icon(Icons.verified_rounded, color: Colors.blue, size: 18),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.location_on_rounded, size: 14, color: primaryColor.withOpacity(0.7)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  property.location,
                                  style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "${property.price.toInt()} ${appProvider.translate('currency')}",
                          style: const TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                      ],
                    ),
                    const Divider(height: 12, thickness: 0.5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildFeatureIcon(Icons.bed_rounded, "${property.rooms} ${appProvider.translate('rooms')}", textColor),
                        const SizedBox(width: 16),
                        _buildFeatureIcon(Icons.king_bed_rounded, "${property.bedsCount} ${appProvider.translate('beds')}", textColor),
                        if (property.isFurnished) ...[
                          const SizedBox(width: 16),
                          _buildFeatureIcon(Icons.chair_rounded, appProvider.translate('furnished'), textColor),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String text, Color textColor) {
    return Row(
      children: [
        Icon(icon, size: 14, color: textColor.withValues(alpha: 0.5)),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  final String propertyId;
  const _FavoriteButton({required this.propertyId});

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  final _propertyService = PropertyService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  void _checkStatus() async {
    final status = await _propertyService.isFavorite(widget.propertyId);
    if (mounted) setState(() => _isFavorite = status);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final newStatus = await _propertyService.toggleFavorite(widget.propertyId);
        setState(() => _isFavorite = newStatus);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
        ),
        child: Icon(
          _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: Colors.redAccent,
          size: 20,
        ),
      ),
    );
  }
}
