import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/property_model.dart';
import '../../providers/app_provider.dart';
import '../../data/services/property_service.dart';
import '../../data/services/chat_service.dart';
import '../chat/chat_screen.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Property property;
  final bool isOwnerView;

  const PropertyDetailsScreen({super.key, required this.property, this.isOwnerView = false});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  final _propertyService = PropertyService();
  final _chatService = ChatService();
  bool _isFavorite = false;
  int _currentImageIndex = 0;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId != null && currentUserId != widget.property.ownerId) {
      _propertyService.incrementViews(widget.property.id);
    }
  }

  Future<void> _checkFavoriteStatus() async {
    final status = await _propertyService.isFavorite(widget.property.id);
    if (mounted) setState(() => _isFavorite = status);
  }

  Future<void> _toggleFavorite() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final newStatus = await _propertyService.toggleFavorite(widget.property.id);
    if (mounted) {
      setState(() => _isFavorite = newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appProvider.translate(newStatus ? 'added.to.favorites' : 'removed.from.favorites') ?? (newStatus ? 'Added to favorites' : 'Removed from favorites')),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _launchCaller() async {
    if (widget.property.ownerPhone == null) return;
    final url = 'tel:${widget.property.ownerPhone}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _launchWhatsApp() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    if (widget.property.ownerPhone == null || widget.property.ownerPhone!.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appProvider.translate('phone.not.available') ?? 'Owner phone not available')));
       return;
    }
    
    String phone = widget.property.ownerPhone!.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.startsWith('0') && !phone.startsWith('00')) {
      phone = '20${phone.substring(1)}'; 
    } else if (phone.length == 10 && phone.startsWith('1')) {
      phone = '20$phone';
    }
    
    final message = Uri.encodeComponent('${appProvider.translate('interest.message') ?? 'Hello, I am interested in your property:'} ${widget.property.title}');
    final whatsappUrl = Uri.parse("https://api.whatsapp.com/send?phone=$phone&text=$message");

    try {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appProvider.translate('error.launch.whatsapp') ?? 'Could not launch WhatsApp')),
        );
      }
    }
  }

  void _startChat() async {
    final chatId = await _chatService.getOrCreateChat(
      ownerId: widget.property.ownerId,
      propertyId: widget.property.id,
    );
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatScreen(chatId: chatId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final isDark = appProvider.isDarkMode;
    final primaryColor = theme.primaryColor;
    final bgColor = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);

    // Split amenities
    final otherKeys = ['Electricity', 'Cleaning Service', 'Security'];
    final mainAmenities = widget.property.amenities.where((a) => !otherKeys.contains(a)).toList();
    final otherAmenities = widget.property.amenities.where((a) => otherKeys.contains(a)).toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(primaryColor, isDark, appProvider),
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Manually handle the vertical space to avoid gaps
                Container(height: 1, color: Colors.transparent),
                
                // THE OVERLAPPING CONTENT
                Transform.translate(
                  offset: const Offset(0, -100), // PUSH IT UP OVER THE IMAGE
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                          blurRadius: 30,
                          offset: const Offset(0, -10),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderContent(textColor, primaryColor, appProvider),
                        const SizedBox(height: 32),
                        _buildSectionTitle(appProvider.translate('about.property') ?? 'About the Property', textColor),
                        const SizedBox(height: 12),
                        Text(
                          widget.property.description,
                          style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 15, height: 1.6),
                          maxLines: _isDescriptionExpanded ? null : 3,
                          overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _isDescriptionExpanded ? 'Read less' : 'Read more', 
                                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)
                              ),
                              Icon(_isDescriptionExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: primaryColor),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildInfoRow(appProvider, textColor),
                        
                        // Section 1: Amenities
                        if (mainAmenities.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          _buildSectionTitle(appProvider.translate('amenities.features') ?? 'Amenities & Features', textColor),
                          const SizedBox(height: 16),
                          _buildAmenitiesGrid(mainAmenities, primaryColor, textColor, isDark, appProvider),
                        ],

                        // Section 2: Other
                        if (otherAmenities.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          _buildSectionTitle(appProvider.translate('other') ?? 'Other', textColor),
                          const SizedBox(height: 16),
                          _buildAmenitiesGrid(otherAmenities, primaryColor, textColor, isDark, appProvider),
                        ],

                        if (!widget.isOwnerView) ...[
                          const SizedBox(height: 32),
                          Text(
                            appProvider.translate('contact.me') ?? 'Contact Me',
                            style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 16),
                          _buildContactOwnerSection(textColor, isDark, appProvider),
                        ],
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(
      Color primaryColor, bool isDark, AppProvider appProvider) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: isDark ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.9),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: isDark ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.9),
            child: IconButton(
              icon: Icon(_isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: Colors.red, size: 22),
              onPressed: _toggleFavorite,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: widget.property.images.length,
              onPageChanged: (index) => setState(() => _currentImageIndex = index),
              itemBuilder: (context, index) => Image.network(widget.property.images[index], fit: BoxFit.cover),
            ),
            // TOP Status Chips
            PositionedDirectional(
              top: 110,
              start: 20,
              child: Row(
                children: [
                  _buildTag(
                    appProvider.translate(
                        widget.property.isAvailable ? 'available' : 'rented'),
                    widget.property.isAvailable ? Colors.green : Colors.red,
                    Colors.white,
                  ),
                  const SizedBox(width: 8),
                  _buildTag(
                    appProvider.translate(widget.property.propertyType),
                    Colors.black.withOpacity(0.6),
                    Colors.white,
                    icon: Icon(
                      widget.property.propertyType == 'apartment'
                          ? Icons.apartment_rounded
                          : widget.property.propertyType == 'villa'
                              ? Icons.villa_rounded
                              : Icons.home_work_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
            PositionedDirectional(
              bottom: 120, // Keep above the overlap
              end: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(20)),
                child: Text('${_currentImageIndex + 1}/${widget.property.images.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color bg, Color text, {Widget? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon, const SizedBox(width: 6)],
          Text(label, style: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHeaderContent(Color textColor, Color primaryColor, AppProvider appProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(widget.property.title, style: TextStyle(color: textColor, fontSize: 26, fontWeight: FontWeight.w900, height: 1.2)),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                    '${widget.property.price.toInt()} ${appProvider.translate('currency')}',
                    style: TextStyle(
                        color: primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w900)),
                Text(appProvider.translate('per.month') ?? 'PER MONTH',
                    style: TextStyle(
                        color: textColor.withOpacity(0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.location_on_rounded, color: primaryColor, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(widget.property.location, style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 15, fontWeight: FontWeight.w500))),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _headerInfoItem(
                Icons.bed_rounded,
                '${widget.property.rooms} ${appProvider.translate('rooms')}',
                textColor,
                primaryColor),
            _headerInfoItem(
                Icons.king_bed_rounded,
                '${widget.property.bedsCount} ${appProvider.translate('beds.count')}',
                textColor,
                primaryColor),
            // White Status Tag (Now at the bottom section)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4)
                ],
              ),
              child: Text(
                appProvider.translate(
                    widget.property.isAvailable ? 'available.now' : 'rented'),
                style: TextStyle(
                  color:
                      widget.property.isAvailable ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _headerInfoItem(IconData icon, String label, Color textColor, Color primaryColor) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 22),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 15, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildInfoRow(AppProvider appProvider, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (widget.property.hasReception)
          _infoItem(Icons.weekend_rounded, appProvider.translate('reception'),
              textColor),
        if (widget.property.isFurnished)
          _infoItem(Icons.check_circle_rounded,
              appProvider.translate('furnished'), textColor),
      ],
    );
  }

  Widget _infoItem(IconData icon, String label, Color textColor) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF5C61F2), size: 32),
        const SizedBox(height: 10),
        Text(label, style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(title, style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w800));
  }

  Widget _buildAmenitiesGrid(List<String> amenities, Color primaryColor, Color textColor, bool isDark, AppProvider appProvider) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: amenities.length,
      itemBuilder: (context, index) {
        final amenity = amenities[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1F26) : const Color(0xFFF8F9FE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(_getAmenityIcon(amenity), color: primaryColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _translateAmenity(amenity, appProvider),
                  style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w600, height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getAmenityIcon(String key) {
    switch (key) {
      case 'WiFi': return Icons.wifi_rounded;
      case 'Fridge': return Icons.kitchen_rounded;
      case 'Washing Machine': return Icons.local_laundry_service_rounded;
      case 'TV': return Icons.tv_rounded;
      case 'Kitchen': return Icons.restaurant_rounded;
      case 'AC': return Icons.ac_unit_rounded;
      case 'Water Heater': return Icons.hot_tub_rounded;
      case 'Study Desk': return Icons.desk_rounded;
      default: return Icons.done_all_rounded;
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
      case 'Electricity': return appProvider.translate('electricity');
      case 'Security': return appProvider.translate('security');
      case 'Cleaning Service': return appProvider.translate('cleaning.service');
      default: return key;
    }
  }

  Widget _buildContactOwnerSection(Color textColor, bool isDark, AppProvider appProvider) {
    final ownerName = widget.property.ownerName ?? 'Owner';
    final primaryColor = const Color(0xFF5C61F2);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E242C) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: primaryColor.withOpacity(0.1),
                backgroundImage: widget.property.ownerAvatar != null && widget.property.ownerAvatar!.isNotEmpty ? NetworkImage(widget.property.ownerAvatar!) : null,
                child: widget.property.ownerAvatar == null || widget.property.ownerAvatar!.isEmpty ? Icon(Icons.person_rounded, color: primaryColor, size: 28) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ownerName, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('Property Owner', style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _contactBtn(Icons.chat_bubble_rounded,
                  appProvider.translate('messages'), primaryColor, _startChat),
              const SizedBox(width: 12),
              _contactBtn(Icons.phone_rounded, appProvider.translate('call'),
                  const Color(0xFF2E7D32), _launchCaller),
              const SizedBox(width: 12),
              _contactBtn(Icons.send_rounded,
                  appProvider.translate('whatsapp'), const Color(0xFF25D366),
                  _launchWhatsApp),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contactBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
