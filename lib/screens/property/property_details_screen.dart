import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/property_model.dart';
import '../chat/chat_screen.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Property? property;
  const PropertyDetailsScreen({super.key, this.property});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  bool _isExpanded = false;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isArabic = appProvider.isArabic;
    final isDark = appProvider.isDarkMode;

    // Content data
    final title = widget.property?.title ?? (isArabic ? 'سكن واحة المدينة للطلاب' : 'Urban Oasis Student Living');
    final price = widget.property?.price ?? 850;
    final location = widget.property?.location ?? (isArabic ? 'وسط المدينة، مجمع الجامعة، قطاع 4' : 'Downtown Campus Heights, Sector 4');
    final description = widget.property?.description ?? (isArabic 
      ? 'تم تصميم هذا السكن خصيصاً للطالب العصري، حيث يوفر مزيجاً سلسلاً من التركيز الأكاديمي والتواصل الاجتماعي. يقع على بعد 5 دقائق فقط سيراً على الأقدام من بوابة الجامعة الرئيسية، وتتميز هذه الشقق الاستوديو الفاخرة بجدران عازلة للصوت، ومساحات دراسة مريحة، وإنترنت ألياف ضوئية فائق السرعة.'
      : 'Designed specifically for the modern student, Urban Oasis offers a seamless blend of academic focus and social connectivity. Located just a 5-minute walk from the main University gate, these premium studio apartments feature soundproof walls, ergonomic study spaces, and high-speed fiber optic internet.');

    final images = (widget.property != null && widget.property!.images.isNotEmpty)
        ? widget.property!.images
        : [
            'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=2070&auto=format&fit=crop',
            'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=1980&auto=format&fit=crop',
            'https://images.unsplash.com/photo-1484154218962-a197022b5858?q=80&w=2074&auto=format&fit=crop',
          ];

    const primaryColor = Color(0xFF5C61F2);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final secondaryTextColor = isDark ? Colors.white70 : Colors.grey[700];
    final backgroundColor = isDark ? const Color(0xFF0F0F0F) : Colors.white;
    final cardColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Header with Carousel and Arrows
                Stack(
                  children: [
                    SizedBox(
                      height: 400,
                      width: double.infinity,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            images[index],
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    // Gradient Overlay for better icon visibility
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withOpacity(0.2),
                            ],
                            stops: const [0.0, 0.2, 0.8, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Navigation Arrows
                    if (images.length > 1)
                      Positioned.fill(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildNavArrow(Icons.arrow_back_ios_new, () {
                                  _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                }),
                                _buildNavArrow(Icons.arrow_forward_ios, () {
                                  _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    // Page Indicator dots
                    Positioned(
                      bottom: 60,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: images.asMap().entries.map((entry) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == entry.key ? primaryColor : Colors.white.withOpacity(0.5),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildBackButton(context),
                            const Text(
                              'Housing Finder',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.favorite_border, color: Colors.black, size: 24),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Info Card
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('\$$price', style: TextStyle(color: primaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
                                Text('PER\nMONTH', textAlign: TextAlign.right, style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 18, color: primaryColor),
                            const SizedBox(width: 6),
                            Expanded(child: Text(location, style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[600], fontSize: 14))),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _buildTag(isArabic ? 'متاح الآن' : 'Available Now'),
                            _buildTag(isArabic ? 'مفروش بالكامل' : 'Fully Furnished'),
                            _buildTag(isArabic ? 'تأجير فردي' : 'Individual Lease'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appProvider.translate('about.property'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 12),
                      Text(description, maxLines: _isExpanded ? null : 3, style: TextStyle(color: secondaryTextColor, height: 1.6, fontSize: 15)),
                      GestureDetector(
                        onTap: () => setState(() => _isExpanded = !_isExpanded),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Text(_isExpanded ? appProvider.translate('read.less') : appProvider.translate('read.more'), style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                              Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: primaryColor, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(appProvider.translate('amenities'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 2.2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        children: [
                          _buildAmenity(Icons.wifi, isArabic ? 'واي فاي فائق السرعة' : 'Ultra-fast WiFi', isDark),
                          _buildAmenity(Icons.ac_unit, isArabic ? 'تكييف مركزي' : 'Central AC', isDark),
                          _buildAmenity(Icons.local_laundry_service, isArabic ? 'مغسلة داخلية' : 'In-unit Laundry', isDark),
                          _buildAmenity(Icons.fitness_center, isArabic ? 'جيم 24/7' : '24/7 Gym', isDark),
                          _buildAmenity(Icons.security, isArabic ? 'دخول بالبصمة' : 'Biometric Entry', isDark),
                          _buildAmenity(Icons.coffee, isArabic ? 'صالة دراسة' : 'Study Lounge', isDark),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(appProvider.translate('location'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 16),
                      Container(
                        height: 200, 
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20), 
                          image: const DecorationImage(
                            image: NetworkImage('https://api.placeholder.com/600x300?text=Location+Map+View'), 
                            fit: BoxFit.cover
                          )
                        )
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              decoration: BoxDecoration(
                color: backgroundColor.withOpacity(0.95),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: Row(
                children: [
                  Expanded(child: _buildButton(appProvider.translate('book.viewing'), Icons.calendar_today_outlined, false)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildButton(appProvider.translate('contact.owner'), Icons.chat_bubble_outline, true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavArrow(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 45, height: 45,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF5C61F2).withOpacity(0.5))),
        child: const Icon(Icons.arrow_back, color: Color(0xFF5C61F2), size: 20),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFF5C61F2).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: const TextStyle(color: Color(0xFF5C61F2), fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildAmenity(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FE), 
        borderRadius: BorderRadius.circular(16)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF5C61F2), size: 24),
          const SizedBox(height: 8),
          Text(
            label, 
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.w600, 
              color: isDark ? Colors.white70 : const Color(0xFF4A4A4A)
            ), 
            textAlign: TextAlign.center
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, IconData icon, bool isPrimary) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF5C61F2) : Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        border: isPrimary ? null : Border.all(color: const Color(0xFF5C61F2), width: 1.5),
        boxShadow: isPrimary ? [BoxShadow(color: const Color(0xFF5C61F2).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))] : null,
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isPrimary ? Colors.white : const Color(0xFF5C61F2), size: 18),
            const SizedBox(width: 8),
            Text(text, style: TextStyle(color: isPrimary ? Colors.white : const Color(0xFF5C61F2), fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

