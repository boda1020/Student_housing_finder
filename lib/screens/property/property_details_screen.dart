import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/property_model.dart';
import '../../providers/app_provider.dart';
import '../../data/services/property_service.dart';
import '../../data/services/chat_service.dart';
import '../chat/chat_screen.dart';
import '../owner/edit_property_screen.dart';

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
  int _currentImageIndex = 0;
  bool _isActualOwner = false;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    
    final user = Supabase.instance.client.auth.currentUser;
    _isActualOwner = user?.id == widget.property.ownerId;

    if (user != null && !_isActualOwner) {
      _propertyService.incrementViews(widget.property.id);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startChat() async {
    try {
      final chatId = await _chatService.getOrCreateChat(
        ownerId: widget.property.ownerId,
        propertyId: widget.property.id,
      );
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(chatId: chatId)));
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = appProvider.isDarkMode;
    final isAr = appProvider.isArabic;
    const primaryColor = Color(0xFF5C61F2);
    final bgColor = isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    final bool isStudent = !_isActualOwner && !widget.isOwnerView;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(isAr ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            appProvider.translate('property_details'),
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            if (isStudent)
              _FavoriteButton(propertyId: widget.property.id)
            else if (_isActualOwner)
              IconButton(
                icon: const Icon(Icons.edit_note_rounded, color: primaryColor),
                onPressed: () => Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => EditPropertyScreen(property: widget.property.toMap()))
                ),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildImageSlider(isDark),
              
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderInfo(textColor, primaryColor, appProvider),
                    const Divider(height: 30),
                    
                    _buildSectionTitle(appProvider.translate('about_property'), textColor),
                    const SizedBox(height: 8),
                    Text(
                      widget.property.description,
                      style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14, height: 1.5),
                    ),
                    
                    const SizedBox(height: 24),
                    _buildAmenitiesSection(primaryColor, textColor, appProvider),
                    
                    if (isStudent) ...[
                      const Divider(height: 40),
                      _buildSectionTitle(appProvider.translate('contact_owner'), textColor),
                      const SizedBox(height: 16),
                      _buildContactCard(textColor, isDark, appProvider, primaryColor),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
        bottomNavigationBar: isStudent ? _buildBottomAction(primaryColor, appProvider, cardBg, isDark) : null,
      ),
    );
  }

  Widget _buildImageSlider(bool isDark) {
    return Container(
      height: 250,
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: widget.property.images.isNotEmpty
                ? PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentImageIndex = index),
                    itemCount: widget.property.images.length,
                    itemBuilder: (context, index) => Image.network(
                      widget.property.images[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 50),
                      ),
                    ),
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  ),
          ),
          if (widget.property.images.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.property.images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentImageIndex == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentImageIndex == index ? Colors.white : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(Color textColor, Color primaryColor, AppProvider appProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(widget.property.title, style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w900))),
            Text("${widget.property.price.toInt()} ${appProvider.translate('currency')}", 
              style: TextStyle(color: primaryColor, fontSize: 20, fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.location_on_rounded, color: primaryColor, size: 16),
            const SizedBox(width: 4),
            Text(widget.property.location, style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 13)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: widget.property.isAvailable ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.property.isAvailable ? (appProvider.translate('available') ?? "Available") : (appProvider.translate('rented') ?? "Rented"),
                style: TextStyle(color: widget.property.isAvailable ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(title, style: TextStyle(color: textColor, fontSize: 17, fontWeight: FontWeight.w800));
  }

  Widget _buildAmenitiesSection(Color primaryColor, Color textColor, AppProvider appProvider) {
    if (widget.property.amenities.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(appProvider.translate('amenities'), textColor),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: widget.property.amenities.map((a) {
            // Try to translate the amenity name
            final String translatedLabel = appProvider.translate(a.toLowerCase().trim()) ?? a;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: primaryColor.withOpacity(0.1)),
              ),
              child: Text(translatedLabel, style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.w600)),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _callOwner() async {
    if (widget.property.ownerPhone != null) {
      final Uri url = Uri.parse('tel:${widget.property.ownerPhone}');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }

  void _whatsappOwner() async {
    if (widget.property.ownerPhone != null) {
      String phone = widget.property.ownerPhone!;
      if (!phone.startsWith('+')) {
        phone = '+20$phone'; // Default to Egypt if no country code
      }
      final Uri url = Uri.parse('https://wa.me/$phone');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }

  Widget _buildContactCard(Color textColor, bool isDark, AppProvider appProvider, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: primaryColor.withOpacity(0.1),
                backgroundImage: widget.property.ownerAvatar != null ? NetworkImage(widget.property.ownerAvatar!) : null,
                child: widget.property.ownerAvatar == null ? Icon(Icons.person, color: primaryColor, size: 30) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.property.ownerName ?? "Owner", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      widget.property.ownerPhone ?? (appProvider.translate('phone_not_available') ?? "Phone not available"),
                      style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (_isActualOwner)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text("Owner", style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildContactButton(
                  onTap: _startChat,
                  icon: Icons.chat_bubble_rounded,
                  label: appProvider.translate('messages') ?? "Messages",
                  color: primaryColor,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildContactButton(
                  onTap: _callOwner,
                  icon: Icons.phone_rounded,
                  label: appProvider.translate('call') ?? "Call",
                  color: Colors.green,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildContactButton(
                  onTap: _whatsappOwner,
                  icon: Icons.send_rounded,
                  label: "WhatsApp",
                  color: const Color(0xFF25D366),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildBottomAction(Color primaryColor, AppProvider appProvider, Color cardBg, bool isDark) {
    return Container(
      height: 85,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          // Price Section
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${widget.property.price.toInt()} ${appProvider.translate('currency')}",
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 20),
              ),
              Text(
                (appProvider.translate('per_month') ?? "PER MONTH").toUpperCase(),
                style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
              ),
            ],
          ),
          const Spacer(),
          // Project Name (Middle)
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                appProvider.translate('app_title').toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: primaryColor.withOpacity(0.8),
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          const Spacer(),
          // Message Icon Button (Right)
          InkWell(
            onTap: _startChat,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
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
    return IconButton(
      icon: Icon(
        _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: Colors.redAccent,
      ),
      onPressed: () async {
        final newStatus = await _propertyService.toggleFavorite(widget.propertyId);
        setState(() => _isFavorite = newStatus);
      },
    );
  }
}
